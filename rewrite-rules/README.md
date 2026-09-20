# Rewrite rules: a Rocq walkthrough

Start with [L01_Conversion.v](L01_Conversion.v), then visit the five files in order. Each contains explanations, predictions, executable commands, and a checkpoint. Allow about two hours across several sittings. You need basic Rocq proofs and induction; native rewrite rules and confluence are introduced here.

This is the first installment of the [study plan](study_plan.md). The running question is: **what changes when Rocq accepts a new computation rule, and what would justify that extension?** The lessons are self-contained apart from Corelib and the surrounding built Rocq checkout. The termination study is useful background but is not a dependency. All hands-on work is in Rocq.

| Order | Runnable lesson | Learning outcome |
| --- | --- | --- |
| 1 · 25 min | [Conversion](L01_Conversion.v) | Distinguish proving an equation from making it compute; use native rules to align dependent types without a transport. |
| 2 · 20 min | [Patterns](L02_Patterns.v) | Explain symbol heads, rigid patterns, linear holes, and incomplete rule coverage through accepted and rejected examples. |
| 3 · 25 min | [Admission](L03_Admission.v) | Follow rule data from elaboration to registration and kernel reduction; use it from an importing client. |
| 4 · 20 min | [Boundaries](L04_Boundaries.v) | Separate compilation success from confluence, subject reduction, termination, and consistency. |
| 5 · 35 min | [Triangle](L05_Triangle.v) | Prove how a triangle witness for parallel reduction yields confluence, and identify the premises needed to apply it. |

Read each comment before executing the command below it. Hide the indicated proofs and reconstruct them when you want an exercise. After Lesson 5, explain the admission path and the three premises of `confluence_via_triangle` before proceeding to the later paper and artifact visits.

## Run and open the lessons

From this study folder:

```sh
python3 check.py
```

From the repository root, use `python3 rewrite-rules/check.py`. The script selects the surrounding checkout's compiler and Corelib, records its version, source commit, flags and lesson hashes in [environment.log](logs/environment.log), and saves each lesson's output in [logs/](logs/). `-test-mode` retains expected-failure diagnostics. Each compilation has a 30-second timeout.

Lessons 1–4 use `-allow-rewrite-rules`. Lesson 5 is checked without that flag and imports no native-rule lesson. Lesson 3 imports Lesson 1, so build before opening it. No lesson imports Lesson 4: its intentionally bad rules are only for observing the admission boundary, and its compiled module should not be used as a proof library. Each file is compiled in a separate process. Guard and universe checks remain enabled.

Open `rewrite-rules/` as the editor project. [_CoqProject](_CoqProject) supplies the `RewriteStudy` namespace, Corelib mapping, and native-rule opt-in. The repository must sit directly inside a built Rocq source checkout; its own directory name does not matter. Select this checkout's prover and give the editor its library environment. Relative to this folder:

```text
Prover:    ../../_build/install/default/bin/coqtop
OCAMLPATH: ../../_build/install/default/lib
```

The project file does not choose the executable or set `OCAMLPATH`. Its opt-in applies to editor sessions for all five files; the build deliberately checks Lesson 5 with the stricter command. A terminal session for the native lessons can be started here with:

```sh
OCAMLPATH="$PWD/../../_build/install/default/lib" \
  ../../_build/install/default/bin/rocq repl -q -boot \
  -R ../../_build/default/theories/Corelib Corelib \
  -Q . RewriteStudy -allow-rewrite-rules
```

