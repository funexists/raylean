import «Raylib»

namespace Window

def screenWidth : Nat := 800
def screenHeight : Nat := 600

def render : IO Unit := do
  let texture ← loadTextureFromImage (← loadImage "resources/Asset.svg")
  let sourceRect : Rectangle :=
    { x := 0
    , y := 0
    , width := texture.width.toFloat
    , height := texture.height.toFloat
    }
  let destRect : Rectangle :=
    { x := screenWidth.toFloat / 2 - texture.width.toFloat / 2
    , y := screenHeight.toFloat / 2
    , width := texture.width.toFloat
    , height := texture.height.toFloat
    }
  let origin : Vector2 := ⟨0, 0⟩
  let rotation : Float := 0

  while not (← windowShouldClose) do
    renderFrame do
      clearBackground Color.Raylib.gold
      drawFPS 100 100
      let c := match (← IO.rand 0 6) with
      | 0 => Color.red
      | 1 => Color.green
      | 2 => Color.red
      | _ => Color.black
      drawText "Hello From Lean!" 190 200 50 c
      drawTexturePro texture sourceRect destRect origin rotation Color.white
  closeWindow

def window : IO Unit := do
  initWindow screenWidth screenHeight "Hello From Lean!"
  setTargetFPS 60
  render

end Window
