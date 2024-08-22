import Raylib.Types

import Examples.JessicaCantSwim.Types

namespace Collision

-- detect if there is a collision between two rectangles
private def detect(rect1: Rectangle) (rect2: Rectangle): Bool :=
  rect1.x < rect2.x + rect2.width &&
  rect1.x + rect1.width > rect2.x &&
  rect1.y < rect2.y + rect2.height &&
  rect1.y + rect1.height > rect2.y

def detects {ModelID: Type} (entities: List (ModelID × List Rectangle)): Id (List (ModelID × ModelID)) := do
  let mut collisions := #[]
  for src in entities do
    for dst in entities do
      for srcBound in src.2 do
        for dstBound in dst.2 do
          if detect srcBound dstBound then
            collisions := collisions.push (src.1, dst.1)
  return collisions.toList

def detectCollisions (msgs: List Types.Msg) : (List Types.Msg) :=
  let idBoxPairs := List.filterMap (λ msg =>
    match msg with
    | Types.Msg.Bounds id boxes =>
      Option.some (id, boxes)
    | _otherwise =>
      Option.none
  ) msgs
  let collisions := detects idBoxPairs
  List.map (λ collision => Types.Msg.Collision collision.1 collision.2) collisions

end Collision
