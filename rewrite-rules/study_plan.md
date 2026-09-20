# Study plan: native rewrite rules and their admission

Understand Rocq's native rewrite mechanism, the metatheory that could justify extensions, and where a proposed certificate would have to connect to the implemented system. Work from concrete declarations toward confluence and dependent typing before considering a contribution.

All executable work is in **Rocq**. Agda's role in the papers is background reading; installing or running its confluence checker is outside this first study. The runnable lessons and their evidence are indexed in [README.md](README.md). This folder has its own project, namespace, and build command; it does not depend on the termination study.

The main Rocq paper is now **[Rewster 2026][R26]**, read in full from the author manuscript **[HAL hal-05294553v2][HAL]**, deposited 13 April 2026. Page references below use its printed article pages; the PDF has an extra HAL cover, so article page 16 is PDF page 17. **[Taming][T]** supplies the earlier confluence argument and formal artifact; **[Rewster 2024][R24]** is a historical comparison.

## Learning outcomes

By the end of the complete study, you should be able to:

- Explain native conversion using an example that ordinary propositional rewriting does not make compute.
- Trace a rule from source syntax to its stored pattern/replacement and use in kernel reduction.
- State confluence, subject reduction, termination, and consistency separately, including the premises of results connecting them.
- Explain the triangle argument, its sufficient nature, and the restrictions needed for modular extension.
- Explain why dependent pattern typing, sort polymorphism, and future rule additions complicate a type-preservation check.
- Distinguish a native Rocq experiment, a theorem about formalized syntax, an implemented checker, and evidence that a particular checker accepts only suitable extensions.
- Formulate one concrete question about admission evidence without assuming that an unsolved research problem or a new contribution has already been identified.

## Phase 1 — Native behavior and a first confluence argument

**Available now:** [Conversion](L01_Conversion.v), [Patterns](L02_Patterns.v), [Admission](L03_Admission.v), [Boundaries](L04_Boundaries.v), [Triangle](L05_Triangle.v). Visit them in that order. Their compilation and diagnostics have been recorded; the paper experiments in later phases have not been executed.

The first four lessons distinguish actual admission checks from properties that remain the user's responsibility. The fifth proves the abstract implication from a parallel triangle witness to confluence. It is a small mathematical bridge, not a second implementation of a language or a native rule checker.

**Checkpoint:** Explain how `pplus n 0` becomes `n`, where the rules are stored, why a type-preservation warning can coexist with successful compilation, and what would be needed to apply `confluence_via_triangle` to this actual reduction relation.

**Deliverable:** The five runnable files, source map, observed-result table, and logs in this folder. Stop for discussion after this walkthrough.

Use these short article visits alongside the lessons; the later phases develop the proofs in detail:

| Lesson | Rewster 2026 companion reading | Connection |
| --- | --- | --- |
| 1 | §1, p. 2 | Parallel addition changes definitional equality. |
| 2 | §§3.1–3.2, pp. 10–12 | Rigid patterns and matching explain the syntactic restrictions. |
| 3 | §7, pp. 25–26 | Separate the installed native mechanism from the proposed typing checker. |
| 4 | §1 Examples 1–4, pp. 3–5 | More subtle failures arise from universes, dependent indices, and later rules. |
| 5 | §§4.1–4.2, pp. 12–16 | The abstract triangle proof precedes the criterion for actual patterns. |

## Phase 2 — Overlaps, parallel reduction, and modular confluence

**Read:** Taming §§3–4 for motivation, then Rewster 2026 §§4.1–4.3. Before the journal proof, read §2.1 and §§3.1–3.2 for its richer syntax and matching operation. Return to Taming §§6.1–6.3 and §7.1 for comparison.

