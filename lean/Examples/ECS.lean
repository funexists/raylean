import Raylean
import ECS

open Raylean
open Raylean.Types
open ECS

namespace Example

structure Position where
  position : Vector2

structure Velocity where
  velocity : Vector2

structure Magic where
  magic : Nat

makeWorldAndComponents Position Velocity Magic

def update (pv : Position × Velocity) : Position :=
  let (p, v) := pv
  {position := p.position.add v.velocity}

def dumpState : System World Unit := do
  IO.println "DUMP STATE"
  let globalPosition : Position ← get global
  cmapM_ (fun ((p, v, m) : Position × Velocity × Magic) =>
    IO.println s!"global pos: {globalPosition.position.x} position : ({p.position.x}, {p.position.y}) velocity : ({v.velocity.x}, {v.velocity.y}) magic : {m.magic}")

def game : System World Unit := do
  newEntityAs_ (Position × Velocity) (⟨0,0⟩, ⟨10,11⟩)
  newEntityAs_ (Position × Velocity) (⟨1,0⟩, ⟨-5,-2⟩)
  newEntityAs_ (Position × Velocity × Magic) (⟨1,0⟩, ⟨-5,-2⟩, ⟨1⟩)
  set' global {position := ⟨999,0⟩ : Position}
  dumpState
  cmap update
  dumpState

end Example

def main : IO Unit := do
  runSystem Example.game (← Example.initWorld)
