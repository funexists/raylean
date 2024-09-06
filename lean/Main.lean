import «Examples».Selector

def main (args : List String) : IO Unit := do
  match args with
  | (demoName :: _) => Selector.tryLaunchDemo demoName
  | _ => Selector.selector