1. Draw the competing reductions of parallel addition at `(S m) + (S n)`. Reconstruct Taming's chosen `rho` and explain why the ordinary join exists while that particular triangle check fails. Locate the extra parallel rule used in its Examples 4.3 and 7.5. Keep failure of a sufficient criterion separate from a proof of nonconfluence.
2. Identify the role of parallel reduction in `R ⊆ P ⊆ R*`. Explain why the induction in Lesson 5 does not require termination of `R`. Contrast a diamond with local confluence; do not use local confluence alone to conclude confluence.
3. Reconstruct Rewster's **Definition 1 and Theorem 2** (§4.2, p. 16). The criterion requires closure under pattern overlaps with the specified rule priority, and a parallel-step condition on the first matching rule's pattern term. Follow how these conditions make the decomposition in the proof possible. Distinguish the structural witness `rho`, the criterion on the rules, and the triangle property that follows.
4. Compare this with Taming Definition 6.3, including its arity/stack condition, and with Theorem 7.3 and Algorithm 7.4. Their scope and presentation differ; the older criterion cannot simply be relabeled as the journal criterion for the richer patterns.
5. Read Rewster §4.3 (pp. 16–17): why must reduction also interact correctly with α-cumulativity and `SProp` irrelevance? Locate the relevance restriction on subpatterns. Lesson 5 proves the relational confluence argument, not these additional compatibility facts needed for the account of conversion.
6. Use Taming §4.2's nonlinear counterexample and Theorem 6.7 to explain the hypotheses of its modularity result. Then consider a new rule in the journal setting: which overlap and priority conditions can it affect? Neither fresh head names nor Rocq's syntactic grouping into a `Rewrite Rule` block automatically supplies those arguments.

**Planned artifact:** `L06_Overlaps.v`, a small worked visit to the same native addition rules with paper diagrams and predictions in comments. Mathematical claims beyond the executed equalities must point to a proof or a paper result. Do not replace the study with a generic interpreter or confluence framework.

**Checkpoint:** What exact information about a candidate extension and the existing environment would a triangle check or a supplied witness need? Which restrictions make the answer stable under later admitted blocks? Keep this question separate from the local postulates with instantiations proposed as “modular rewrite rules” in Rewster §9.

## Phase 3 — Dependent typing and later extensions

**Read:** Rewster 2026 §1 Examples 1–4 (pp. 3–5), §§2.1–2.3, §§5.1–5.2 (pp. 17–23), and §6 (pp. 23–25). Definition 2 gives the first typing criterion; Definition 3 adds extracted equalities. In this version, the vector example is **Example 3** and the `Box` interaction is **Example 4**.

1. Start with Examples 1 and 2: why is finding one common type for the two sides insufficient, and why must the types of the pattern variables be determined carefully?
2. Read the bidirectional rules in Figure 8. Identify the checking mode of `PatVar` and the virtual universe annotations. Explain the conservative bounds `↑[s]ℓ` and `ℓ ∗[s] ℓ'` when a sort variable may be predicative or impredicative. A rule's data includes its universe and metavariable contexts, not just two terms.
3. Follow §5.2's anti-substitution argument: from a well-typed term matching a pattern, recover a well-typed matching substitution and a cumulative bound on the instantiated pattern type. Its preservation statement quantifies over **all extended environments `Σ ⊇ Σ₀`** and all local contexts under the paper's ambient assumptions; identify the weakening and conversion properties used in the proof. The general subject-reduction argument also relies on §4.3's properties of type formers.
4. Contrast Example 3's vector indices with Example 4's `Box`/`I`/`C`/`D` interaction. Which equality is justified by an injective type former, and which apparent injectivity can disappear when a later rule is added? Use these supplied examples before designing another.
5. Read Figure 9 and Definition 3. The `Failsafe` rule extracts no equality at a symbol head: explain how that prevents Example 4. Accepting a comparison with an empty set of extracted equalities is not permission to assert arbitrary equalities.

**Planned artifact:** `L07_DependentPatterns.v`, with an isolated reproduction, diagnostics, and an explanation of the bidirectional criterion. Compare the current checkout with the criterion; attribute historical implementation statements to their version. Do not infer subject reduction from successful elaboration or from matching universe constraints alone.

