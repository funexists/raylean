import Lake
open System Lake DSL

def optionUseBundle : Bool := get_config? bundle == some "on"

def optionDisableResvg : Bool := get_config? resvg == some "disable"

require batteries from git "https://github.com/leanprover-community/batteries.git" @ "v4.20.0"

require «lens-demo» from git "https://github.com/funexists/lens-demo.git" @ "c0121c73d85ae3539add5b69b3345123ac4606e1"

package «raylean» where
  srcDir := "lean"

lean_lib «Raylean» where
  precompileModules := true

lean_lib «Examples» where
  precompileModules := true

@[default_target]
lean_exe «raylean» where
  root := `Main
  moreLinkArgs := Id.run do
    let mut args := #[ "lib/libraylib.a"]
    if not optionDisableResvg then
      args := args ++ #["lib/libresvg.a"]
    if (← System.Platform.isOSX) then
      args := args ++
        #[ "-isysroot", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
         , "-framework", "IOKit"
         , "-framework", "Cocoa"
         , "-framework", "OpenGL"
         ]
    args

target raylib_bindings.o pkg : FilePath := do
  let oFile := pkg.buildDir / "c" / "raylib_bindings.o"
  let includes := pkg.dir / "c" / "include"
  let srcJob ← inputTextFile <| pkg.dir / "c" / "raylib_bindings.c"
  let raylibInclude := pkg.dir / "raylib-5.0" / "src"
  let resvgInclude := pkg.dir / "resvg-0.43.0" / "crates" / "c-api"
  let weakArgs := #["-I", s!"{raylibInclude}", "-I", s!"{includes}", "-I", s!"{resvgInclude}"]
  let mut traceArgs := #["-fPIC"]
  if optionDisableResvg then
    traceArgs := traceArgs ++ #["-DRAYLEAN_NO_RESVG"]
  if not (optionUseBundle) then
    traceArgs := traceArgs ++ #["-DRAYLEAN_NO_BUNDLE"]
  buildLeanO oFile srcJob weakArgs traceArgs

extern_lib libleanffi pkg := do
  let ffiO ← raylib_bindings.o.fetch
  let name := nameToStaticLib "rayliblean"
  buildStaticLib (pkg.staticLibDir / name) #[ffiO]
