(** Subtraction-based Euclid: complete baseline and supporting proofs.

    Start the guided walkthrough in L01_Baseline.v. This reference module
    contains the algorithm and every arithmetic lemma used by the lessons.
    Build everything with [python3 check.py] from this folder.
*)

From Corelib Require Import Init.Nat Program.Wf.

Set Guard Checking.
Set Universe Checking.

(* The ordinary structural termination checker rejects this program.
   Fail asserts rejection; it does not admit the definition. *)
Fail Fixpoint euclid_sub_plain (a b : nat) : nat :=
  match a, b with
  | 0, _ => b
  | _, 0 => a
  | S a', S b' =>
      if Nat.leb (S a') (S b')
      then euclid_sub_plain (S a') (S b' - S a')
      else euclid_sub_plain (S a' - S b') (S b')
  end.

(* Elementary arithmetic support, requiring only Corelib. *)
Module TerminationFacts.

Lemma le_transitive n m p : n <= m -> m <= p -> n <= p.
Proof.
  intros Hnm Hmp. induction Hmp.
  - exact Hnm.
  - apply le_S. exact IHHmp.
Defined.

Lemma sub_le n m : n - m <= n.
Proof.
  revert m. induction n as [|n IH]; intros [|m]; simpl.
  - apply le_n.
  - apply le_n.
  - apply le_n.
  - apply le_S. apply IH.
Defined.

Lemma add_le_left n m k : n <= m -> k + n <= k + m.
Proof.
  intro H. induction k as [|k IH]; simpl.
  - exact H.
  - apply le_n_S. exact IH.
Defined.

Lemma add_le_right n m k : n <= m -> n + k <= m + k.
Proof.
  intro H. induction H; simpl.
  - apply le_n.
  - apply le_S. exact IHle.
Defined.

Lemma subtract_right_decreases a b :
  S a + (S b - S a) < S a + S b.
Proof.
  unfold lt. simpl. rewrite <- plus_n_Sm.
  apply le_n_S, le_n_S, add_le_left, sub_le.
Defined.

Lemma subtract_left_decreases a b :
  (S a - S b) + S b < S a + S b.
Proof.
  unfold lt. simpl.
  apply le_n_S, add_le_right, sub_le.
Defined.

Lemma nat_lt_wf : well_founded lt.
Proof.
  assert (bounded : forall n m, m < n -> Acc lt m).
  { intro n. induction n as [|n IH]; intros m Hm.
    - inversion Hm.
    - constructor. intros k Hk. apply IH.
      unfold lt in *.
      eapply le_transitive; [exact Hk |].
      apply le_S_n. exact Hm.
  }
  intro n. apply (bounded (S n) n). apply le_n.
Defined.

End TerminationFacts.

(* The same algorithm, with measure a + b and checked proofs.
   In each positive-input branch, one argument stays unchanged while
   the other decreases. Neither decreases in every branch, but their
   sum does. The recursive calls are unchanged.
*)
#[local] Obligation Tactic := idtac.

Program Fixpoint euclid_sub (a b : nat) {measure (a + b)} : nat :=
  match a, b with
  | 0, _ => b
  | _, 0 => a
  | S a', S b' =>
      if Nat.leb (S a') (S b')
      then euclid_sub (S a') (S b' - S a')
      else euclid_sub (S a' - S b') (S b')
  end.

Next Obligation.
  intros a b recurse a' b' Ha Hb. subst a b.
  apply TerminationFacts.subtract_right_decreases.
Defined.

Next Obligation.
  intros a b recurse a' b' Ha Hb. subst a b.
  apply TerminationFacts.subtract_left_decreases.
Defined.

Next Obligation.
  (* Pattern matching bookkeeping: zero is not a successor. *)
  intros; intuition discriminate.
Defined.

Next Obligation.
  (* There is no infinite descending chain of natural-number measures. *)
  apply measure_wf. exact TerminationFacts.nat_lt_wf.
Defined.

(* The accepted definition computes and has no axioms. *)
Compute (euclid_sub 48 18).
Compute (euclid_sub 18 48).
Compute (euclid_sub 0 5).
Compute (euclid_sub 5 0).

Print Assumptions euclid_sub.
