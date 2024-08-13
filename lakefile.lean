import Lake
open System Lake DSL

package «lean-raylib» where
  srcDir := "lean"

lean_lib «Raylib» where
  precompileModules := true

lean_lib «Examples» where
  precompileModules := true

lean_lib «Lens»

@[default_target]
lean_exe «raylib-lean» where
  root := `Main
  moreLinkArgs :=
    #[ "lib/libraylib.a"
     , "lib/libresvg.a"
     , "-isysroot", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
     , "-framework", "IOKit"
     , "-framework", "Cocoa"
     , "-framework", "OpenGL"
     ]

target raylib_bindings.o pkg : FilePath := do
  let oFile := pkg.buildDir / "c" / "raylib_bindings.o"
  let includes := pkg.dir / "c" / "include"
  let srcJob ← inputTextFile <| pkg.dir / "c" / "raylib_bindings.c"
  let raylibInclude := pkg.dir / "raylib-5.0" / "src"
  let resvgInclude := pkg.dir / "resvg-0.43.0" / "crates" / "c-api"
  let weakArgs := #["-I", s!"{raylibInclude}", "-I", s!"{includes}", "-I", s!"{resvgInclude}"]
  buildLeanO oFile srcJob weakArgs #["-fPIC"]

extern_lib libleanffi pkg := do
  let ffiO ← raylib_bindings.o.fetch
  let name := nameToStaticLib "rayliblean"
  buildStaticLib (pkg.nativeLibDir / name) #[ffiO]
