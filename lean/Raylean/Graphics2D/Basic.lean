import Raylean.Types

open Raylean.Types

namespace Raylean.Graphics2D

inductive Picture : Type where
  | blank : Picture
  | line (path : Array Vector2) : Picture
  | circle (radius : Float) : Picture
  | rectangle (width : Float) (height : Float)
  | image : Image → Picture
  | imageSelection (subsection : Rectangle) : Image → Picture
  | text : String → Picture
  | color : Color → Picture → Picture
  | translate : Vector2 → Picture → Picture
  | scale : Vector2 → Picture → Picture
  | rotate : Float → Picture → Picture
  | pictures : Array Picture → Picture

instance : Inhabited Picture where
  default := .blank

instance : Append Picture where
  append : Picture → Picture → Picture
   | (.pictures ps1), (.pictures ps2) => .pictures <| ps1 ++ ps2
   | (.pictures ps), p => .pictures <| ps.push p
   | p, (.pictures ps) => .pictures <| #[p] ++ ps
   | p1, p2 => .pictures #[p1, p2]
