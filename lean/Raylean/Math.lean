import Raylean.Types

namespace Raylean

namespace Types

namespace Vector2

open Raylean.Types

def add (v1 : Vector2) (v2 : Vector2) : Vector2 :=
  { x := v1.x + v2.x, y := v1.y + v2.y }

def length (v : Vector2) : Float := Float.sqrt (v.x ^ 2 + v.y ^ 2)

def sub (v1 : Vector2) (v2 : Vector2) : Vector2 :=
  { x := v1.x - v2.x, y := v1.y - v2.y  }

def mul (v : Vector2) (s : Float) : Vector2 :=
  { x := s * v.x, y := s * v.y }

def div (v : Vector2) (s : Float) : Vector2 :=
  { x := v.x / s, y := v.y / s }

def dot (v1 v2 : Vector2) : Vector2 := ⟨v1.x * v2.x, v1.y * v2.y⟩

instance : Add Vector2 := ⟨add⟩

instance : Sub Vector2 := ⟨sub⟩

instance : HMul Float Vector2 Vector2 := ⟨flip mul⟩

instance : HMul Vector2 Float Vector2 := ⟨mul⟩

instance : HDiv Vector2 Float Vector2 := ⟨div⟩

end Vector2

namespace Vector3

def add (v1 : Vector3) (v2 : Vector3) : Vector3 :=
  { x := v1.x + v2.x, y := v1.y + v2.y, z := v1.z + v2.z }

def length (v : Vector3) : Float := Float.sqrt (v.x ^ 2 + v.y ^ 2 + v.z ^ 2)

def sub (v1 : Vector3) (v2 : Vector3) : Vector3 :=
  { x := v1.x - v2.x, y := v1.y - v2.y, z := v1.z - v2.z }

def mul (v : Vector3) (s : Float) : Vector3 :=
  { x := s * v.x, y := s * v.y, z := s * v.z }

def div (v : Vector3) (s : Float) : Vector3 :=
  { x := v.x / s, y := v.y / s, z := v.z / s }

instance : Add Vector3 := ⟨add⟩

instance : Sub Vector3 := ⟨sub⟩

instance : HMul Float Vector3 Vector3 := ⟨flip mul⟩

instance : HMul Vector3 Float Vector3 := ⟨mul⟩

instance : HDiv Vector3 Float Vector3 := ⟨div⟩

end Vector3
