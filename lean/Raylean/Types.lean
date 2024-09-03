namespace Raylean

namespace Types

structure Vector2 where
  x : Float
  y : Float
  deriving Inhabited

structure Vector3 where
  x : Float
  y : Float
  z : Float

structure Rectangle where
  /-- Rectangle top-left corner position x -/
  x : Float
  /-- Rectangle top-left corner position y -/
  y : Float
  /-- Rectangle width -/
  width : Float
  /-- Rectangle height -/
  height : Float

structure Camera2D where
  /-- Camera offset (displacement from target) -/
  offset : Vector2
  /-- Camera target (rotation and zoom origin) -/
  target : Vector2
  /-- Camera rotation in degrees -/
  rotation : Float
  /-- Camera zoom (scaling), should be 1.0f by default -/
  zoom : Float

inductive CameraProjection where
  | perspective
  | orthographic

structure Camera3D where
  /-- Camera position -/
  position : Vector3
  /-- Camera target it looks-at -/
  target : Vector3
  /-- Camera up vector (rotation over its axis) -/
  up : Vector3
  /-- Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic -/
  fovy : Float
  /-- Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC -/
  projection : CameraProjection

inductive CameraMode where
  | custom
  | free
  | orbital
  | firstPerson
  | thridPerson

structure Color where
  /-- Color red value -/
  r : UInt8
  /-- Color green value -/
  g : UInt8
  /-- Color blue value -/
  b : UInt8
  /-- Color alpha value -/
  a : UInt8 := 255
  deriving BEq

namespace Color

def white       := { r:=255, g:=255, b:=255, a:=255 : Color }
def red         := { r:=255, g:=0, b:=0, a:=255 : Color }
def green       := { r:=0, g:=255, b:=0, a:=255 : Color }
def blue        := { r:=0, g:=0, b:=255, a:=255 : Color }
def yellow      := { r:=0, g:=255, b:=255, a:=255 : Color }
def black       := { r:=0, g:=0, b:=0, a:=255 : Color }
def magenta     := { r := 255, g := 0, b := 255, a := 255 : Color  }
def transparent := { r:=0, g:=0, b:=0, a:=0 : Color }

namespace Raylean

def lightgray  := { r := 200, g := 200, b := 200, a := 255 : Color  }
def gray       := { r := 130, g := 130, b := 130, a := 255 : Color  }
def darkgray   := { r := 80, g := 80, b := 80, a := 255 : Color  }
def yellow     := { r := 253, g := 249, b := 0, a := 255 : Color  }
def gold       := { r := 255, g := 203, b := 0, a := 255 : Color  }
def orange     := { r := 255, g := 161, b := 0, a := 255 : Color  }
def pink       := { r := 255, g := 109, b := 194, a := 255 : Color  }
def red        := { r := 230, g := 41, b := 55, a := 255 : Color  }
def maroon     := { r := 190, g := 33, b := 55, a := 255 : Color  }
def green      := { r := 0, g := 228, b := 48, a := 255 : Color  }
def lime       := { r := 0, g := 158, b := 47, a := 255 : Color  }
def darkgreen  := { r := 0, g := 117, b := 44, a := 255 : Color  }
def skyblue    := { r := 102, g := 191, b := 255, a := 255 : Color  }
def blue       := { r := 0, g := 121, b := 241, a := 255 : Color  }
def darkblue   := { r := 0, g := 82, b := 172, a := 255 : Color  }
def purple     := { r := 200, g := 122, b := 255, a := 255 : Color  }
def violet     := { r := 135, g := 60, b := 190, a := 255 : Color  }
def darkpurple := { r := 112, g := 31, b := 126, a := 255 : Color  }
def beige      := { r := 211, g := 176, b := 131, a := 255 : Color  }
def brown      := { r := 127, g := 106, b := 79, a := 255 : Color  }
def darkbrown  := { r := 76, g := 63, b := 47, a := 255 : Color  }
def raywhite   := { r := 245, g := 245, b := 245, a := 255 : Color  }

end Raylean

end Color

namespace Key

def space : Nat := 32
def right : Nat := 262
def left : Nat := 263
def down : Nat := 264
def up : Nat := 265

end Key

inductive MouseButton where
  | left
  | right
  | middle
  | side
  | extra
  | forward
  | back

private opaque Texture2DP : NonemptyType
def Texture2D := Texture2DP.type
instance : Nonempty Texture2D := Texture2DP.property

-- fields of Texture2D defined directly using a namespace must be in the same
-- namespace as Texture2D
@[extern "texture2d_width"]
opaque Texture2D.width (texture2d : @& Texture2D) : Nat

@[extern "texture2d_height"]
opaque Texture2D.height (texture2d : @& Texture2D) : Nat

private opaque ImageP : NonemptyType
def Image := ImageP.type
instance : Nonempty Image := ImageP.property

-- fields of Image defined directly using a namespace must be in the same
-- namespace as Image
@[extern "image_width"]
opaque Image.width (image : @& Image) : Nat

@[extern "image_height"]
opaque Image.height (image : @& Image) : Nat
