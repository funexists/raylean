import Lean

open Lean Elab Command Term Meta

--- Generate an array of all elements of an inductive type.
--- This only works when all constructors of the type are unary.
elab "allElements " indTy:ident : term => do
  let indName ← resolveGlobalConstNoOverload indTy
  let indVal ← getConstInfoInduct indName
  for ctor in indVal.ctors do
    if (← getConstInfoCtor ctor).numFields != 0
      then throwError "Types with non-unary constructors are not supported"
  let ctorVals ← List.mapM mkConst indVal.ctors
  mkArrayLit (mkConst indName) ctorVals

