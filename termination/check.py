#!/usr/bin/env python3
"""Compile the study's baseline and lessons with this checkout's Rocq."""

from datetime import datetime, timezone
import hashlib
import os
from pathlib import Path
import shlex
import subprocess


STUDY = Path(__file__).resolve().parent
ROOT = STUDY.parent.parent
ROCQ = ROOT / "_build/install/default/bin/rocq"
LOGS = STUDY / "logs"
ENV = dict(os.environ, OCAMLPATH=str(ROOT / "_build/install/default/lib"))
BASE = [str(ROCQ), "compile", "-q", "-boot",
        "-R", "../../_build/default/theories/Corelib", "Corelib",
        "-Q", ".", "TerminationStudy"]
LESSONS = ["L01_Baseline", "L02_Obligations", "L03_Accessibility", "L04_Admission"]


def run(args, log):
    result = subprocess.run(args, cwd=STUDY, env=ENV, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    log.write("$ " + shlex.join(args) + "\n")
    log.write(result.stdout)
    log.write(f"\n[exit {result.returncode}]\n\n")
    log.flush()
    if result.returncode:
        raise SystemExit(f"Failed; inspect {log.name}\n{result.stdout}")


def main():
    if not ROCQ.is_file():
        raise SystemExit(f"Build this checkout first; executable missing: {ROCQ}")
    LOGS.mkdir(exist_ok=True)
    baseline = STUDY / "Euclid.v"
    before = hashlib.sha256(baseline.read_bytes()).hexdigest()
    with (LOGS / "environment.log").open("w") as log:
        log.write(f"UTC: {datetime.now(timezone.utc).isoformat()}\n")
        log.write(f"cwd: {STUDY}\nRocq source: {ROOT}\nOCAMLPATH={ENV['OCAMLPATH']}\n")
        log.write(f"Euclid.v SHA256: {before}\n\n")
        run(["git", "-C", str(ROOT), "rev-parse", "HEAD"], log)
        run(["git", "-C", str(ROOT), "diff", "--stat", "HEAD"], log)
        run([str(ROCQ), "--version"], log)
        run([str(ROCQ), "compile", "-config"], log)
        config = ROOT / "_build/default/config/coq_config.ml"
        if config.is_file():
            log.write("Generated build configuration:\n" + config.read_text())
    with (LOGS / "baseline.log").open("w") as log:
        run(BASE + ["Euclid.v"], log)
    print("PASS Euclid.v", flush=True)
    for lesson in LESSONS:
        with (LOGS / f"{lesson}.log").open("w") as log:
            # In this checkout, -test-mode retains Fail diagnostics even
            # during the compiler's silent interpretation of commands.
            run(BASE + ["-test-mode", f"{lesson}.v"], log)
        print(f"PASS {lesson}.v", flush=True)
    after = hashlib.sha256(baseline.read_bytes()).hexdigest()
    if before != after:
        raise SystemExit("The baseline source changed during this run.")
    print(f"Baseline source unchanged. Logs: {LOGS}")


if __name__ == "__main__":
    main()
