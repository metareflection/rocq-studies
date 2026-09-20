(** Lesson 5 -- Why does the triangle property help? (~35 minutes.)

    Read The Taming of the Rew, section 4.1, alongside this file, then
    The Rewster (JAR 2026), sections 4.1-4.2. See study_plan.md for the
    manuscript version and page references.
    This is a small proof about abstract relations, not a model of
    Rocq's syntax or a checker for native rules. It imports none of the
    native examples. The build checks it WITHOUT -allow-rewrite-rules.

    The key move is to find a parallel relation P and a function rho:

                          t
                         / \
                        u -> rho(t)

    Every P-successor of t can take one more P-step to the SAME rho(t).
    We prove the relational argument completely below. Constructing
    the right P and proving this premise for a type theory is the hard
    work in the paper; the premise is not assumed true of our checkout.
*)

From Corelib Require Import Init.Logic.

Set Guard Checking.
Set Universe Checking.

(** [steps R x y] means zero or more R-steps from x to y. A reflexive
    case is essential: a common reduct may already be one endpoint. *)
Inductive steps {A : Type} (R : A -> A -> Prop) : A -> A -> Prop :=
| steps_refl : forall x, steps R x x
| steps_cons : forall x y z, R x y -> steps R y z -> steps R x z.

Arguments steps_refl {A R} x.
Arguments steps_cons {A R x y z} _ _.

Definition diamond {A : Type} (R : A -> A -> Prop) :=
  forall t u v, R t u -> R t v ->
    exists w, R u w /\ R v w.

Definition confluent {A : Type} (R : A -> A -> Prop) :=
  forall t u v, steps R t u -> steps R t v ->
    exists w, steps R u w /\ steps R v w.

Definition triangle {A : Type} (P : A -> A -> Prop) (rho : A -> A) :=
  (forall t, P t (rho t)) /\
  (forall t u, P t u -> P u (rho t)).

(** Exercise: hide the proof. What witness joins the two successors?
    No induction and no termination argument are needed here. *)
Lemma triangle_diamond {A : Type} (P : A -> A -> Prop) (rho : A -> A) :
  triangle P rho -> diamond P.
Proof.
  intros [_ Htriangle] t u v Htu Htv.
  exists (rho t). split.
  - apply Htriangle. exact Htu.
  - apply Htriangle. exact Htv.
Qed.

(** The next two proofs fill a grid of diamonds. The inductions are on
    the FINITE paths supplied to the theorem. They do not assume every
    reduction sequence terminates. Step through one cons case slowly. *)
Lemma diamond_strip {A : Type} (R : A -> A -> Prop) :
  diamond R ->
  forall a b c, R a b -> steps R a c ->
    exists d, steps R b d /\ R c d.
Proof.
  intros D a b c Hab Hac. revert b Hab.
  induction Hac as [a | a x c Hax Hxc IH].
  - intros b Hab. exists b. split.
    + apply steps_refl.
    + exact Hab.
  - intros b Hab.
    destruct (D a b x Hab Hax) as [w [Hbw Hxw]].
    destruct (IH w Hxw) as [d [Hwd Hcd]].
    exists d. split.
    + exact (steps_cons Hbw Hwd).
    + exact Hcd.
Qed.

Lemma diamond_confluent {A : Type} (R : A -> A -> Prop) :
  diamond R -> confluent R.
Proof.
  intros D a b c Hab. revert c.
  induction Hab as [a | a x b Hax Hxb IH].
  - intros c Hac. exists c. split.
    + exact Hac.
    + apply steps_refl.
  - intros c Hac.
    destruct (diamond_strip R D a x c Hax Hac) as [d [Hxd Hcd]].
    destruct (IH d Hxd) as [e [Hbe Hde]].
    exists e. split.
    + exact Hbe.
    + exact (steps_cons Hcd Hde).
Qed.

(** Two bookkeeping lemmas let us move between ordinary and parallel
    reduction. Their statements matter more than their proof scripts. *)
Lemma steps_trans {A : Type} (R : A -> A -> Prop) :
  forall x y z, steps R x y -> steps R y z -> steps R x z.
Proof.
  intros x y z Hxy Hyz.
  induction Hxy as [x | x u y Hxu Huy IH].
  - exact Hyz.
  - exact (steps_cons Hxu (IH Hyz)).
Qed.

Lemma steps_simulation {A : Type} (R S : A -> A -> Prop) :
  (forall x y, R x y -> steps S x y) ->
  forall x y, steps R x y -> steps S x y.
Proof.
  intros embed x y Hxy.
  induction Hxy as [x | x u y Hxu Huy IH].
  - apply steps_refl.
  - exact (steps_trans S x u y (embed x u Hxu) IH).
Qed.

(** The paper's bridge is R contained in P contained in R*.
    Read the three premises aloud before looking at the proof. *)
Theorem confluence_via_triangle {A : Type}
  (R P : A -> A -> Prop) (rho : A -> A) :
  (forall x y, R x y -> P x y) ->
  (forall x y, P x y -> steps R x y) ->
  triangle P rho -> confluent R.
Proof.
  intros include simulate Htriangle t u v Htu Htv.
  assert (lift_R : forall x y, R x y -> steps P x y).
  { intros x y Hxy.
    exact (steps_cons (include x y Hxy) (steps_refl y)). }
  pose proof (steps_simulation R P lift_R t u Htu) as HtuP.
  pose proof (steps_simulation R P lift_R t v Htv) as HtvP.
  destruct (diamond_confluent P (triangle_diamond P rho Htriangle)
    t u v HtuP HtvP) as [w [Huw Hvw]].
  exists w. split.
  - exact (steps_simulation P R simulate u w Huw).
  - exact (steps_simulation P R simulate v w Hvw).
Qed.

Print confluence_via_triangle.
Print Assumptions confluence_via_triangle.

(** Checkpoint

    1. Where would a certificate have to connect to the ACTUAL native
       reduction relation? Identify all three premises above.
    2. Why is diamond stronger than local confluence? Local confluence
       allows many steps to join a ONE-step peak. It is not enough on
       its own to conclude confluence without another argument.
    3. Does this theorem require strong normalization? No: its proof
       inducts over supplied finite derivations, not an Acc proof of R.
    4. Does it certify [pplus_rules]? No P, rho, or bridge proofs have
       been supplied for Rocq's actual reduction and those rules.

    Reading exercise: Taming Example 4.3 has the same four addition
    equations as Lesson 1. Follow BOTH branches from (S m) + (S n).
    They are joinable, but the paper's chosen one-step parallel witness
    does not satisfy the triangle property. Explain how its additional
    parallel rule repairs that witness. "This criterion fails" does
    not mean "the original system is nonconfluent".

    Journal reading: Rewster 2026 Definition 1 and Theorem 2 (section
    4.2) give the criterion and triangle argument for richer patterns.
    Explain the required overlap patterns, their rule priority, and
    the one-parallel-step condition. These are premises to establish
    for the intended reduction relation, not properties checked here.

    Section 4.3 then relates reduction to alpha-cumulativity and SProp
    irrelevance. Our abstract confluence theorem does not supply those
    compatibility facts. Section 9 lists formalizing the journal's
    criteria and proofs in MetaRocq as future work; do not identify
    them with the historical Taming formalization.

    Stop here to discuss the first walkthrough. study_plan.md gives
    the next phases: modularity, dependent typing, and formal artifacts.
*)
