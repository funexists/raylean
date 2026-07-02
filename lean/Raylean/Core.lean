import Raylean.Types

namespace Raylean

open Raylean.Types

/- Window-related functions -/

@[extern "initWindow"]
opaque initWindow : (width : Nat) → (height : Nat) → (title : @& String) → IO Unit

@[extern "closeWindow"]
opaque closeWindow : IO Unit

@[extern "windowShouldClose"]
opaque windowShouldClose : IO Bool

@[extern "maximizeWindow"]
opaque maximizeWindow : IO Unit

@[extern "getScreenWidth"]
opaque getScreenWidth : IO Nat

@[extern "getScreenHeight"]
opaque getScreenHeight : IO Nat

@[extern "getWindowScaleDPI"]
opaque getWindowScaleDPI : IO Vector2

/- Cursor-related functions -/

@[extern "disableCursor"]
opaque disableCursor : IO Unit

/- Drawing-related functions -/

@[extern "clearBackground"]
opaque clearBackground : (c : @& Color) → IO Unit

@[extern "beginDrawing"]
opaque beginDrawing : IO Unit

@[extern "endDrawing"]
opaque endDrawing : IO Unit

@[extern "beginMode2D"]
opaque beginMode2D : (camera : @& Camera2D) → IO Unit

@[extern "endMode2D"]
opaque endMode2D : IO Unit

@[extern "beginMode3D"]
opaque beginMode3D : (camera : @& Camera3D) → IO Unit

@[extern "endMode3D"]
opaque endMode3D : IO Unit

@[extern "getWorldToScreen"]
opaque getWorldToScreen : (position : @& Vector3) → (camera : @& Camera3D) → IO Vector2

/- Timing-related functions -/

@[extern "setTargetFPS"]
opaque setTargetFPS : (fps : Nat) → IO Unit

@[extern "getFrameTime"]
opaque getFrameTime : IO Float

/- Input-related functions: keyboard -/

@[extern "isKeyDown"]
opaque isKeyDown : (key : Nat) → IO Bool

/- Input-related functions: mouse -/

@[extern "isMouseButtonPressed"]
opaque isMouseButtonPressed : (button : MouseButton) → IO Bool

@[extern "getMousePosition"]
opaque getMousePosition : IO Vector2

@[extern "getMouseWheelMove"]
opaque getMouseWheelMove : IO Float

/- Camera System Functions -/

@[extern "updateCamera"]
opaque updateCamera : (camera : Camera3D) → (mode : CameraMode) → IO Camera3D

/- Basic shapes drawing functions -/

@[extern "drawCircleV"]
opaque drawCircleV : (center : @& Vector2) → (radius : Float) → (color : @& Color) → IO Unit

@[extern "drawLineV"]
opaque drawLineV : (startPos : @& Vector2) → (endPos : @& Vector2) → (color : @& Color) → IO Unit

@[extern "drawLineStrip"]
opaque drawLineStrip : (points : @& Array Vector2) → (color : @& Color) → IO Unit

@[extern "drawRectangleRec"]
opaque drawRectangleRec : (rectangle : @& Rectangle) → (color : @& Color) → IO Unit

/- Basic shapes collision detection functions -/

@[extern "checkCollisionPointRec"]
opaque checkCollisionPointRec : (point : @& Vector2) → (rect : @& Rectangle) -> IO Bool

/- Screen-space-related functions -/

/-- Get the world space position for a 2d camera screen space position -/
@[extern "getScreenToWorld2D"]
opaque getScreenToWorld2D : (position : @& Vector2) → (camera : @& Camera2D) → Vector2

/- Text drawing functions -/

@[extern "drawFPS"]
opaque drawFPS : (posX : Nat) → (posY : Nat) → IO Unit

@[extern "drawText"]
opaque drawText : (text : @& String) → (posX : Nat) → (posY : Nat) → (fontSize : Nat) → (color : @& Color) → IO Unit

/- Basic geometric 3D shapes drawing functions -/

@[extern "drawLine3D"]
opaque drawLine3D : (startPos : @& Vector3) → (endPos : @& Vector3) → (color : @& Color) → IO Unit

@[extern "drawCube"]
opaque drawCube : (position : @& Vector3) → (width : Float) → (height : Float) → (length : Float) → (color : @& Color) -> IO Unit

-- This is also in Raylib but it's easier to just reimplement it here
def drawCubeV (position size : Vector3) (color : Color) :=
  drawCube position size.x size.y size.z color

@[extern "drawCubeWires"]
opaque drawCubeWires : (position : @& Vector3) → (width : Float) → (height : Float) → (length : Float) → (color : @& Color) -> IO Unit

def drawCubeWiresV (position size : Vector3) (color : Color) :=
  drawCubeWires position size.x size.y size.z color

@[extern "drawCylinderEx"]
opaque drawCylinderEx : (startPos : @& Vector3) → (endPos : @& Vector3) → (startRadius : Float) → (endRadius : Float) → (sides : Nat) → (color : @& Color) -> IO Unit

@[extern "drawGrid"]
opaque drawGrid : (slices : Nat) → (spacing : Float) → IO Unit

@[extern "loadImage"]
opaque loadImage : (resourceName : @& String) -> IO Image

@[extern "loadTextureFromImage"]
opaque loadTextureFromImage : (image : @& Image) -> IO Texture2D

@[extern "drawTexture"]
opaque drawTexture : (texture : @& Texture2D) -> (posX : Nat) -> (posY : Nat) -> (color : @& Color) -> IO Unit

/--
Source rectangle (part of the texture to use for drawing)
source defines the part of the texture we use for drawing
dest defines the rectangle where our texture part will fit (scaling it to fit)
origin defines the point of the texture used as reference for rotation and scaling, it's relative to destination rectangle size
rotation defines the texture rotation (using origin as rotation point)
-/
@[extern "drawTexturePro"]
opaque drawTexturePro : (texture : @& Texture2D) -> (source : @& Rectangle) -> (dest : @& Rectangle) -> (origin : @& Vector2) -> (rotation : Float) -> (tint : @& Color) -> IO Unit

@[extern "drawPixelV"]
opaque drawPixelV : (position : @& Vector2) -> (color : @& Color) -> IO Unit

@[extern "setConfigFlags"]
opaque setConfigFlags : (flags : UInt64) -> IO Unit

@[extern "setWindowState"]
opaque setWindowState : (flags : UInt64) -> IO Unit

namespace Flags

def windowResizable : UInt64 := 0x00000004
def vsyncHint : UInt64 := 0x00000040
def windowHighdpi : UInt64 := 0x00002000

end Flags
