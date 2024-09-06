import «Raylean»
import Examples

import Examples.Elab

namespace Selector

open Raylean
open Raylean.Types

/-- Demos supported in the selector --/
inductive Demo where
  | jessica
  | window
  | platformer2d
  | cube3d
  | inputKeys
  | basicECS

def Demo.all := allElements Demo

def stringToDemo (s : String) : Option Demo :=
  match s.trim.toLower with
  | "jessica" => some .jessica
  | "window" => some .window
  | "platformer2d" => some .platformer2d
  | "cube3d" => some .cube3d
  | "inputkeys" => some .inputKeys
  | "basicecs" => some .basicECS
  | _ => none

def screenWidth : Nat := 800
def optionHeight : Nat := 80
def screenHeight : Nat := Demo.all.size * optionHeight
def fps : Nat := 60
def textSize : Nat := 20
def lightSelectorColor : Color := Color.Raylean.blue
def darkSelectorColor : Color := Color.Raylean.darkblue
def selectorTextColor : Color := Color.black

structure DemoInfo where
  /-- The action that starts the demo --/
  start : IO Unit
  /-- The title that identifies the demo --/
  title : String

def mkDemoInfo : Demo -> DemoInfo
   | .window => {start := Window.window, title := "Basic window"}
   | .platformer2d => {start := Camera2DPlatformer.main, title := "2D Platformer"}
   | .cube3d => {start := Camera3D.camera3D, title := "3D Cube"}
   | .inputKeys => {start := InputKeys.inputKeys, title := "Input keys"}
   | .jessica => {start := JessicaCantSwim.main, title := "Jessica can't swim"}
   | .basicECS => {start := BasicECS.main, title := "Basic ECS"}

structure DemoRenderInfo where
  /-- The action that starts the demo --/
  start : IO Unit
  /-- The action that renders the demo selector --/
  render : IO Unit
  /-- An action that determines if the position has clicked the demo selector --/
  isClicked : Vector2 -> IO Bool

/-- Construct a DemoRenderInfo for each Demo --/
def demoRenderInfos : Array DemoRenderInfo :=
  let f {n : Nat} (idx : Fin n) (demo : Demo) :=
    let demoInfo := mkDemoInfo demo
    let yOffset := idx * optionHeight
    let rect : Rectangle :=
      { x := 0
      , y := yOffset.toFloat
      , width := screenWidth.toFloat
      , height := optionHeight.toFloat }
    let color := if idx.val % 2 == 0 then lightSelectorColor else darkSelectorColor
    let render := do
      drawRectangleRec rect color
      drawText demoInfo.title (Nat.div screenWidth 3) (yOffset + Nat.div optionHeight 2) textSize selectorTextColor
    let isClicked (pos : Vector2) := checkCollisionPointRec pos rect
    {start := demoInfo.start, render, isClicked}
  Demo.all.mapIdx f

/-- Start the selector --/
def start : IO Unit := do
  let mut launchDemo : Option (IO Unit) := none
  while not (← windowShouldClose) do
    if (← isMouseButtonPressed MouseButton.left) then do
      let pos ← getMousePosition
      launchDemo := DemoRenderInfo.start <$> (← demoRenderInfos.findM? (·.isClicked pos))
      if launchDemo.isSome then break

    renderFrame do
      clearBackground Color.green
      for i in demoRenderInfos do i.render
  closeWindow
  if let some start := launchDemo then start

def selector : IO Unit := do
  initWindow Selector.screenWidth Selector.screenHeight "Select a demo"
  setTargetFPS 60
  start

/-- Directly launch a demo by name, otherwise start the selector --/
def tryLaunchDemo (name : String) : IO Unit :=
  match stringToDemo name with
  | none => selector
  | some d => mkDemoInfo d |>.start

end Selector
