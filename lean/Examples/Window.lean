import «Raylib»

namespace Window

def render : IO Unit := do
  while not (← windowShouldClose) do
    renderFrame do
      drawFPS 100 100
      clearBackground Color.green
      let c := match (← IO.rand 0 6) with
      | 0 => Color.red
      | 1 => Color.green
      | 2 => Color.red
      | _ => Color.black
      drawText "Hello From Lean!" 190 200 50 c
  closeWindow

def window : IO Unit := do
  initWindow 800 450 "Hello From Lean!"
  setTargetFPS 60
  render

end Window
