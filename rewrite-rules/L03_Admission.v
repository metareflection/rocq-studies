(** Lesson 3 -- Follow one rule from declaration to conversion.
    (~25 minutes, with the source map in README.md open.)

    First build [L01_Conversion.v]. This file is an importing client:
    its conversion examples use the rules saved with that module.
    It does not replay Lesson 1's proof scripts or rule declarations.
*)

From RewriteStudy Require Import L01_Conversion.

Set Guard Checking.
Set Universe Checking.
Test Guard Checking.
Test Universe Checking.

Check pplus.
Print pplus.
Print native_right_zero.

(** A rule block has a name, but it is not an equality-proof constant.
    The [Print] diagnostic is an observation about this interface, not
    the entire argument that no metatheoretic evidence was checked. *)
Fail Check pplus_rules.
Fail Print pplus_rules.

Definition imported_computation : forall n, pplus n 0 = n :=
  fun n => eq_refl.
Definition imported_reindex (P : nat -> Type) (n : nat)
  (x : P (pplus n 0)) : P n := x.

Print imported_computation.
Print imported_reindex.
Print Assumptions imported_computation.

(** Trace the rule [pplus ?n 0 => ?n] through these entry points in the
    surrounding Rocq source, pinned in README.md:

    1. [vernac/comRewriteRule.ml], [interp_rule]: elaborate the pattern,
       collect holes, check its shape and symbol head; try checking the
       replacement against the inferred type. Read the warning/fallback
       branch, not just the successful typing branch.

    2. The same file, [do_rules]: build rule data and call
       [Global.add_rewrite_rules]. Follow that wrapper in library/global.ml.

    3. [kernel/safe_typing.ml], [add_rewrite_rules]: add an [SFBrules]
       field; [add_field] passes it to [Environ.add_rewrite_rules].

    4. [kernel/environ.ml], [add_rewrite_rules]: store the rule under
       its symbol. Find the rule's hole count, pattern, and replacement
       in the data, rather than looking for an equality proof.

    5. [kernel/cClosure.ml], [knr]'s Symbol case and
       [RedPattern.match_symbol]: match a rule, construct a substitution,
       and continue reduction with the instantiated replacement.

    At the call [pplus n 0], the first hole is instantiated by [n], so
    the replacement is [n]. Conversion can therefore accept [eq_refl]
    at the type [pplus n 0 = n].

    This path does not ask for proofs of confluence or termination.
    Its current typing attempt is not a guarantee of subject reduction.
    Lesson 4 exhibits the distinction without modifying kernel code.

    Compare Rewster (JAR 2026), section 7: the article distinguishes
    native rewrite support from the typing checker proposed in PR
    #19290. Its section 9 separately lists implementing the Rocq
    confluence checker as future work. These are the article's dated
    implementation statements; this source trace establishes what the
    particular checkout used by our lessons does.
*)

(** Compare with the termination study (optional prior reading):

    - Program Fixpoint constructs a term using an existing recursor
      and evidence of decrease/accessibility. The core recursive term
      satisfies the existing structural check.
    - Rewrite Rule registers patterns and replacements consulted by
      native reduction. There is no analogous proof parameter in this
      declaration interface certifying the whole extended reduction.

    Successful import shows availability of compiled declarations.
    It is not a new proof that their rules have good metaproperties.
    [Print Assumptions] reports symbol/theory dependencies; it does not
    certify the rewrite system's confluence, termination or consistency.

    Checkpoint: describe the proposed object, the installed data, where
    conversion uses it, and the missing guarantees in your own words.

    Next: L04_Boundaries.v -- accepted declarations with bad behavior.
*)
