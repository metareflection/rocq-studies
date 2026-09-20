(** Lesson 1 -- What does the baseline establish? (About 20 minutes.)

    Start here after running [python3 check.py] from this folder.
    Editor/load-path instructions are in README.md.
    Step through the commands; predict each result before executing it.

    [Euclid.v] contains the complete algorithm and arithmetic proofs.
    Open it alongside this lesson when you want to inspect the proofs.
    This lesson covers Phase 1 of study_plan.md.
*)

From Corelib Require Import Init.Nat Program.Wf.
From TerminationStudy Require Import Euclid.

Set Guard Checking.
Set Universe Checking.
Test Guard Checking.
Test Universe Checking.

(** The imported function has a plain computational interface. Its type
    promises a natural number, not a proof that this number is the gcd. *)
Check euclid_sub.

Compute (euclid_sub 48 18).
Compute (euclid_sub 18 48).
Compute (euclid_sub 0 5).
Compute (euclid_sub 5 0).

(** These equalities make the four observations checked examples. They
    do not establish the gcd specification for all inputs. *)
Example baseline_examples :
  euclid_sub 48 18 = 6 /\ euclid_sub 18 48 = 6 /\
  euclid_sub 0 5 = 5 /\ euclid_sub 5 0 = 5.
Proof. repeat split; reflexivity. Qed.

Print Assumptions euclid_sub.
Print Assumptions baseline_examples.

(** Predict: can Rocq pick one argument that decreases in BOTH branches?

    In the [then] branch [a] stays [S a']; in the [else] branch [b] stays
    [S b']. A numerical decrease of their sum does not by itself supply
    the structural argument of an ordinary Fixpoint.

    [Fail] asserts rejection and leaves no definition behind. In an
    interactive session (or the build log), read the diagnostic.
*)
Fail Fixpoint plain (a b : nat) : nat :=
  match a, b with
  | 0, _ => b
  | _, 0 => a
  | S a', S b' =>
      if Nat.leb (S a') (S b')
      then plain (S a') (S b' - S a')
      else plain (S a' - S b') (S b')
  end.

(** The preceding message is "Cannot guess decreasing argument of fix."
    Its source is [pretyping/pretyping.ml:141], in [search_guard].
    It summarizes unsuccessful candidate checks during elaboration.

    To separate inference from checking a specified argument, change
    ONLY the structural annotation in the following two copies. *)
Fail Fixpoint structural_a (a b : nat) {struct a} : nat :=
  match a, b with
  | 0, _ => b
  | _, 0 => a
  | S a', S b' =>
      if Nat.leb (S a') (S b')
      then structural_a (S a') (S b' - S a')
      else structural_a (S a' - S b') (S b')
  end.

Fail Fixpoint structural_b (a b : nat) {struct b} : nat :=
  match a, b with
  | 0, _ => b
  | _, 0 => a
  | S a', S b' =>
      if Nat.leb (S a') (S b')
      then structural_b (S a') (S b' - S a')
      else structural_b (S a' - S b') (S b')
  end.

Fail Check plain.
Fail Check structural_a.
Fail Check structural_b.

(** Inspect the supporting evidence in [Euclid.v].
    A useful surprise: neither decrease lemma needs the [leb] outcome.
    Subtracting a positive natural decreases the sum in either branch,
    even with truncated subtraction. Branch selection matters to the
    gcd algorithm, but these termination inequalities do not use it. *)
Check TerminationFacts.subtract_right_decreases.
Check TerminationFacts.subtract_left_decreases.
Check TerminationFacts.nat_lt_wf.

(** Checkpoint -- explain these before going on:

    1. Which recursive call rules out {struct a}? Which rules out {struct b}?
    2. What does "Closed under the global context" tell you? Does it
       establish that [euclid_sub] computes the gcd for every input?
    3. Where did the plain-definition diagnostic originate?

    Answer cues: unchanged first argument in [then]; unchanged second
    argument in [else]; no global axioms in this constant's dependencies;
    no general gcd theorem; [Pretyping.search_guard].

    Next: L02_Obligations.v -- where do the proofs attach to the program?
*)
