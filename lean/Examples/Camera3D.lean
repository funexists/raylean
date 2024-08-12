import «Raylib»

namespace Camera3D

private def screenWidth : Nat := 1000
private def screenHeight : Nat := 600
private def fps : Nat := 120

private def cubePosition : Vector3 := { x := 0, y := 0, z := 0 : Vector3 }

private def doRender : IO Unit := do
  let mut camera : Camera3D := {
    position := { x := 10, y := 10, z := 10 },
    target := { x := 0, y := 0, z := 0 },
    up := { x := 0, y := 1, z := 0 },
    fovy := 45,
    projection := CameraProjection.perspective
  }
  disableCursor
  while not (← windowShouldClose) do
    camera <- updateCamera camera CameraMode.thridPerson
    if (<- isKeyDown Key.space) then
      camera := { camera with target := cubePosition }
    renderFrame do
      clearBackground Color.white
      renderWithCamera camera do
        drawCube cubePosition 2 2 2 Color.red
        drawCubeWires cubePosition 2 2 2 Color.blue
        drawGrid 10 1
      drawFPS (screenWidth - 100) 10
      drawText "Welcome to the third dimension" 10 40 20 Color.black

def camera3D : IO Unit := do
  initWindow screenWidth screenHeight "Camera3D"
  setTargetFPS fps
  doRender

end Camera3D
