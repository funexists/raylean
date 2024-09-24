import Raylean.Core
import Raylean.Types
import Raylean.Math
import Raylean.Graphics2D.Basic
import Lens
import Raylean.Lean

open Raylean.Types
open Lens

namespace Raylean.Graphics2D

structure RenderState where
  scale : Vector2
  color : Color
  translate : Vector2
  center : Vector2

def RenderState.doTranslate (s : RenderState) (v : Vector2) : Vector2 :=
  ⟨v.x + s.translate.x, v.y - s.translate.y⟩

def RenderState.toScreen (s : RenderState) (v : Vector2) : Vector2 :=
  s.doTranslate ⟨s.center.x + s.scale.x * v.x, s.center.y - s.scale.y * v.y⟩

makeLenses RenderState

open RenderState.Lens

def renderLine (points : Array Vector2) : ReaderT RenderState IO Unit :=
  for (startPoint, endPoint) in points.zip (points.extract 1 points.size) do
    let s ← read
    drawLineV (s.toScreen startPoint) (s.toScreen endPoint) s.color

def renderCircle (radius : Float) : ReaderT RenderState IO Unit := do
  let s ← read
  drawCircleV (s.doTranslate s.center) (radius * (max 0 (max s.scale.x s.scale.y))) s.color

def renderRectangle (width height : Float) : ReaderT RenderState IO Unit := do
  let s ← read
  let topLeft : Vector2 := ⟨-width / 2, height / 2⟩
  let p := s.toScreen topLeft
  let r : Rectangle := {x := p.x, y := p.y, width := s.scale.x * width, height := s.scale.y * height}
  drawRectangleRec r s.color

partial def renderPicture' : (picture : Picture) → ReaderT RenderState IO Unit
  | .blank => return ()
  | .line ps => renderLine ps
  | .circle radius => renderCircle radius
  | .rectangle width height => renderRectangle width height
  | .color c p  => renderPicture' p |>.local (set color c)
  | .translate v p => renderPicture' p |>.local (over translate (·.add v))
  | .scale v p => renderPicture'  p |>.local (over scale (·.dot v))
  | .pictures ps => (fun _ => ()) <$> ps.mapM renderPicture'
  | .rotate _ _ => return ()
  | .text _ => return ()
  | .image _ => return ()
  | .imageSelection _ _ => return ()

def renderPicture (width height : Float) (picture : Picture) : IO Unit :=
  let initState := {scale := ⟨1,1⟩, color := Color.transparent, translate := ⟨0,0⟩, center := ⟨width / 2, height / 2⟩}
  renderPicture' picture |>.run initState
