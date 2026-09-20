# Study brief: Rocq termination as a model for checked rewrite-rule admission

## Purpose

Help me understand Rocq's existing termination machinery as a working instance of evidence-based admission, then use that understanding to investigate native rewrite-rule admission, especially confluence.

The purpose is not to invent a replacement for `Program Fixpoint`. An existing mechanism is worth studying precisely because it works. The eventual target is something useful for Rocq itself, not another toy reflective language implemented inside Rocq.

My reasonable-reflection framing distinguishes substrate, proposer, evidence, gate, admission policy, reflective depth, and guarantees across admitted histories. Use that vocabulary, but do not force the implementation to fit it. In particular, distinguish changing proof construction from changing an admission criterion or its trusted checker.

## Working constraints

Work in the current Rocq source checkout and record its commit, executable version, and build flags. Local source is authoritative for this experiment; report discrepancies with published documentation. Keep the study's examples and supporting proofs in this folder. Use [Euclid.v](Euclid.v) as the baseline and separate files for variants.

Keep guard and universe checking enabled. Do not add axioms, use `Admitted`/`Admit Obligations`, or use unchecked proof escapes. Keep the termination baseline independent of experimental rewrite-rule flags. Native rewrite experiments may use the documented opt-in flag, explicitly and in isolation; successful compilation is not evidence that the rule system is confluent, terminating, or type preserving.

Do not start a kernel modification, generic gate framework, toy interpreter, learned-heuristic project, or benchmark suite. This is a guided study, not an implementation sprint. Do not assume either novelty or redundancy before examining the actual mechanisms.

## Phase 1 — Reproduce the existing example

**Question:** What does the baseline demonstrate, and which layer rejects the plain definition?

Start with the subtraction-based Euclid example in [Euclid.v](Euclid.v). It has a plain `Fixpoint` expected to fail and a `Program Fixpoint` using the measure `a + b`, with all obligations proved using Corelib.

Run from this study folder with the surrounding checkout's compiler:

```sh
OCAMLPATH="$PWD/../../_build/install/default/lib" \
  ../../_build/install/default/bin/rocq compile -q -boot \
  -R ../../_build/default/theories/Corelib Corelib \
  -Q . TerminationStudy Euclid.v
```

Record the rejection, accepted definition, computed results, and `Print Assumptions` output. If necessary, use separate variants with explicit structural arguments to distinguish failure to infer a decreasing argument from rejection of a chosen one. Locate the source of the diagnostic rather than assuming it came directly from the kernel.

**Deliverable:** A short reproducibility note. Do not redo the arithmetic proofs or replace the algorithm merely to simplify the study.

## Phase 2 — Follow one recursive call all the way to admission

**Question:** How is the evidence connected to the exact definition that Rocq installs?

Inspect the pending obligations and `Preterm` before solving them, then inspect the completed definition and the relevant generated constants. The Program manual documents `Preterm` specifically for inspecting the term to be submitted after obligations are solved [R1].

Trace one Euclid recursive call through:

```text
source recursive call
    -> elaborated call with its decrease obligation
    -> well-founded recursion construction
    -> core recursive term and its structural argument
    -> declaration checking and installation
```

Find the actual definitions used by this checkout. Read `Acc`, `well_founded`, and the relevant well-founded recursor; `Corelib.Init.Wf` is a starting point, not a promise about the complete dependency path [R2]. Explain why the recursion in the final construction satisfies the core rules even though the original plain declaration did not.

Locate the relevant source functions for elaboration, obligation completion, declaration checking, and guardedness checking. Record paths, function names, line references, and the checkout commit. Distinguish proof-generating code from code trusted to check the result. Also establish when the definition becomes usable while obligations are pending.

**Deliverable:** One annotated trace of a recursive call, a compact dependency sketch, and a small source map. Keep full term dumps in logs rather than substituting them for an explanation.

## Phase 3 — Probe the boundary with controlled variants

**Question:** What is checked, what gets retained, and what participates in computation?

Run these separately; change one thing at a time.

1. **Bad recursive call.** In a copy, replace a recursive call with a call on the same arguments. Inspect the resulting decrease obligation and explain its impossibility. A failed tactic alone is not proof of impossibility. Use expected-failure tests or leave the negative experiment outside the successful build; never admit it.
2. **Different justification.** Keep the executable algorithm fixed while changing a proof script, and then, separately, its measure. Identify which generated terms change. Do not claim the resulting definitions are definitionally or propositionally equal without establishing the relevant claim.
3. **Evidence opacity.** Separately vary transparency of a decrease proof and of the well-foundedness proof. Observe declaration acceptance, ordinary reduction, and small equality goals. Do not assume all evidence is erased or that all opaque evidence blocks computation; explain the observed dependencies.
4. **Saved evidence and later use.** Import the compiled module from a separate client, use the definition, and inspect its assumptions. Distinguish importing compiled evidence from replaying source proof scripts. Check whether a separate library-checking command is available in this checkout; do not describe normal importing as independent rechecking without verifying that behavior.

