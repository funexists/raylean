import «Raylean»

namespace Window

open Raylean.Types
open Raylean.Graphics2D
open Raylean

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
  let rectangle := .rectangle 10 10 |> .color Color.red |> .scale ⟨20,20⟩
  let circle := (.circle 100 |> .color Color.blue |> .scale ⟨0.5, 0.5⟩)
  let line :=  .line #[⟨100, 100⟩, ⟨200, 200⟩] |> .color Color.black
  let p : Picture := line ++ (rectangle ++ circle |> .translate ⟨250, -50⟩ |> .scale ⟨1, 2⟩)

  while not (← windowShouldClose) do
    renderFrame do
      renderPicture screenWidth.toFloat screenHeight.toFloat p
      clearBackground Color.Raylean.gold
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
