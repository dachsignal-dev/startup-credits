#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/kids_music_wan_benchmark"
EVIDENCE="$ROOT/benchmark_evidence"
REPO="$ROOT/Wan2.2"
VENV="$ROOT/.venv"
MODEL_DIR="$ROOT/Wan2.2-TI2V-5B"
mkdir -p "$EVIDENCE" "$ROOT/tests" "$ROOT/outputs" "$ROOT/uploads"

fail() {
  rc=$?
  printf 'BLOCKED_CPU_PREP\nreason=command_failed_rc_%s_line_%s\ncost_eur=0\n' "$rc" "${BASH_LINENO[0]:-unknown}" | tee -a "$EVIDENCE/final_status.txt"
  exit "$rc"
}
trap fail ERR

{
  echo "timestamp=$(date -Is)"
  echo "pwd=$(pwd)"
  echo "python=$(python3 --version 2>&1 || true)"
  echo "git=$(git --version 2>&1 || true)"
  echo "curl=$(curl --version 2>/dev/null | head -n1 || true)"
  echo "disk:"; df -h "$HOME" || true
  echo "ram:"; free -h || true
  echo "cuda:"; python3 - <<'PY'
try:
    import torch
    print('torch=', torch.__version__)
    print('cuda_available=', torch.cuda.is_available())
except Exception as exc:
    print('torch_check=', repr(exc))
PY
} > "$EVIDENCE/environment.txt" 2>&1

rm -f "$ROOT/benchmark_wrapper.py" "$ROOT/server.py"
rm -f "$ROOT/tests/test_benchmark.py"

python3 -m venv "$VENV"
source "$VENV/bin/activate"
python -m pip install -q --upgrade pip
python -m pip install -q pytest fastapi uvicorn pydantic huggingface_hub python-multipart

cat > "$ROOT/tests/test_benchmark.py" <<'PY'
import pytest


def test_request_rejects_missing_image_or_prompt():
    from benchmark_wrapper import validate_request
    with pytest.raises(ValueError):
        validate_request('', 'move gently')
    with pytest.raises(ValueError):
        validate_request('input.png', '')


def test_size_is_locked():
    from benchmark_wrapper import WIDTH, HEIGHT
    assert (WIDTH, HEIGHT) == (1280, 704)


def test_command_contains_required_wan_flags():
    from benchmark_wrapper import build_command
    import benchmark_wrapper
    cmd = build_command('input.png', 'characters wave')
    assert cmd[:2] == ['python', str(benchmark_wrapper.WAN_DIR / 'generate.py')]
    assert '--task' in cmd and cmd[cmd.index('--task') + 1] == 'ti2v-5B'
    assert '--size' in cmd and cmd[cmd.index('--size') + 1] == '1280*704'
    assert '--offload_model' in cmd and cmd[cmd.index('--offload_model') + 1] == 'True'
    assert '--convert_model_dtype' in cmd
    assert '--t5_cpu' in cmd
    assert '--image' in cmd and cmd[cmd.index('--image') + 1] == 'input.png'
    assert '--prompt' in cmd and cmd[cmd.index('--prompt') + 1] == 'characters wave'


def test_cpu_refuses_generation():
    from benchmark_wrapper import ensure_gpu
    with pytest.raises(RuntimeError):
        ensure_gpu(cuda_available=False)
PY

cd "$ROOT"
set +e
PYTHONPATH="$ROOT" pytest -q tests/test_benchmark.py > "$EVIDENCE/red_tests.txt" 2>&1
RED_RC=$?
set -e
if [[ "$RED_RC" -eq 0 ]]; then
  echo 'BLOCKED_CPU_PREP' | tee "$EVIDENCE/final_status.txt"
  echo 'reason=tdd_red_unexpectedly_passed' | tee -a "$EVIDENCE/final_status.txt"
  echo 'cost_eur=0' | tee -a "$EVIDENCE/final_status.txt"
  exit 2
fi
if ! grep -Eq 'ModuleNotFoundError|ImportError|ERROR collecting|failed' "$EVIDENCE/red_tests.txt"; then
  echo 'BLOCKED_CPU_PREP' | tee "$EVIDENCE/final_status.txt"
  echo 'reason=tdd_red_not_the_expected_missing_implementation_failure' | tee -a "$EVIDENCE/final_status.txt"
  echo 'cost_eur=0' | tee -a "$EVIDENCE/final_status.txt"
  exit 3
fi

if [[ ! -d "$REPO/.git" ]]; then
  git clone --depth 1 https://github.com/Wan-Video/Wan2.2.git "$REPO"
