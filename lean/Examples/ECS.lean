import Raylean
import ECS

open Raylean
open Raylean.Types

structure Position where
  position : Vector2

structure Velocity where
  velocity : Vector2

axiom StoragePosition : StorageFam Position = MapStorage Position
instance : FamilyDef StorageFam Position (MapStorage Position) := ⟨StoragePosition⟩

instance : @Component Position (MapStorage Position) Position _ _ where
  constraint := rfl

axiom StorageVelocity : StorageFam Velocity = MapStorage Velocity
instance : FamilyDef StorageFam Velocity (MapStorage Velocity) := ⟨StorageVelocity⟩

instance : @Component Velocity (MapStorage Velocity) Velocity _ _ where
  constraint := rfl

structure World where
  positionStore : MapStorage Position
  velocityStore : MapStorage Velocity
  entityStore : GlobalStorage EntityCounter

instance : @Has World Position (MapStorage Position) _ where
  getStore := (·.positionStore) <$> read

instance : @Has World Velocity (MapStorage Velocity) _ where
  getStore := (·.velocityStore) <$> read

instance : @Has World EntityCounter (GlobalStorage EntityCounter) _ where
  getStore := (·.entityStore) <$> read

def initWorld : IO World := do
  let positionStore : MapStorage Position ← ExplInit.explInit
  let velocityStore : MapStorage Velocity ← ExplInit.explInit
  let entityStore : GlobalStorage EntityCounter ← ExplInit.explInit
  pure {positionStore,velocityStore,entityStore}

def update (pv : Position × Velocity) : Position :=
  let (p, v) := pv
  {position := p.position.add v.velocity}

def dumpState : System World Unit := do
  IO.println "DUMP STATE"
  cmapM_ (fun ((p, v) : Position × Velocity) =>
    IO.println s!"position : ({p.position.x}, {p.position.y}) velocity : ({v.velocity.x}, {v.velocity.y})")

def game : System World Unit := do
  newEntityAs_ (Position × Velocity) (⟨0,0⟩, ⟨10,11⟩)
  newEntityAs_ (Position × Velocity) (⟨1,0⟩, ⟨-5,-2⟩)
  set' global {position := ⟨0,0⟩ : Position}
  dumpState
  cmap update
  dumpState

def main : IO Unit := do
  runSystem game (← initWorld)
