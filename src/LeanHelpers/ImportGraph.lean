import Std

open System
open Std

def toModuleName (path: FilePath)(base: FilePath): String :=
  path.toString.drop (base.toString.length + 1)
    |>.replace "/" "."
    |>.replace ".lean" ""

def readImports(lines: List String): List String :=
  match lines with
  | [] => []
  | line :: lines' =>
    let line' := line.trim
    if line'.isEmpty ∨ line'.startsWith "#" then -- imports might follow
      readImports lines' else
    let keyword := "import "
    if line'.startsWith keyword then -- import
      line'.drop keyword.length :: readImports lines' else
    [] -- no imports anymore

def Graph := List (String × List String)

def getGraph (path: FilePath): IO Graph:= do
  let allFiles ← path.walkDir
    (return ·.fileName.map (!·.startsWith ".") |>.getD true) -- exclude folders starting with .
  let leanFiles := allFiles.filter
    (·.extension.map (·=="lean") |>.getD false) -- filter .lean files
  let graph ← leanFiles.mapM (λ path' => do
    let name := toModuleName path' path
    let handle ← IO.FS.Handle.mk path' IO.FS.Mode.read
    let content ← handle.readToEnd
    let imports := readImports (content.split (·='\n'))
    return (name, imports)
  )
  return graph.toList

def Graph.filter(graph: Graph): Graph :=
  graph.map (λ n => n.map id (λ prevs =>
    prevs.filter (λ prev =>
      true -- todo filter indirect and not part of project, trim path?
    )
  ))

def Graph.print(graph: Graph): String :=
  "digraph G {" ++ (
    List.flatMap (λ (n, prevs) =>
      s!"\"{n}\";" ::
      prevs.map (λ p =>
        s!"\"{p}\" -> \"{n}\";"
      )
    ) graph |>.foldl (s!"{·}\n{·}") ""
  ) ++ "\n}"

def genImportGraph'(path: FilePath)(out: FilePath): IO Unit := do
  let graph ← getGraph path
  let erg := graph.filter.print
  IO.FS.writeFile out erg

def main(args: List String): IO Unit :=
  let path := args.getD 0 "."
  let out  := args.getD 1 "out.dot"
  genImportGraph' path out

-- #eval return (← getGraph (mkFilePath ["."])).print
-- #eval return (←(mkFilePath ["."]).walkDir).filter (λ path:FilePath => path.extension.map (·=="lean") |>.getD false)
