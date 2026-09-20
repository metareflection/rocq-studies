(** Lesson 2 -- What makes a native rule a valid pattern? (~20 minutes.)

    This file is independent of Lesson 1. Keep the diagnostic for each
    [Fail] visible. Ask which check explains it: a head restriction,
    pattern-variable binding, or ordinary typing?

    See the matching manual's "Pattern syntax" section. The fragment
    used here is first order. Lambda/match patterns, explicit hole
    substitutions, and universes belong to the later reading plan.
*)

From Corelib Require Import Init.Nat.

Set Guard Checking.
Set Universe Checking.

Definition ordinary_identity (n : nat) := n.

(** A defined constant cannot be the head of a native rule. *)
Fail Rewrite Rule on_definition := ordinary_identity ?n => ?n.

(** A constructor can occur INSIDE a pattern, but the head of the rule
    must be a symbol. This cannot install a reduction for [S] itself. *)
Fail Rewrite Rule on_constructor := S ?n => ?n.

Symbol peel : nat -> nat.
Rewrite Rule peel_successor := peel (S ?n) => ?n.

Definition peel_example : forall n, peel (S n) = n :=
  fun n => eq_refl.
Eval cbn in peel 0.

(** There is no completeness/coverage obligation requiring a rule for
    [peel 0]. With no applicable rule this term remains stuck. *)
Fail Definition peel_zero : peel 0 = 0 := eq_refl.

Symbol choose : nat -> nat -> nat.

(** A repeated named hole does not mean "compare these arguments".
    Named pattern holes must be bound at most once (left-linearity). *)
Fail Rewrite Rule nonlinear := choose ?n ?n => ?n.

(** A replacement cannot invent an unbound hole. This checkout may
    warn during elaboration before reporting the final binding error. *)
Fail Rewrite Rule unbound_rhs := choose ?n _ => ?missing.

(** Separate [_] holes discard independently matched arguments. *)
Rewrite Rule choose_first := choose ?n _ => ?n.
Definition choose_example : forall n m, choose n m = n :=
  fun n m => eq_refl.

Symbol inspect : nat -> nat.

(** A hole also cannot be the head of an application inside a pattern.
    The elaborator can type this application; the pattern check rejects
    its shape. *)
Fail Rewrite Rule application_hole := inspect (?f ?n) => 0.

(** Rules in sections are not supported by this checkout. Even a rule
    which does not mention any section variable is rejected there. *)
Section UnsupportedSection.
  Fail Rewrite Rule in_section := inspect 0 => 0.
End UnsupportedSection.

Rewrite Rule inspect_zero := inspect 0 => 0.
Example inspect_example : inspect 0 = 0.
Proof. reflexivity. Qed.

(** Checkpoint

    Classify each failure above. Then explain why accepting [peel] does
    not establish coverage, and why checking left-linearity does not
    by itself establish confluence of a collection of rules.

    Cues: symbol heads and rigid patterns restrict matching; holes must
    be bound once and available on the right; sections are unsupported;
    none of these checks compares all possible reductions of a term.

    Next: L03_Admission.v -- what is registered and later reused?
*)
