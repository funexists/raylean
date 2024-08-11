structure FileData where
  filename : String
  data : ByteArray

structure ResourceInfo where
  filename : String
  offset : Nat
  size : Nat

structure ResourcesInfo where
  allData : ByteArray
  resources : Array ResourceInfo

open IO.FS

def readFile (entry : DirEntry) : IO FileData := do
  return {filename := entry.fileName, data := (← readBinFile entry.path)}

def readFilesFromDir (dir : String) : IO (Array FileData) := do
  (← System.FilePath.readDir dir).mapM readFile

def mkResourcesInfo (ds : Array FileData) : ResourcesInfo := Id.run do
  let mut allData := ByteArray.empty
  let mut resources := #[]
  for d in ds do
    resources := resources.push {filename := d.filename, offset := allData.size, size := d.data.size}
    -- Push an extra 0 so that a pointer at the offset can be used as a C string.
    -- This is useful for text resources like SVG.
    allData := (allData.append d.data).push 0
  return {allData, resources}

def hexEncodeByte (b : UInt8) : String :=
    let go (b : UInt8) : Char :=
        if b = 0 then '0' else
        if b = 1 then '1' else
        if b = 2 then '2' else
        if b = 3 then '3' else
        if b = 4 then '4' else
        if b = 5 then '5' else
        if b = 6 then '6' else
        if b = 7 then '7' else
        if b = 8 then '8' else
        if b = 9 then '9' else
        if b = 0xa then 'A' else
        if b = 0xb then 'B' else
        if b = 0xc then 'C' else
        if b = 0xd then 'D' else
        if b = 0xe then 'E' else
        if b = 0xf then 'F' else
        '*'
    let hi := go <| b >>> 4
    let low := go <| b &&& 0xF
    s!"0x{hi}{low}"

def List.splitAt (n : Nat) (ls : List α) : List α × List α :=
  (ls.take n, ls.drop n)

unsafe
def List.repeatedly (f : List α → (β × List α)) (ls : List α) : List β :=
  match ls with
    | [] => []
    | xs =>
      let (b, xs') := f xs
      b :: repeatedly f xs'

unsafe
def List.chunksOf (n : Nat) (ls : List α) : List (List α) :=
  match n with
  | 0 => panic! "Cannot call chunksOf with zero"
  | n => ls.repeatedly (List.splitAt n)

unsafe
def generateDataCode (ba : ByteArray) : String :=
  let byteStrings := ba.toList.map hexEncodeByte
  let lines := byteStrings.chunksOf 20
  let joinedLines := lines.map (fun line => "    " ++ (String.intercalate ", " line) ++ ",")
  "static const unsigned char bundle_data[] = {\n" ++ String.intercalate "\n" joinedLines ++ "\n};\n"

def generateResourceInfoSize (s : Nat) :=
  s!"size_t resources_size = {s};\n"

def generateResourceInfoCode (rs : Array ResourceInfo) : String :=
  let lines := rs.map (fun info => "    {.filename = \"" ++ info.filename ++ "\", .offset = " ++ info.offset.repr ++ ", .size = " ++ info.size.repr ++ "},")
  "static const ResourceInfo resource_infos[" ++ rs.size.repr ++ "] = {\n" ++ String.intercalate "\n" lines.toList ++ "\n};\n"

unsafe
def assembleBundleFile (r : ResourcesInfo) : String :=
  let struct := "typedef struct {\n    const char* filename;\n    size_t offset;\n    size_t size;\n} ResourceInfo;\n"
  let infos := generateResourceInfoCode r.resources
  let data := generateDataCode r.allData
  s!"#ifndef BUNDLE_H\n#define BUNDLE_H\n\n#include <stddef.h>\n\n{struct}\n{infos}\n{data}#endif // BUNDLE_H\n"

unsafe
def main (args : List String) : IO Unit := do
  let [dir, output] := args
    | IO.println "Usage: makeBundle <directory> <outputfile>"
  let ri := mkResourcesInfo (← readFilesFromDir dir)
  writeFile output (assembleBundleFile ri)
