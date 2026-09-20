# rocq-studies

Runnable, annotated studies of Rocq's implementation and proof mechanisms. Each study combines small Rocq files, questions to work through, and notes connecting the examples to the implementation.

| Study | Start here | Focus |
| --- | --- | --- |
| [Termination](termination/README.md) | [Lesson 1](termination/L01_Baseline.v) | Follow a recursive call through termination obligations, accessibility proofs, and kernel admission. |
| [Rewrite rules](rewrite-rules/README.md) | [Lesson 1](rewrite-rules/L01_Conversion.v) | Extend conversion, trace native rule admission, and study the conditions behind confluence and type preservation. |

Each study has its own `_CoqProject`, namespace, and build script. This lets future studies choose the dependencies and compiler flags they need. Shared helpers can be introduced when multiple studies actually use them.

## Working with a Rocq source checkout

Place this repository directly inside a built Rocq source checkout. Its directory name can be `rocq-studies`, `my-studies`, or another name; the build scripts use its location. The current layout is:

```text
rocq/
├── _build/
└── rocq-studies/
    ├── README.md
    ├── termination/
    │   ├── _CoqProject
    │   ├── check.py
    │   ├── Euclid.v
    │   └── L01_Baseline.v … L04_Admission.v
    └── rewrite-rules/
        ├── _CoqProject
        ├── check.py
        └── L01_Conversion.v … L05_Triangle.v
```

From this repository's root, build the termination study with:

```sh
python3 termination/check.py
```

Build the rewrite-rule study with:

```sh
python3 rewrite-rules/check.py
```

Each script uses the surrounding checkout's compiler and Corelib, records its version and source commit, and writes results into that study's `logs/` directory. The [termination guide](termination/README.md) and [rewrite-rule guide](rewrite-rules/README.md) give editor setup, the reading order, and references pinned to the Rocq commit studied.
