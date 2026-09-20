#!/usr/bin/env python3
"""Compile the walkthrough with the surrounding Rocq source checkout."""

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
BASE = [str(ROCQ), "compile", "-q", "-boot", "-test-mode",
        "-R", "../../_build/default/theories/Corelib", "Corelib",
        "-Q", ".", "RewriteStudy"]
LESSONS = ["L01_Conversion", "L02_Patterns", "L03_Admission",
           "L04_Boundaries", "L05_Triangle"]


def run(args, log):
    log.write("$ " + shlex.join(args) + "\n")
    log.flush()
    try:
        result = subprocess.run(args, cwd=STUDY, env=ENV, text=True,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=30)
    except subprocess.TimeoutExpired as error:
        output = error.stdout or b""
        log.write(output.decode(errors="replace") if isinstance(output, bytes) else output)
        log.write("\n[timeout after 30 seconds]\n")
        raise SystemExit(f"Timed out; inspect {log.name}") from error
    log.write(result.stdout)
    log.write(f"\n[exit {result.returncode}]\n\n")
    log.flush()
    if result.returncode:
        raise SystemExit(f"Failed; inspect {log.name}\n{result.stdout}")


def main():
    if not ROCQ.is_file():
        raise SystemExit(f"Build the surrounding checkout first: missing {ROCQ}")
    LOGS.mkdir(exist_ok=True)
    with (LOGS / "environment.log").open("w") as log:
        log.write(f"UTC: {datetime.now(timezone.utc).isoformat()}\n")
        log.write(f"cwd: {STUDY}\nRocq source: {ROOT}\nOCAMLPATH={ENV['OCAMLPATH']}\n")
        run(["git", "-C", str(ROOT), "rev-parse", "HEAD"], log)
        run(["git", "-C", str(ROOT), "diff", "--stat", "HEAD"], log)
        run([str(ROCQ), "--version"], log)
        run([str(ROCQ), "compile", "-config"], log)
        for lesson in LESSONS:
            digest = hashlib.sha256((STUDY / f"{lesson}.v").read_bytes()).hexdigest()
            log.write(f"{lesson}.v SHA256: {digest}\n")
    for lesson in LESSONS:
        # The abstract theorem has no native rules and needs no opt-in.
        flags = [] if lesson == "L05_Triangle" else ["-allow-rewrite-rules"]
        with (LOGS / f"{lesson}.log").open("w") as log:
            run(BASE + flags + [f"{lesson}.v"], log)
        print(f"PASS {lesson}.v", flush=True)
    print(f"All five lessons compiled. Inspect expected failures/warnings in {LOGS}")


if __name__ == "__main__":
    main()
