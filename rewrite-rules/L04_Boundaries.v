(** Lesson 4 -- Acceptance is not a metatheoretic certificate.
    (~20 minutes.)

    Open this as a separate document/process. It imports no other study
    lesson, and no other lesson imports it. The build compiles each file
    in a separate Rocq process.

    This file deliberately declares one nonconfluent system and one
    ill-typed rule. Do not use their compiled module as a proof library.
    We only inspect the failure modes; there is no admitted proof or
    disabled guard/universe check. See the local manual's section
    "Rewrite rules, type preservation, confluence and termination".
*)

From Corelib Require Import Init.Nat.

Set Guard Checking.
Set Universe Checking.
Test Guard Checking.
Test Universe Checking.

(** Each replacement has type [nat]. But the two rules permit a peak

                              forked
                              /    \
                             0      1

    with distinct normal forms under the declared relation: neither
    numeral has a reduction. Thus this tiny system is not confluent.
    Rocq accepts the block without a confluence check. *)
Symbol forked : nat.
Rewrite Rule forked_rules :=
| forked => 0
| forked => 1.

Eval cbn in forked.

(** This checkout returns [1]. A reducer picking one rule does not make
    the relation containing BOTH declared rules confluent. An observed
    strategy is not a proof that all reduction paths can be joined. *)

(** Type preservation has a different failure mode. Predict: rejection,
    warning, or silent acceptance? Read the output before continuing. *)
Symbol mistyped : nat.
Rewrite Rule mistyped_rule := mistyped => true.

Check mistyped.
Eval cbn in mistyped.

(** The warning is [rewrite-rules-break-SR]. The Eval output prints
    [true : nat], retaining the type of the input expression. It is not
    an independent successful typecheck of the displayed result! *)
Check true.
Fail Definition result_has_original_type : nat := true.

Print Assumptions mistyped.

(** Here is the concrete failed preservation claim:

      [mistyped] has type [nat]; the declared rule reduces it to [true];
      [true] itself has type [bool], and is rejected at type [nat].

    The warning is useful evidence about this example. Absence of that
    warning would not prove subject reduction: the manual describes the
    check as incomplete. Turning the warning into an error does not
    establish that the check catches all bad rules.

    Keep four questions separate:

    - Confluence: can competing reduction paths always be joined?
    - Subject reduction: does reduction preserve the original type?
    - Termination: can reduction continue indefinitely?
    - Consistency: is the logical theory free of a closed proof of False?

    These properties have connections, but none is interchangeable with
    "the file compiled". A [Symbol] itself can introduce an assumption;
    consistency is not solely a question about its rewrite rules.

    We do not run a nonterminating native rule. The paper studies
    confluence without assuming termination; that mathematical point
    does not require deliberately hanging this checkout's reducer.

    For the next reading phase, Rewster (JAR 2026), section 1, gives
    subtler examples. Example 3 uses typing to relate vector indices;
    Example 4 shows why apparent injectivity of a symbol can disappear
    after another rule is added. Locate [Failsafe] in Figure 9: why
    must the typing criterion avoid extracting that latter equality?
    These paper examples are planned visits, not executed in this file.

    Checkpoint: which checks rejected Lesson 2's examples, and which
    properties did the accepted declarations here fail to establish?

    Next: L05_Triangle.v -- a sufficient argument for confluence.
*)