Use the ordinary reductions shown in the lessons. This checkout disables the VM and native reduction machines when rewrite rules are enabled; `vm_compute` and `native_compute` are not substitutes for these experiments. See the matching [manual source](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/doc/sphinx/addendum/rewrite-rules.rst#L173).

## What was observed

All five lessons compiled on 2026-09-19 (America/New_York; logs use UTC) with **Rocq 9.4+alpha, OCaml 5.4.1**, at source commit **`67ab16a375d31812dc1dd788f92d446d7d6dcd45`**. The build log records the surrounding checkout's tracked diff and configuration. These are observations of that checkout, not a promise about every released version.

| Experiment | Result | Evidence |
| --- | --- | --- |
| Ordinary `n + 0` | `eq_refl` fails even after an equality theorem has been proved. | [Lesson 1 log](logs/L01_Conversion.log) |
| Native `pplus n 0` | `eq_refl` succeeds; a value of `P (pplus n 0)` can be returned directly at `P n`. | Same log; inspect the printed bodies. |
| Invalid rule patterns | Definition/constructor heads, a repeated named hole, an unbound replacement hole, an application-headed hole, and declaration inside a section are rejected. | [Lesson 2 log](logs/L02_Patterns.log) |
| Saved native rules | An importing client uses them for conversion; the block name is not an equality-proof constant accessible through `Check`. | [Lesson 3 log](logs/L03_Admission.log) |
| Two rules `forked => 0` and `forked => 1` | The nonconfluent block is accepted; this checkout's `cbn` returns `1`. Choosing one branch does not join the two branches of the declared relation. | [Lesson 4 log](logs/L04_Boundaries.log) |
| A symbol of type `nat` rewritten to `true` | The rule is accepted with `rewrite-rules-break-SR`; the reduct itself is rejected at type `nat`. | Same log. |
| Abstract confluence proof | The theorem compiles without native rules and has closed assumptions. Its relation, witness, and bridge conditions remain explicit parameters/premises. | [Lesson 5 log](logs/L05_Triangle.log) |

In Lesson 4, `Eval` displays `true : nat` because it retains the input's type; it has not independently checked the displayed reduct at that type. In the positive native examples, `Print Assumptions` reports `pplus` as an axiom dependency and reports the rewrite theory flag. These reports do not certify the extended theory's metaproperties.

## Follow the implementation

Follow one rule, `pplus ?n 0 => ?n`, through the entry points below. Links are pinned to the tested source commit.

| Stage | Source entry point | What to inspect |
| --- | --- | --- |
| Declare a symbol | [vernac/comRewriteRule.ml](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/vernac/comRewriteRule.ml#L55) | The `SymbolEntry` passed to declaration. |
| Interpret a rule | [interp_rule](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/vernac/comRewriteRule.ml#L385) | Pattern elaboration; `safe_pattern_of_constr`; symbol-head and hole checks. |
| Attempt replacement typing | [Warning and fallback](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/vernac/comRewriteRule.ml#L484) | On expected-type failure, warn and retry without that expected type. Universe-constraint failures also warn. |
| Submit the rule data | [do_rules](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/vernac/comRewriteRule.ml#L562), [Global.add_rewrite_rules](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/library/global.ml#L103) | The opt-in check and handoff to safe typing. |
| Add an environment field | [Safe_typing.add_rewrite_rules](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/kernel/safe_typing.ml#L1318), [add_field dispatch](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/kernel/safe_typing.ml#L844) | Section rejection and insertion of an `SFBrules` field. |
| Store rules under their symbol | [Environ.add_rewrite_rules](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/kernel/environ.ml#L325) | The symbol-to-rules map; new rules are prepended. |
| Reduce a symbol | [knr's Symbol case](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/kernel/cClosure.ml#L2008), [match_symbol](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/kernel/cClosure.ml#L1967), [match_main](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/kernel/cClosure.ml#L1693) | Match, construct the hole/universe substitution, instantiate the replacement, continue reducing. |

The matching [manual's metaproperties section](https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/doc/sphinx/addendum/rewrite-rules.rst#L148) explicitly assigns responsibility for type preservation to the user and says confluence and termination are not checked. The implemented pattern checks and the warning do not amount to the paper's typing criterion. Promoting the warning to an error would still leave the check incomplete.

The declaration path stores patterns and replacements for native conversion. In the termination study, the proposed definition instead uses evidence to construct a term accepted under the existing recursion rules. That distinction identifies the question for a future certificate: what evidence justifies the *changed reduction relation*, including its interactions with the surrounding environment?

## From this walkthrough to the papers

[Lesson 5](L05_Triangle.v) proves a sufficient relational result. For ordinary reduction `R`, parallel reduction `P`, and a witness function `rho`, its premises are `R ⊆ P`, `P ⊆ R*`, and the triangle property for `P`. It does not instantiate those objects for Rocq or certify `pplus_rules`. It also does not prove type preservation, termination, or consistency.

The [study plan](study_plan.md) now uses the full **[Rewster 2026 journal article](https://link.springer.com/article/10.1007/s10817-026-09753-0)**, read in the [HAL v2 author manuscript](https://inria.hal.science/hal-05294553v2). It includes companion readings for each lesson and a route through the richer triangle criterion (§4.2, Definition 1 and Theorem 2), compatibility with α-cumulativity and irrelevance (§4.3), and dependent pattern typing (§§5–6, Definitions 2 and 3). The vector and later-extension examples are Examples 3 and 4 in this version.

*The Taming of the Rew* remains the introduction to the confluence method and the source of the historical MetaCoq artifact. Rewster §9 explicitly leaves formalization of its new criteria and proofs in MetaRocq to future work. Its implementation discussion also separates native rewrite support, the proposed typing checker, and the planned Rocq confluence checker. These distinctions guide the later study; the article is not evidence that this checkout enforces those criteria.

No additional repository is needed to run these lessons. The plan identifies the historical MetaCoq artifact and the Rocq typechecker PR for later, focused source comparisons.
