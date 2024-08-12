import «Raylib».Types

/- Window-related functions -/

@[extern "initWindow"]
opaque initWindow : (width : Nat) → (height : Nat) → (title : @& String) → IO Unit

@[extern "closeWindow"]
opaque closeWindow : IO Unit

@[extern "windowShouldClose"]
opaque windowShouldClose : IO Bool

/- Cursor-related functions -/

@[extern "disableCursor"]
opaque disableCursor : IO Unit

/- Drawing-related functions -/

@[extern "clearBackground"]
opaque clearBackground : (c : Color) → IO Unit

@[extern "beginDrawing"]
opaque beginDrawing : IO Unit

@[extern "endDrawing"]
opaque endDrawing : IO Unit

@[extern "beginMode2D"]
opaque beginMode2D : (camera : Camera2D) → IO Unit

@[extern "endMode2D"]
opaque endMode2D : IO Unit

@[extern "beginMode3D"]
opaque beginMode3D : (camera : Camera3D) → IO Unit

@[extern "endMode3D"]
opaque endMode3D : IO Unit

/- Timing-related functions -/

@[extern "setTargetFPS"]
opaque setTargetFPS : (fps : Nat) → IO Unit

@[extern "getFrameTime"]
opaque getFrameTime : IO Float

/- Random values generation functions -/

@[extern "getRandomValue"]
opaque getRandomValue : UInt32 → UInt32 → IO UInt32

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
opaque drawCircleV : (center : Vector2) → (radius : Float) → (color : Color) → IO Unit

@[extern "drawRectangleRec"]
opaque drawRectangleRec : (rectangle : Rectangle) → (color : Color) → IO Unit

/- Basic shapes collision detection functions -/

@[extern "checkCollisionPointRec"]
opaque checkCollisionPointRec : (point : Vector2) → (rect : Rectangle) -> IO Bool

/- Screen-space-related functions -/

/-- Get the world space position for a 2d camera screen space position -/
@[extern "getScreenToWorld2D"]
opaque getScreenToWorld2D : (position : Vector2) → (camera : Camera2D) → Vector2

/- Text drawing functions -/

@[extern "drawFPS"]
opaque drawFPS : (posX : Nat) → (posY : Nat) → IO Unit

@[extern "drawText"]
opaque drawText : (text : @& String) → (posX : Nat) → (posY : Nat) → (fontSize : Nat) → (color : Color) → IO Unit

/- Basic geometric 3D shapes drawing functions -/

@[extern "drawCube"]
opaque drawCube : (position : Vector3) → (width : Float) → (height : Float) → (length : Float) → (color : Color) -> IO Unit

@[extern "drawCubeWires"]
opaque drawCubeWires : (position : Vector3) → (width : Float) → (height : Float) → (length : Float) → (color : Color) -> IO Unit

@[extern "drawGrid"]
opaque drawGrid : (slices : Nat) → (spacing : Float) → IO Unit

@[extern "image_width"]
opaque Image.width (image : @& Image) : Nat

@[extern "image_height"]
opaque Image.height (image : @& Image) : Nat
@[extern "loadImage"]
opaque loadImage : (resourceName : @& String) -> IO Image

@[extern "texture2d_width"]
opaque Texture2D.width (texture2d : @& Texture2D) : Nat

@[extern "texture2d_height"]
opaque Texture2D.height (texture2d : @& Texture2D) : Nat

@[extern "loadTextureFromImage"]
opaque loadTextureFromImage : (image : @& Image) -> IO Texture2D

@[extern "drawTexture"]
opaque drawTexture : (texture : @& Texture2D) -> (posX : Nat) -> (posY : Nat) -> (color : Color) -> IO Unit

/--
Source rectangle (part of the texture to use for drawing)
source defines the part of the texture we use for drawing
dest defines the rectangle where our texture part will fit (scaling it to fit)
origin defines the point of the texture used as reference for rotation and scaling, it's relative to destination rectangle size
rotation defines the texture rotation (using origin as rotation point)
-/
@[extern "drawTexturePro"]
opaque drawTexturePro : (texture : @& Texture2D) -> (source : Rectangle) -> (dest : Rectangle) -> (origin : Vector2) -> (rotation : Float) -> (tint : Color) -> IO Unit
