(** Lesson 2 -- Watch a definition become available. (About 30 minutes.)

    Read after L01_Baseline.v. This is the same Euclid algorithm and
    measure, with a fresh name and inspection commands inserted.
    Arithmetic evidence is defined in Euclid.v. This begins Phase 2.
*)

From Corelib Require Import Init.Nat Program.Wf.
From TerminationStudy Require Import Euclid.

Set Guard Checking.
Set Universe Checking.

(** Pause automatic proof search so every obligation stays visible. *)
#[local] Obligation Tactic := idtac.

Program Fixpoint euclid_trace (a b : nat) {measure (a + b)} : nat :=
  match a, b with
  | 0, _ => b
  | _, 0 => a
  | S a', S b' =>
      if Nat.leb (S a') (S b')
      then euclid_trace (S a') (S b' - S a')
      else euclid_trace (S a' - S b') (S b')
  end.

(** Before solving anything, inspect the four pending propositions and
    the proposed term. The name with [_func] is Program's internal
    function on a packed pair of arguments. Search the Preterm output
    for [Fix_sub], [existT], [exist], and [_obligation_1].

    These commands inspect Program's pending state; they do not install
    an incomplete function in the global environment. *)
Obligations of euclid_trace_func.
Preterm of euclid_trace_func.
Fail Check euclid_trace.
Fail Check euclid_trace_func.

(** Follow the [then] call. Its local recursive function now takes an
    extra proof that the new sum is smaller than the CURRENT sum.
    Match equalities identify the current [a,b] with [S a',S b'].
    Execute [Show] before and after [subst] and read the change. *)
Next Obligation.
  intros a b recurse a' b' Ha Hb.
  Show.
  subst a b.
  Show.
  apply TerminationFacts.subtract_right_decreases.
Defined.

(** One evidence constant is now installed, but the function is not. *)
Check euclid_trace_func_obligation_1.
Print euclid_trace_func_obligation_1.
Fail Check euclid_trace.
Obligations of euclid_trace_func.

Next Obligation.
  intros a b recurse a' b' Ha Hb. subst a b.
  apply TerminationFacts.subtract_left_decreases.
Defined.

(** This third goal is match bookkeeping, not another recursive call. *)
Next Obligation.
  Show.
  intros; intuition discriminate.
Defined.

(** Both decreases are proved, but the relation still needs a proof of
    well-foundedness. The public function remains unavailable. *)
Fail Check euclid_trace.
Fail Check euclid_trace_func.
Obligations of euclid_trace_func.
Preterm of euclid_trace_func.

Next Obligation.
  Show.
  apply measure_wf. exact TerminationFacts.nat_lt_wf.
Defined.

(** Crossing this last [Defined] completes the definition and its
    two-argument wrapper. No extra admission command is needed. *)
Check euclid_trace_func.
Check euclid_trace.
Print euclid_trace.
Print euclid_trace_func.
Print euclid_trace_func_obligation_2.
Print euclid_trace_func_obligation_3.
Print euclid_trace_func_obligation_4.

Compute (euclid_trace 18 48).
Example traced_result : euclid_trace 18 48 = 6.
Proof. reflexivity. Qed.
Print Assumptions euclid_trace.

(** Checkpoint:

    - Point to the proof argument attached to the [then] call in Preterm.
    - Classify the four obligations: two decreases, one match condition,
      one well-foundedness proof.
    - At which command does [Check euclid_trace] first succeed?

    The four propositions constrain THIS proposed term. The proofs are
    referenced or substituted into its holes, not filed beside unrelated
    source text. We inspect the final connection again in Lesson 4.

    Next: L03_Accessibility.v -- what core recursion does Fix_sub use?
*)
