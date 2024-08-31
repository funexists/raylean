import Raylib
import ECS

structure Position where
  position : Vector2

structure Velocity where
  velocity : Vector2

instance : StorageT Position where
  storageType := MapStorage Position

instance : Elem (StorageT.storageType Position) where
  elemType := inferInstanceAs (Elem (MapStorage Position)) |>.elemType

instance : ExplGet (StorageT.storageType Position) where
  explGet := inferInstanceAs (ExplGet (MapStorage Position)) |>.explGet
  explExists := inferInstanceAs (ExplGet (MapStorage Position)) |>.explExists

instance : ExplSet (StorageT.storageType Position) where
  explSet := inferInstanceAs (ExplSet (MapStorage Position) ) |>.explSet

instance : Component Position where
  constraint := rfl

instance : StorageT Velocity where
  storageType := MapStorage Velocity

instance : Elem (StorageT.storageType Velocity) where
  elemType := inferInstanceAs (Elem (MapStorage Velocity)) |>.elemType

instance : Component Velocity where
  constraint := rfl

instance : ExplSet (StorageT.storageType (Position × Velocity)) where
  explSet := inferInstanceAs (ExplSet (MapStorage Position × MapStorage Velocity) ) |>.explSet

instance : ExplMembers (StorageT.storageType (Position × Velocity)) where
  explMembers := inferInstanceAs (ExplMembers (MapStorage Position × MapStorage Velocity) ) |>.explMembers

instance : ExplGet (StorageT.storageType (Position × Velocity)) where
  explGet := inferInstanceAs (ExplGet (MapStorage Position × MapStorage Velocity) ) |>.explGet
  explExists := inferInstanceAs (ExplGet (MapStorage Position × MapStorage Velocity) ) |>.explExists

-- Stores must be in Type 1 otherwise ReaderT w IO a will not compile
-- because IO is Type 1 -> Type 1.
-- These should also be associated to the
def PositionStore : Type := MapStorage Position

def VelocityStore : Type := MapStorage Velocity

def EntityStore : Type := GlobalStorage EntityCounter

structure World where
  positionStore : PositionStore
  velocityStore : VelocityStore
  entityStore : EntityStore

instance : Has World Position where
  getStore := (·.positionStore) <$> read

instance : Has World Velocity where
  getStore := (·.velocityStore) <$> read

instance : Has World EntityCounter where
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
  newEntity_ ({position := ⟨0,0⟩ : Position}, {velocity := ⟨10,11⟩ : Velocity})
  newEntity_ ({position := ⟨1,0⟩ : Position}, {velocity := ⟨-5,-2⟩ : Velocity})
  dumpState
  cmap update
  dumpState

def main : IO Unit := do
  runSystem game (← initWorld)
