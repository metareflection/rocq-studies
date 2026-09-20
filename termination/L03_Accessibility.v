(** Lesson 3 -- The structural argument is a proof. (About 30 minutes.)

    Read after L02_Obligations.v. Keep the Preterm output nearby.
    We inspect the actual Corelib recursor used in that term and build
    the evidence package for the same [then] call, one piece at a time.
*)

From Corelib Require Import Init.Nat Program.Wf.
From TerminationStudy Require Import Euclid.

Set Guard Checking.
Set Universe Checking.

(** Read [Acc R x] as: from [x], every [R]-smaller state is accessible.
    The constructor holds a function producing the child proofs.
    The orientation is [R child parent]. *)
Print Acc.
Print Acc_inv.
Print well_founded.

(** [well_founded R] supplies [Acc R x] for EVERY starting state [x].
    A decrease proof establishes one edge. Well-foundedness supplies
    the accessibility proof with which the recursion starts.

    Program packs our two inputs in a dependent pair [sigT], even though
    the second input's type is simply [nat]. This is the same shape as
    Lesson 2's [recarg : {a : nat & nat}]. *)
Definition State : Type := {a : nat & nat}.
Definition pack (a b : nat) : State := existT (fun _ : nat => nat) a b.
Definition weight (x : State) : nat := projT1 x + projT2 x.
Definition smaller (child parent : State) : Prop :=
  weight child < weight parent.

Example relation_is_the_measure_relation :
  smaller = @MR State nat lt weight.
Proof. reflexivity. Qed.

(** Spell out the [then] call from parent (S a', S b'). The inner
    [existT] packages its two numbers. The outer [exist] packages that
    state WITH its decrease proof. These are different jobs. *)
Definition right_call (a' b' : nat) :
  {child : State | smaller child (pack (S a') (S b'))} :=
  exist _ (pack (S a') (S b' - S a'))
    (TerminationFacts.subtract_right_decreases a' b').

Check right_call.
Compute (proj1_sig (right_call 17 47)).
(* The state (18,48) calls (18,30); its measure goes from 66 to 48. *)
Compute (weight (pack 18 48)).
Compute (weight (proj1_sig (right_call 17 47))).

(** A spelling of the same global justification as obligation 4. No
    new arithmetic proof is needed: lift well-founded [lt] along weight. *)
Definition states_accessible : well_founded smaller :=
  @measure_wf State nat lt TerminationFacts.nat_lt_wf weight.

(** The critical connection: use the EXACT proof carried by this call
    to obtain an accessibility proof for its EXACT next state. *)
Definition right_child_accessible (a' b' : nat)
    (parent_proof : Acc smaller (pack (S a') (S b'))) :
    Acc smaller (proj1_sig (right_call a' b')) :=
  Acc_inv parent_proof (proj2_sig (right_call a' b')).

Check right_child_accessible.
Print Assumptions right_child_accessible.
Print Assumptions states_accessible.

(** Now inspect the library definitions, rather than guessing which
    recursor Program uses. Look for [{struct r}] in [Fix_F_sub]. *)
Print Corelib.Program.Wf.Fix_sub.
Print Corelib.Program.Wf.Fix_F_sub.

(** At [theories/Corelib/Program/Wf.v:27] the recursive call is:

      Fix_F_sub (proj1_sig y) (Acc_inv r (proj2_sig y))

    Unfold [Acc_inv]: matching [r = Acc_intro ... children] exposes
    [children], and [children child decrease] is a structurally smaller
    accessibility proof. The state itself need not be a syntactic
    subterm. The existing guard checker recognizes this recursion on [r].

    The following equality checks one actual unfolding of the library
    recursor. Section variables become explicit parameters on closing
    the section; they introduce no global axioms. *)
Section OneUnfolding.
  Variable A : Type.
  Variable R : A -> A -> Prop.
  Variable P : A -> Type.
  Variable body : forall x : A,
    (forall y : {child : A | R child x}, P (proj1_sig y)) -> P x.

  Example recursor_on_constructor (x : A)
      (children : forall child, R child x -> Acc R child) :
    Fix_F_sub A R P body x (Acc_intro x children) =
    body x (fun y =>
      Fix_F_sub A R P body (proj1_sig y)
        (children (proj1_sig y) (proj2_sig y))).
  Proof. reflexivity. Qed.
End OneUnfolding.

Print Assumptions recursor_on_constructor.

(** [Acc] lives in Prop, but its singleton-elimination permission allows
    this recursion to return values in Type (here, nat). Inspect the
    actual generated eliminator; an arbitrary proposition does not
    enjoy this permission. [Init/Wf.v:31] documents this point. *)
Check Acc_rect.

(** Checkpoint:

    1. Identify the two projections from [right_call]: state and proof.
    2. What supplies the initial [r]? What supplies the child's [r]?
    3. Is [a + b] the structural argument of [Fix_F_sub]?
    4. Did proving the decrease replace the guard checker?

    Answer cues: [proj1_sig]/[proj2_sig]; well-foundedness/[Acc_inv];
    no, [r] is the structural argument; no, the evidence enables a
    construction accepted by that checker.

    This is not yet an opacity experiment: the one-step equality above
    explicitly provides a visible [Acc_intro]. We have not established
    which opaque proofs would block a particular reduction strategy.

    Next: L04_Admission.v -- connect these pieces to the installed term.
*)
