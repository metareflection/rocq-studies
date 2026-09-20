(** Lesson 4 -- What was actually installed? (About 20 minutes.)

    Read after L03_Accessibility.v. This closes the Phase 2 walkthrough.
    Source paths below are relative to the Rocq checkout; README.md has
    the source map with line references and the recorded commit.
*)

From Corelib Require Import Init.Nat Program.Wf.
From TerminationStudy Require Import L02_Obligations L03_Accessibility.

Set Guard Checking.
Set Universe Checking.

(** The public wrapper only packs arguments for the generated function.
    This is a checked equality for arbitrary inputs, by conversion. *)
Print euclid_trace.
Example wrapper_is_generated_function (a b : nat) :
  euclid_trace a b = euclid_trace_func (pack a b).
Proof. reflexivity. Qed.

(** Inspect the artifact and its evidence. In [euclid_trace_func], find
    the application of [Fix_sub], the reference to obligation 4, and
    the two calls carrying obligations 1 and 2. Obligation 3 belongs
    to the elaborated match. The full output stays in this lesson's log. *)
Print euclid_trace_func.
(* Generated obligations require qualification after importing a module. *)
Check L02_Obligations.euclid_trace_func_obligation_1.
Check L02_Obligations.euclid_trace_func_obligation_2.
Check L02_Obligations.euclid_trace_func_obligation_3.
Check L02_Obligations.euclid_trace_func_obligation_4.

Example installed_examples :
  euclid_trace 48 18 = 6 /\ euclid_trace 18 48 = 6 /\
  euclid_trace 0 5 = 5 /\ euclid_trace 5 0 = 5.
Proof. repeat split; reflexivity. Qed.

Print Assumptions euclid_trace.
Print Assumptions euclid_trace_func.
Print Assumptions L02_Obligations.euclid_trace_func_obligation_1.
Print Assumptions L02_Obligations.euclid_trace_func_obligation_4.
Print Assumptions wrapper_is_generated_function.
Print Assumptions installed_examples.

(** Follow one call, end to end:

    source: euclid_trace (S a') (S b' - S a')
      -> a recursive-function argument with an extra decrease proof
      -> [exist] carrying [existT ...] and obligation 1's proof
      -> [Fix_sub] invokes [Fix_F_sub] with obligation 4's [Acc] proof
      -> [Acc_inv] uses that call's proof to select a child [Acc] proof
      -> [Fix_F_sub] recurses structurally on this child proof.

    The generated Euclid body is an ordinary term applying an existing
    recursor. [Fix_F_sub]'s recursive body was checked when Corelib was
    built; declaring Euclid does not reinstall that library definition.

    Implementation trail at commit
    67ab16a375d31812dc1dd788f92d446d7d6dcd45:

    - vernac/comFixpoint.ml: [encapsulate_Fix_sub], [build_wellfounded]
      build the relation, proof holes, recursor application, and wrapper.
    - vernac/declare.ml: [prepare_obligations], [declare_obligation],
      [obligation_substitution], [update_obls], [declare_definition]
      connect solved evidence to the proposed term and complete it.
    - vernac/declare.ml: [declare_constant] calls [Global.add_constant].
    - kernel/safe_typing.ml: [add_constant] checks a definition before
      adding its constant body to the environment.
    - kernel/typeops.ml: the [Fix] case calls [Inductive.check_fix];
      kernel/inductive.ml implements the guard check.

    Thus the proof-producing elaborator and tactics may change while
    their output remains subject to the existing kernel's checks.
    This observation does not justify changing the kernel or its rules.

    In the study's vocabulary:
    substrate = the existing core theory and environment;
    proposer = source author plus elaboration/proof-producing tools;
    evidence = the typed decrease and well-foundedness proof terms;
    gate = kernel checking of the resulting declarations, with guards
           and universe checking enabled;
    admission policy = add definitions accepted under those core rules;
    reflective depth = construct terms in the existing theory.

    We have not added native reduction rules. We have not proved a
    general guarantee about all future admission histories. Changing
    conversion or the gate itself requires a different argument.
*)

(** Stop for discussion here, as requested in study_plan.md.

    Explain the trace using [right_call] and [Fix_F_sub], then ask:
    what evidence must remain transparent for this function to compute?
    That is an open experimental question for Phase 3.

    Later checkpoints are planned in README.md: controlled changes,
    the scope of the admission discipline, then native rewrite rules.
    This import shows how we use the saved lesson; it is not a claim
    that normal [Require Import] independently rechecks every proof.
*)
