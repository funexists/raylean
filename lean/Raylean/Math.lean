import Raylean.Types

namespace Raylean

namespace Math

namespace Vector2

open Raylean.Types

def add (v1 : Vector2) (v2 : Vector2) : Vector2 :=
  { x := v1.x + v2.x, y := v1.y + v1.y : Vector2 }

def length (v : Vector2) : Float := Float.sqrt (v.x ^ 2 + v.y ^ 2)

def sub (v1 : Vector2) (v2 : Vector2) : Vector2 :=
  { x := v1.x - v2.x, y := v1.y - v2.y  }

end Vector2