**Deliverable:** A small experiment table: change, question, observed outcome, explanation, and supporting code/source location. Report untested expectations as expectations.

## Phase 4 — Extract the admission discipline and its limits

**Question:** In exactly what sense is this mechanism robust to future changes?

Write a one-page account identifying the proposed addition, supplied evidence, installed artifact, admission checks, protected assumptions, and permitted future changes. Use the actual findings rather than a generic gate diagram.

Distinguish:

- changing a tactic or elaboration strategy;
- adding a checked definition to the environment;
- editing an existing definition or specification and rebuilding;
- changing native reduction rules or trusted kernel code.

Explain why these are different transitions. Identify which are covered by the baseline mechanism and which require another argument. Do not infer a general future-proofing theorem from a handful of successful tests. State which claims come from an experiment, implementation inspection, documentation, or an existing metatheoretical result.

In particular: did the supplied proof replace Rocq's structural guard check, or enable construction of a term that passes it? What exactly can evolve without requiring trust in a new proof-producing implementation? What has not been shown about replacing the gate itself?

**Deliverable:** A precise account of the successful existing pattern, with explicit scope and trust assumptions. No new toy formalization is required.

## Phase 5 — Transfer the questions to native rewrite rules

**Question:** What would the analogue of this evidence-to-admission path be for changing Rocq's computation rules?

Read the matching rewrite-rule manual and the Rewster paper [R4, R5]. Reproduce one small documented native example, such as parallel addition, in an isolated file. Demonstrate what subsequent kernel conversion can do with it; do not substitute an equality-rewriting tactic for native computation.

Inspect the actual path from rule declaration to registration and use during reduction. Record which checks the checkout implements, which conditions the paper establishes, and which properties remain obligations of the user. Do not assume published criteria are already implemented, or that an implementation absent from this checkout is absent everywhere.

Compare the two mechanisms along these axes: object admitted, form of evidence, evidence-to-artifact connection, trusted checking, effect on conversion, dependence on the surrounding environment, and behavior under subsequent extensions. Keep confluence, type preservation, termination, and consistency separate.

Focus on the central contrast: elaborating a recursive definition into the existing core versus admitting new native reduction rules [R1, R4]. Study how Rewster handles interactions with existing and later rules; do not invent an interaction example when the paper already supplies one. The 2026 paper explicitly develops modular confluence and typing criteria, so examine those before proposing another gate [R5].

If the 2026 full text is unavailable, use the open ITP 2024 paper provisionally and label that limitation. Do not attribute unread results to the newer paper.

**Deliverable:** A one-page note for discussion with Eric: what termination teaches us, what does not transfer automatically, and the smallest potentially useful experiment on native Rocq rewrite admission. Include specific questions about the existing criteria, implementation plans, and where explicit certificates would add value. Do not assume a new contribution has already been identified.

## How to work with me

Proceed one phase at a time. At each checkpoint, show the runnable artifact, explain the main mechanism in a few paragraphs, identify the next uncertainty, and pause. The goal is that I understand the admission path, not merely that a collection of files compiles.

Keep one study note plus the small Rocq experiments and logs. Attach source locations to implementation claims and paper sections/theorem numbers to theoretical claims. Never report an unexecuted experiment as successful.

**Start now with Phase 1. If the baseline reproduces immediately, prepare the Phase 2 walkthrough of one recursive call, then stop for discussion.**

## Starting references

Use versions matching the checkout where possible.

- [R1] Rocq 9.2 manual, Program: https://rocq-prover.org/doc/V9.2.0/refman/addendum/program.html
- [R2] Rocq 9.2 Corelib, Init.Wf: https://rocq-prover.org/doc/V9.2.0/corelib/Corelib.Init.Wf.html
- [R3] Rocq 9.2 manual, Inductive types and recursive functions: https://rocq-prover.org/doc/V9.2.0/refman/language/core/inductive.html
- [R4] Rocq 9.2 manual, User-defined rewrite rules: https://rocq-prover.org/doc/V9.2.0/refman/addendum/rewrite-rules.html
- [R5] Leray, Gilbert, Tabareau, Winterhalter, The Rewster: Type Preserving Rewrite Rules for the Rocq Prover, JAR 2026: https://link.springer.com/article/10.1007/s10817-026-09753-0
- [R6] ITP 2024 version: https://doi.org/10.4230/LIPIcs.ITP.2024.26
- Framing: Nada Amin, slides-lics.pdf, especially slides 17, 20, 26, 33, and 41–42. Use the supplied 44-slide deck rather than an earlier draft. Repository location: https://github.com/namin/reasonable-reflection/blob/main/slides-lics.pdf
