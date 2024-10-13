import Raylean.Core
import Raylean.Types
import Raylean.Math
import Raylean.Graphics2D.Basic
import Lens
import Raylean.Lean

open Raylean.Types
open Lens

namespace Raylean.Graphics2D

structure RenderContext where
  scale : Vector2
  color : Color
  translate : Vector2
  center : Vector2

/-- Convert a point in Picture coordinates to a point in screen coordinates -/
def RenderContext.toScreen (s : RenderContext) (v : Vector2) : Vector2 :=
  let translateScreen := s.translate.dot ⟨1, -1⟩
  let vScreen := v.dot ⟨1, -1⟩
  vScreen |>.dot s.scale |>.add translateScreen |>.add s.center

abbrev getContext : ReaderT RenderContext IO RenderContext := read

makeLenses RenderContext

open RenderContext.Lens

def renderLine (points : Array Vector2) : ReaderT RenderContext IO Unit := do
  let ctx ← getContext
  drawLineStrip (points.map ctx.toScreen) ctx.color

def renderCircle (radius : Float) : ReaderT RenderContext IO Unit := do
  let ctx ← getContext
  drawCircleV (ctx.toScreen ⟨0, 0⟩) (radius * (max 0 (max ctx.scale.x ctx.scale.y))) ctx.color

def renderRectangle (width height : Float) : ReaderT RenderContext IO Unit := do
  let ctx ← getContext
  let topLeft : Vector2 := ⟨-width / 2, height / 2⟩
  let p := ctx.toScreen topLeft
  let r : Rectangle := {x := p.x, y := p.y, width := ctx.scale.x * width, height := ctx.scale.y * height}
  drawRectangleRec r ctx.color

-- This function is partial because lean cannot prove termination
partial def renderPicture' : (picture : Picture) → ReaderT RenderContext IO Unit
  | .blank => return ()
  | .line ps => renderLine ps
  | .circle radius => renderCircle radius
  | .rectangle width height => renderRectangle width height
  | .color c p  => renderPicture' p |>.local (set color c)
  | .translate v p => renderPicture' p |>.local (fun s =>
    over translate (·.add (v.dot s.scale)) s
  )
  | .scale v p => renderPicture'  p |>.local (over scale (·.dot v))
  | .pictures ps => (fun _ => ()) <$> ps.mapM renderPicture'

def renderPicture (width height : Float) (picture : Picture) : IO Unit :=
  let initState := {scale := ⟨1,1⟩, color := Color.transparent, translate := ⟨0,0⟩, center := ⟨width / 2, height / 2⟩}
  renderPicture' picture |>.run initState
