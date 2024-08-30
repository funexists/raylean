import Raylib
import ECS

structure Position where
  position : Vector2

structure Velocity where
  velocity : Vector2

instance : Component Position where
  StorageType := MapStorage Position
  constraint := rfl

instance : Component Velocity where
  StorageType := MapStorage Velocity
  constraint := rfl

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

instance : ExplGet (Component.StorageType EntityCounter) where
  explGet := let i : ExplGet (GlobalStorage EntityCounter) := inferInstance
    i.explGet

  explExists := let i : ExplGet (GlobalStorage EntityCounter) := inferInstance
    i.explExists

instance : ExplSet (Component.StorageType EntityCounter) where
  explSet := let i : ExplSet (GlobalStorage EntityCounter) := inferInstance
    i.explSet

instance : ExplSet (Component.StorageType Position) where
  explSet := let i : ExplSet (MapStorage Position) := inferInstance
    i.explSet

def game : System World Unit := do
  let p : Position := {position := ⟨0,0⟩}
  newEntity_ p
