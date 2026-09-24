#!/usr/bin/env python3
"""Render every study's Rocq files as Alectryon webpages.

Goals and messages come from a VsRocq language server built against the
surrounding checkout, so the pages show this checkout's behaviour.

    python3 render.py --setup   # once: install Alectryon, build VsRocq
    python3 render.py           # render into site/
"""

import argparse
import html
import os
from pathlib import Path
import shutil
import subprocess
import sys


REPO = Path(__file__).resolve().parent
ROOT = REPO.parent
INSTALL = ROOT / "_build/install/default"
TOOLS = REPO / ".tools"
VENV = TOOLS / "venv"
VSROCQ = TOOLS / "vsrocq"
ALECTRYON = VENV / "bin/alectryon"
VSROCQTOP = VSROCQ / "language-server/_build/install/default/bin/vsrocqtop"
SITE = REPO / "site"

ALECTRYON_URL = "https://github.com/cpitclaudel/alectryon"
ALECTRYON_REV = "a6f19454a4a8756c51c6c4413544ad09d188e006"
VSROCQ_URL = "https://github.com/rocq-prover/vsrocq"
VSROCQ_REV = "d170eb99bce54e4c174a235b6cde521412e0f4c5"

# The checkout's binaries come first so VsRocq builds and runs against them.
ENV = dict(os.environ, OCAMLPATH=str(INSTALL / "lib"),
           PATH=os.pathsep.join([str(VSROCQTOP.parent), str(INSTALL / "bin"),
                                 os.environ.get("PATH", "")]))


def sh(args, **kwargs):
    print("$ " + " ".join(map(str, args)), flush=True)
    subprocess.run(args, check=True, env=ENV, **kwargs)


def setup():
    if not (INSTALL / "bin/rocq").is_file():
        raise SystemExit(f"Build the Rocq checkout first: {ROOT}")
    TOOLS.mkdir(exist_ok=True)
    if not VENV.is_dir():
        sh([sys.executable, "-m", "venv", VENV])
    sh([VENV / "bin/pip", "install", "-q", f"git+{ALECTRYON_URL}@{ALECTRYON_REV}"])
    if not VSROCQ.is_dir():
        sh(["git", "clone", "-q", VSROCQ_URL, VSROCQ])
    sh(["git", "-C", VSROCQ, "fetch", "-q", "origin", VSROCQ_REV])
    sh(["git", "-C", VSROCQ, "checkout", "-q", VSROCQ_REV])
    # The generated dune files record the Rocq version; regenerate them.
    sh(["git", "-C", VSROCQ, "clean", "-qfdX", "language-server"])
    # --root keeps dune from adopting the enclosing checkout as workspace.
    sh(["make", "-C", VSROCQ / "language-server",
        "dune=dune $(1) --root . --stop-on-first-error"])
    print(f"Ready: {VSROCQTOP}")


def studies():
    for project in sorted(REPO.glob("*/_CoqProject")):
        files = [line.strip() for line in project.read_text().splitlines()
                 if line.strip().endswith(".v")]
        yield project.parent, files


def render(selected):
    for tool in (ALECTRYON, VSROCQTOP):
        if not tool.is_file():
            raise SystemExit(f"Missing {tool}; run: python3 render.py --setup")
    index = []
    for study, files in studies():
        if selected and study.name not in selected:
            continue
        stale = [f for f in files if not (study / f).with_suffix(".vo").is_file()
                 or (study / f).with_suffix(".vo").stat().st_mtime
                 < (study / f).stat().st_mtime]
        if stale:
            raise SystemExit(f"Compile {study.name} first (stale: {', '.join(stale)}):"
                             f" python3 {study.name}/check.py")
        out = SITE / study.name
        out.mkdir(parents=True, exist_ok=True)
        # VsRocq reads the study's _CoqProject, so run from the study folder.
        sh([ALECTRYON, "--frontend", "coq", "--backend", "webpage",
            "--coq-driver", "vsrocq", "--output-directory", out, *files],
           cwd=study)
        index.append((study.name, files))
    write_index(index)
    print(f"Open {SITE / 'index.html'}")


def write_index(index):
    items = []
    for name, files in index:
        links = "".join(f'<li><a href="{html.escape(name)}/{html.escape(f)}.html">'
                        f"{html.escape(f)}</a></li>" for f in files)
        items.append(f"<h2>{html.escape(name)}</h2><ul>{links}</ul>")
    SITE.joinpath("index.html").write_text(
        "<!DOCTYPE html><meta charset='utf-8'><title>Rocq studies</title>"
        "<body style='font-family:sans-serif;max-width:40em;margin:2em auto'>"
        "<h1>Rocq studies</h1>" + "".join(items) + "</body>\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--setup", action="store_true",
                        help="install Alectryon and build VsRocq against this checkout")
    parser.add_argument("--clean", action="store_true", help="remove site/ first")
    parser.add_argument("studies", nargs="*", help="study folders to render (default: all)")
    args = parser.parse_args()
    if args.setup:
        setup()
        return
    if args.clean and SITE.is_dir():
        shutil.rmtree(SITE)
    render(set(args.studies))


if __name__ == "__main__":
    main()
