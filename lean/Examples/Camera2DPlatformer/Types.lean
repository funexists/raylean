import Raylean.Types
import Lens

namespace Types

open Raylean.Types
open Lens

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
  playerTexture : Texture2D

makeLenses Player
makeLenses Camera2D
makeLenses GameState
makeLenses Vector2

abbrev GameM : Type -> Type := StateT GameState (ReaderT GameEnv IO)

open GameState.Lens
open Player.Lens
open Vector2.Lens
open Camera2D.Lens

def modifyPositionX [MonadState GameState m] (f : Float → Float) : m Unit :=
  modify (over (player ∘ position ∘ x) f)

def modifyPositionY [MonadState GameState m] (f : Float → Float) : m Unit :=
  modify (over (player ∘ position ∘ y) f)

def modifySpeed [MonadState GameState m] (f : Float → Float) : m Unit :=
  modify (over (player ∘ speed) f)

def setPositionY [MonadState GameState m] (py : Float) : m Unit :=
  modify (set (player ∘ position ∘ y) py)

def setCanJump [MonadState GameState m] (b : Bool) : m Unit :=
  modify (set (player ∘ canJump) b)

def setSpeed [MonadState GameState m] (s : Float) : m Unit :=
  modify (set (player ∘ speed) s)

def modifyZoom [MonadState GameState m] (f : Float -> Float) : m Unit :=
  modify (over (camera ∘ zoom) f)

def setZoom [MonadState GameState m] (z : Float) : m Unit :=
  modify (set (camera ∘ zoom) z)

def setTarget [MonadState GameState m] (v : Vector2) : m Unit :=
  modify (set (camera ∘ target) v)

namespace Types
