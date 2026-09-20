(** Lesson 1 -- What changes when an equation computes? (~25 minutes.)

    Run [python3 check.py] from this folder, then visit the L*.v files
    in order. README.md explains editor setup. All examples use Corelib.

    We start with ordinary addition, then declare a fresh symbol whose
    rules compute on either argument. Before each [Fail] or [Eval],
    predict what Rocq will do. No theorem about the whole rewrite system
    is being claimed by these individual examples.
*)

From Corelib Require Import Init.Nat.

Set Guard Checking.
Set Universe Checking.
Test Guard Checking.
Test Universe Checking.

(** Ordinary addition inspects its FIRST argument. A variable blocks
    that match, even when the second argument is zero. *)
Print Nat.add.
Eval cbn in (fun n => 0 + n).
Eval cbn in (fun n => n + 0).

Definition ordinary_left_zero : forall n, 0 + n = n :=
  fun n => eq_refl.

Fail Definition ordinary_right_zero_by_conversion : forall n, n + 0 = n :=
  fun n => eq_refl.

(** The missing computational equation is still PROVABLE. Hide this
    proof and try it yourself: what is the induction hypothesis? *)
Lemma ordinary_right_zero : forall n, n + 0 = n.
Proof.
  induction n as [|n IH].
  - reflexivity.
  - cbn. rewrite IH. reflexivity.
Qed.

(** [rewrite] uses an equality proof to transform a goal. It does not
    install a native rule for [Nat.add]. *)
Example ordinary_use (n : nat) : S (n + 0) = S n.
Proof. rewrite ordinary_right_zero. reflexivity. Qed.

Fail Definition ordinary_still_stuck : forall n, n + 0 = n :=
  fun n => eq_refl.

(** A Symbol has a declared type and no defining body. This declaration
    is an assumption about a new operation; it is not a Fixpoint. *)
Symbol pplus : nat -> nat -> nat.
Check pplus.
Print pplus.

Fail Definition before_rules : forall n, pplus n 0 = n :=
  fun n => eq_refl.

(** Parallel addition, following the native rewrite-rule manual.
    [?n] binds a pattern variable. The same name on the right refers to
    the matched term. Rules here overlap: overlap is not itself failure
    of confluence. That distinction will matter in Lesson 5. *)
Rewrite Rule pplus_rules :=
| pplus ?n 0 => ?n
| pplus ?n (S ?m) => S (pplus ?n ?m)
| pplus 0 ?n => ?n
| pplus (S ?n) ?m => S (pplus ?n ?m).

Definition native_right_zero : forall n, pplus n 0 = n :=
  fun n => eq_refl.
Definition native_left_zero : forall n, pplus 0 n = n :=
  fun n => eq_refl.
Definition native_successors :
  forall n m, pplus (S n) (S m) = S (S (pplus n m)) :=
  fun n m => eq_refl.

Eval cbn in (fun n => pplus n 0).
Eval cbn in (fun n m => pplus (S n) (S m)).
Example concrete_sum : pplus 5 10 = 15.
Proof. reflexivity. Qed.

(** Conversion also aligns TYPES. [P] is an arbitrary family indexed
    by natural numbers. Inspect the body: there is no equality transport
    in it. The expected and actual types become equal by computation. *)
Definition native_reindex (P : nat -> Type) (n : nat)
  (x : P (pplus n 0)) : P n := x.

Fail Definition ordinary_reindex (P : nat -> Type) (n : nat)
  (x : P (n + 0)) : P n := x.

Print native_right_zero.
Print native_reindex.
Print Assumptions ordinary_right_zero.
Print Assumptions native_right_zero.

(** Checkpoint

    1. Why can [eq_refl] prove [native_right_zero]?
    2. Did proving [ordinary_right_zero] change computation of [Nat.add]?
    3. Which assumption and theory flag appear for the native example?
    4. Does one successful equality prove confluence or termination?

    Cues: conversion uses the registered rule; an equality theorem does
    not change native reduction; the symbol [pplus] and rewrite opt-in
    are reported; testing equalities establishes those examples only.

    Next: L02_Patterns.v -- which declarations are actually rejected?
*)
