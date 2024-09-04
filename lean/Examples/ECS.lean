import Raylean
import ECS

open Raylean
open Raylean.Types
open ECS

structure Position where
  position : Vector2

structure Velocity where
  velocity : Vector2

structure Magic where
  magic : Nat

makeMapComponent Position
makeMapComponent Velocity
makeMapComponent Magic

structure World where
  positionStore : MapStorage Position
  velocityStore : MapStorage Velocity
  magicStore : MapStorage Magic
  entityStore : GlobalStorage EntityCounter

instance : @Has World Position (MapStorage Position) _ where
  getStore := (·.positionStore) <$> read

instance : @Has World Velocity (MapStorage Velocity) _ where
  getStore := (·.velocityStore) <$> read

instance : @Has World Magic (MapStorage Magic) _ where
  getStore := (·.magicStore) <$> read

instance : @Has World EntityCounter (GlobalStorage EntityCounter) _ where
  getStore := (·.entityStore) <$> read

def initWorld : IO World := do
  let positionStore : MapStorage Position ← ExplInit.explInit
  let velocityStore : MapStorage Velocity ← ExplInit.explInit
  let magicStore : MapStorage Magic ← ExplInit.explInit
  let entityStore : GlobalStorage EntityCounter ← ExplInit.explInit
  pure {positionStore,velocityStore,magicStore,entityStore}

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

def main : IO Unit := do
  runSystem game (← initWorld)
