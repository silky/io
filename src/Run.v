Require Import Effect.
Require Import C.

(** A run is an execution of a computation with explicit answers for the
    external calls. We define a run by induction on a computation. The `Intro`
    operator is used to introduce a value of a given type, to help to answer
    to the calls. *)
Inductive t : forall {E : Effect.t} {A : Type}, C.t E A -> A -> Type :=
| Ret : forall {E A} (x : A), t (C.Ret (E := E) x) x
| Call : forall E (command : Effect.command E) (answer : Effect.answer E command),
  t (C.Call E command) answer
| Let : forall {E A B} {c_x : C.t E B} {x : B} {c_f : B -> C.t E A} {y : A},
  t c_x x -> t (c_f x) y -> t (C.Let c_x c_f) y
| Join : forall {E A B} {c_x : C.t E A} {x : A} {c_y : C.t E B} {y : B},
  t c_x x -> t c_y y -> t (C.Join c_x c_y) (x, y)
| Left : forall {E A B} {c_x : C.t E A} {x : A} {c_y : C.t E B},
  t c_x x -> t (C.First c_x c_y) (inl x)
| Right : forall {E A B} {c_x : C.t E A} {c_y : C.t E B} {y : B},
  t c_y y -> t (C.First c_x c_y) (inr y)
| Intro : forall {E A} (B : Type) {c : C.t E A} {x : A}, (B -> t c x) -> t c x.