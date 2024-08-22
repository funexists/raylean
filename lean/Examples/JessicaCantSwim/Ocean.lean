import «Raylib»
import Raylib.Types

import Examples.JessicaCantSwim.Entity

namespace Ocean

structure Ocean where
  private maxWidth: Float
  private height: Float
  private gravity: Float
  private width: Float
  private speed: Float
  private resetting: Bool
  private pulledback: Bool

def init (maxWidth: Nat) (height: Nat) : Ocean :=
  {
    width := 0,
    maxWidth := maxWidth.toFloat,
    height := height.toFloat,
    speed := 100,
    gravity := 9.8,
    resetting := false
    pulledback := false
  }

def Ocean.id (_entity: Ocean): Entity.ID :=
  Entity.ID.Ocean

private def Ocean.box (ocean: Ocean): Rectangle :=
  {
    x := ocean.maxWidth - ocean.width,
    y := 0,
    width := ocean.width,
    height := ocean.height,
  }

def Ocean.emit (entity: Ocean): List Entity.Msg :=
  if entity.speed < 0 && !entity.pulledback
  then [
    Entity.Msg.Bounds entity.id [entity.box],
    Entity.Msg.OceanPullingBack entity.width
  ]
  else if entity.resetting
  then [ Entity.Msg.RequestRand entity.id 100 ]
  else [ Entity.Msg.Bounds entity.id [entity.box] ]

def Ocean.update (ocean: Ocean) (msg: Entity.Msg): Id Ocean := do
  match msg with
  | Entity.Msg.ResponseRand Entity.ID.Ocean r =>
    if ocean.resetting
    then return {
      resetting := false,
      maxWidth := ocean.maxWidth,
      height := ocean.height,
      gravity := ocean.gravity,
      width := 0,
      speed := r.toFloat,
      pulledback := false,
    }
    else ocean
  | Entity.Msg.OceanPullingBack _ =>
    -- Don't send this twice
    return { ocean with
      pulledback := true
    }
  | Entity.Msg.Time delta =>
    let move := ocean.speed * delta
    let width := ocean.width + move
    let speed := ocean.speed - ocean.gravity * delta
    {
      resetting := width < 0
      maxWidth := ocean.maxWidth,
      height := ocean.height,
      gravity := ocean.gravity,
      width := width,
      speed := speed,
      pulledback := ocean.pulledback,
    }
  | _otherwise =>
    ocean

def Ocean.render (ocean: Ocean): IO Unit := do
  let rect: Rectangle := ocean.box
  drawRectangleRec rect Color.blue

instance : Entity.Entity Ocean where
  emit := Ocean.emit
  update := Ocean.update
  render := Ocean.render

end Ocean
