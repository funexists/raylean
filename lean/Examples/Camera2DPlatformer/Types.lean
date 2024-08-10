import Raylib.Types
import Lens

structure Player where
  position : Vector2
  speed : Float
  canJump : Bool

structure EnvItem where
  rect : Rectangle
  blocking : Bool
  color : Color

structure GameState where
  player : Player
  camera : Camera2D

structure GameEnv where
  items : List EnvItem

makeLenses Player
makeLenses Camera2D
makeLenses GameState
makeLenses Vector2

abbrev GameM : Type -> Type := StateT GameState (ReaderT GameEnv IO)

def modifyPositionX [MonadState GameState m] (f : Float → Float) : m Unit :=
  modify (over (GameState.lens.player ∘ Player.lens.position ∘ Vector2.lens.x) f)

def modifyPositionY [MonadState GameState m] (f : Float → Float) : m Unit :=
  modify (over (GameState.lens.player ∘ Player.lens.position ∘ Vector2.lens.y) f)

def modifySpeed [MonadState GameState m] (f : Float → Float) : m Unit :=
  modify (over (GameState.lens.player ∘ Player.lens.speed) f)

def setPositionY [MonadState GameState m] (py : Float) : m Unit :=
  modify (set (GameState.lens.player ∘ Player.lens.position ∘ Vector2.lens.y) py)

def setCanJump [MonadState GameState m] (b : Bool) : m Unit :=
  modify (set (GameState.lens.player ∘ Player.lens.canJump) b)

def setSpeed [MonadState GameState m] (s : Float) : m Unit :=
  modify (set (GameState.lens.player ∘ Player.lens.speed) s)

def modifyZoom [MonadState GameState m] (f : Float -> Float) : m Unit :=
  modify (over (GameState.lens.camera ∘ Camera2D.lens.zoom) f)

def setZoom [MonadState GameState m] (z : Float) : m Unit :=
  modify (set (GameState.lens.camera ∘ Camera2D.lens.zoom) z)

def setTarget [MonadState GameState m] (v : Vector2) : m Unit :=
  modify (set (GameState.lens.camera ∘ Camera2D.lens.target) v)