else
  git -C "$REPO" fetch --depth 1 origin main
  git -C "$REPO" reset --hard origin/main
fi
WAN_COMMIT="$(git -C "$REPO" rev-parse HEAD)"

cat > "$ROOT/benchmark_wrapper.py" <<PY
from pathlib import Path
import subprocess

WIDTH = 1280
HEIGHT = 704
ROOT = Path(r"$ROOT")
WAN_DIR = ROOT / "Wan2.2"
CKPT_DIR = ROOT / "Wan2.2-TI2V-5B"


def validate_request(image: str, prompt: str):
    if not image or not str(image).strip():
        raise ValueError("image is required")
    if not prompt or not str(prompt).strip():
        raise ValueError("prompt is required")


def ensure_gpu(cuda_available: bool):
    if not cuda_available:
        raise RuntimeError("CUDA unavailable: refusing video generation")


def build_command(image: str, prompt: str):
    validate_request(image, prompt)
    return [
        "python", str(WAN_DIR / "generate.py"),
        "--task", "ti2v-5B",
        "--size", "1280*704",
        "--ckpt_dir", str(CKPT_DIR),
        "--offload_model", "True",
        "--convert_model_dtype",
        "--t5_cpu",
        "--image", image,
        "--prompt", prompt,
    ]


def generate(image: str, prompt: str):
    import torch
    ensure_gpu(torch.cuda.is_available())
    return subprocess.run(build_command(image, prompt), cwd=WAN_DIR, check=True)
PY

cat > "$ROOT/server.py" <<'PY'
from pathlib import Path
import shutil
import uuid
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from benchmark_wrapper import generate

app = FastAPI(title='Kids Music Wan2.2 Benchmark')
UPLOAD_DIR = Path('uploads')
UPLOAD_DIR.mkdir(exist_ok=True)


@app.post('/generate')
async def generate_video(image: UploadFile = File(...), prompt: str = Form(...)):
    if not prompt.strip():
        raise HTTPException(400, 'prompt is required')
    suffix = Path(image.filename or 'input.png').suffix or '.png'
    target = UPLOAD_DIR / f'{uuid.uuid4().hex}{suffix}'
    with target.open('wb') as fh:
        shutil.copyfileobj(image.file, fh)
    try:
        generate(str(target), prompt)
    except RuntimeError as exc:
        raise HTTPException(503, str(exc))
    return {'status': 'generation_invoked', 'image': str(target), 'resolution': '1280x704', 'concurrency': 1}
PY

PYTHONPATH="$ROOT" pytest -q tests/test_benchmark.py | tee "$EVIDENCE/tests.txt"
python -m py_compile "$ROOT/benchmark_wrapper.py" "$ROOT/server.py"

cp "$REPO/requirements.txt" "$EVIDENCE/wan_requirements.txt"

FREE_GB="$(df -Pk "$HOME" | awk 'NR==2 {printf "%d", $4/1024/1024}')"
WEIGHTS_STATUS='NEEDS_GPU_STAGE'
if [[ "$FREE_GB" -ge 45 ]]; then
  python - <<PY
from huggingface_hub import snapshot_download
snapshot_download(repo_id='Wan-AI/Wan2.2-TI2V-5B', local_dir=r'$MODEL_DIR')
PY
  [[ -d "$MODEL_DIR" ]] && WEIGHTS_STATUS='READY'
else
  printf 'weights_deferred: only %s GiB free; threshold is 45 GiB\n' "$FREE_GB" > "$EVIDENCE/weights_deferred.txt"
fi

cat > "$EVIDENCE/READY.md" <<EOF
# Wan2.2 CPU Prep Benchmark
repo_commit: $WAN_COMMIT
model: Wan-AI/Wan2.2-TI2V-5B
task: ti2v-5B
target_resolution: 1280x704
target_fps: 24
weights: $WEIGHTS_STATUS
disk_free_gb_at_check: $FREE_GB
cpu_tests: PASS
full_wan_runtime_install: DEFERRED_TO_GPU_STAGE_BECAUSE_FLASH_ATTN_IS_CUDA_SENSITIVE
cash_spend_eur: 0
paid_api_used: false
card_added: false
payg_enabled: false
next_gpu_stage: switch to one L40S only after explicit owner action; install GPU runtime; verify CUDA; run exactly one I2V benchmark; record runtime/credits; stop GPU immediately
EOF

{
  echo 'READY_FOR_L40S'
  echo 'tests=PASS'
  echo "weights=$WEIGHTS_STATUS"
  echo 'cost_eur=0'
  echo 'next_action=wait_for_assistant_to_verify_then_switch_once_to_L40S'
} | tee "$EVIDENCE/final_status.txt"
