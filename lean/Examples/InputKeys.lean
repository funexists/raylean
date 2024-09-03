import «Raylean»

namespace InputKeys

private def screenWidth : Nat := 800
private def screenHeight : Nat := 450

private def initialBallPosition : Vector2 := { x := screenWidth.toFloat / 2, y := screenHeight.toFloat / 2 }

private inductive Move where
 | up
 | down
 | left
 | right
 | stay

private def updateBallPosition (d : Move) (p : Vector2) : Vector2 := match d with
  | Move.right => { p with x := p.x + 2.0 }
  | Move.left => { p with x := p.x - 2.0 }
  | Move.up => { p with y := p.y - 2.0 }
  | Move.down => { p with y := p.y + 2.0 }
  | Move.stay => p

private def getMove : IO Move := do
  if (← isKeyDown Key.right) then return Move.right
     else if (← isKeyDown Key.left) then return Move.left
     else if (← isKeyDown Key.up) then return Move.up
     else if (← isKeyDown Key.down) then return Move.down
     else return Move.stay

private def doRender : IO Unit := do
  let mut ballPosition := initialBallPosition
  while not (← windowShouldClose) do
    let d ← getMove
    ballPosition := updateBallPosition d ballPosition
    renderFrame do
      drawFPS (screenWidth - 100) 10
      clearBackground Color.white
      drawText "Move the ball with arrow keys" 10 10 20 Color.blue
      drawCircleV ballPosition 50 Color.red
  closeWindow

def inputKeys : IO Unit := do
  initWindow 800 450 "keyboard input"
  setTargetFPS 60
  doRender

end InputKeys