**Checkpoint:** Explain why pattern typing must anticipate more substitutions and extensions than the single term currently being elaborated. Identify the place in the proposed checking procedure that prevents the counterexample.

## Phase 4 — Where the metatheoretic proof lives

**Read:** Rewster 2026 §§2.2–2.3 and §9, then Taming §§5–6 and the [historical MetaCoq artifact][A]. Rewster §9 explicitly leaves formalizing its criteria and proofs in MetaRocq to future work, with higher-order metavariable support as a prerequisite. Its mathematical presentation in PCUIC is not a claim that the new results have already been checked in MetaRocq.

The historical artifact belongs to **Taming 2021**, with a different scope. Start by reading source through the repository; a build is a separate, optional experiment. It identifies Coq 8.11.0 and Equations 1.2.1+8.11 as its build dependencies and should have its own toolchain if rebuilt. All paper landmark numbers in the following table refer to Taming.

| Paper landmark | Artifact entry point to inspect | Question |
| --- | --- | --- |
| Triangle and modularity | `pcuic/theories/PCUICParallelReductionConfluence.v` | What is required by `confluenv`? Locate the corresponding witness and extension hypotheses. |
| Confluence, Theorem 6.4 | `pcuic/theories/PCUICConfluence.v`, `red_confluence` | Which environment and confluence premises does the theorem take? |
| Subject reduction, Lemma 6.6 | `pcuic/theories/PCUICSR.v`, `subject_reduction` | Where is `type_preserving` still an assumption about the rewrite rules? |
| Assumptions | Artifact README and `Print Assumptions` when built | Separate declared hypotheses, guard abstractions, and logical axioms. |

Taming Lemma 6.8 (consistency) and Theorem 6.10 (conditional correctness of conversion) are explicitly marked **not formalized** in that paper. Study their stated premises. In particular, the consistency argument uses instantiations of symbols and proofs of their equations in an empty rewriting signature; confluence alone is not that argument. Subject reduction also uses validity/type preservation of the rules, alongside the confluence-based properties of conversion.

Include two scope distinctions from the journal article in the audit. Section 2.2 keeps the fixpoint guard condition abstract and omits the constructor guard on fixpoint *unfolding*. Section 2.3 presents proof irrelevance illustratively and explains the limits of the underlying MetaRocq account; §4.3 gives the compatibility argument for rewrite rules. Neither is an instruction to disable checks in our native experiments or an established correspondence between the full paper model and this checkout.

**Planned artifact:** `L08_ArtifactVisit.md`, a short theorem-to-source and hypothesis map. If a build is useful, record the exact commit, dependencies, commands, and assumption outputs. A theorem about an explicit representation of syntax is not automatically connected to the native declaration API.

**Checkpoint:** What has been formalized, what remains a premise, and what would connect a certificate checked in Rocq to a native rule registered by this implementation?

## Phase 5 — One concrete admission question

Compare the observed mechanism with the [termination study](../termination/README.md), reading its explanation if you have not worked through it. Distinguish changes in proof construction from changes to the trusted acceptance criterion or reduction semantics.

Write one page identifying the proposed rule block, its exact surrounding environment, the evidence being offered, the check consuming it, and the allowed later extensions. Consider a checker that searches for a witness, a supplied witness checked by a fixed procedure, and a proof about a formalized relation. Name the missing connection to native rules in each case. A witness does not justify a different rule block merely because they look similar.

The abstract triangle proof is one sufficient pattern for confluence evidence. It is not a complete analogue of `Acc`, nor an implementation of certificate-based native admission. Examine existing criteria and implementation work before proposing a new interface.

Rewster §9 already discusses more permissive confluence methods and local postulates instantiated by terms and propositional equalities. These are relevant starting points for an admission proposal. Distinguish preserving typing under environment extension (§5.2), maintaining the triangle criterion when rules interact (§4.2), and the proposed instantiation mechanism (§9).

