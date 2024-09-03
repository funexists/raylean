import «Raylean».Core

namespace Raylean

open Raylean.Types

def renderFrame [Monad m] [MonadLiftT IO m] (mkFrame : m Unit) : m Unit := do
    beginDrawing
    mkFrame
    endDrawing

def renderWithCamera [Monad m] [MonadLiftT IO m] (camera : Camera3D) (mkScene : m Unit) : m Unit := do
  beginMode3D camera
  mkScene
  endMode3D

def renderWithCamera2D [Monad m] [MonadLiftT IO m] (camera : Camera2D) (mkScene : m Unit) : m Unit := do
  beginMode2D camera
  mkScene
  endMode2D