**Possible next experiment:** compare the same small cases against the proposed Rocq rule typechecker in [PR #19290][PR]. Rewster §7 reports that this checker is implemented in the PR but not yet integrated; §9 separately lists implementing the Rocq confluence checker as future work. Treat those as the article's dated status, then resolve the current PR state and define the exact comparison before using a separate pinned checkout. Record observed acceptance, warnings, and errors; do not turn compiler behavior into a general soundness claim.

**Deliverable:** A focused discussion note: what evidence is already supported, what the papers establish under which assumptions, what is missing in this checkout, and one experiment that could resolve a specific uncertainty. No kernel patch, new admission framework, or claim of novelty is required.

## Source and checkout policy

The first walkthrough needs only the current Rocq checkout and Corelib. Additional repositories are optional follow-up work:

| Candidate | Purpose | Before checking it out |
| --- | --- | --- |
| [Taming artifact, `rewrite-rules` branch][A] | Inspect formal definitions and theorem hypotheses. | Resolve and record the branch's commit; read its toolchain requirements. |
| [Rocq PR #19290][PR] | Compare the proposed typechecker with the tested mainline behavior. | Resolve the current PR head and status; identify the relevant tests and build requirements. |

There is no Rewster formalization checkout assigned by this plan: the journal article explicitly describes that formalization as future work. Do not assume the historical Taming artifact or a current MetaRocq checkout proves the journal criteria.

Keep external checkouts and their builds outside this public study repository. Use separate directories and toolchains where required. The first walkthrough does not require fetching branches, changing Git configuration, or installing an Agda toolchain.

Keep runnable studies self-contained, preserve guard and universe checking, and use explicit native opt-in only for native experiments. Intentional ill-typed/nonconfluent cases belong in independent files with their purpose stated. Do not add admitted proofs or unchecked proof escapes. Keep actual results separate from planned visits, and pause at each learning checkpoint before expanding the scope.

## Reading references and version status

- **[T]** Cockx, Tabareau, Winterhalter. [The Taming of the Rew: A Type Theory with Computational Assumptions][T], POPL 2021, article 60. Full-text sections cited above were studied. Its Agda examples can be read mathematically without running Agda.
- **[R26]** Leray, Gilbert, Tabareau, Winterhalter. [The Rewster: Type Preserving Rewrite Rules for the Rocq Prover][R26], JAR 2026, volume 70, article 7. Full text studied in the [HAL v2 author manuscript][HAL], deposited 13 April 2026, with 30 article pages plus the HAL cover. This is the main source for the Rocq-specific theory, examples, and theorem numbering above. Its introduction identifies sort polymorphism and the more detailed confluence development as additions to the conference version.
- **[R24]** The same authors. [The Rewster: Type Preserving Rewrite Rules for the Coq Proof Assistant][R24], ITP 2024, article 26. Open full text retained for historical comparison. Its `Box` Example 3 became Example 4 in the journal version; its Definitions 4 and 5 became Definitions 2 and 3, respectively.
- **Native implementation:** [Matching manual source][M] and the commit-pinned source map in [README.md](README.md). The [9.2 rendered manual](https://rocq-prover.org/doc/V9.2.0/refman/addendum/rewrite-rules.html) is a convenient secondary view; the tested checkout is 9.4+alpha.
- **Implementation history:** [PR #18038](https://github.com/rocq-prover/rocq/pull/18038) and [PR #19290][PR], discussed in Rewster 2026 §7. The latter's discussion was inspected, but its branch was not built. The tested checkout's behavior is established separately by the examples, logs, and local source map.

[T]: https://doi.org/10.1145/3434341
[R24]: https://doi.org/10.4230/LIPIcs.ITP.2024.26
[R26]: https://link.springer.com/article/10.1007/s10817-026-09753-0
[HAL]: https://inria.hal.science/hal-05294553v2
[A]: https://github.com/TheoWinterhalter/template-coq/tree/rewrite-rules
[PR]: https://github.com/rocq-prover/rocq/pull/19290
[M]: https://github.com/rocq-prover/rocq/blob/67ab16a375d31812dc1dd788f92d446d7d6dcd45/doc/sphinx/addendum/rewrite-rules.rst
