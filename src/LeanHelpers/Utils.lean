import Std

open System
open Std

def System.FilePath.toModuleName (path: FilePath)(base: FilePath): String :=
  path.toString.drop (base.toString.length + 1)
    |>.dropRight ".lean".length
    |>.replace "/" "."

def toModuleName (pathS: String): String :=
  pathS
    |>.dropRight ".lean".length
    |>.replace "/" "."

def readFile (path: FilePath): IO String := do
  let handle ← IO.FS.Handle.mk path IO.FS.Mode.read
  handle.readToEnd

def writeFile (path: FilePath)(content: String): IO Unit :=
  IO.FS.writeFile path content

def String.dropAfter (s: String)(sep: String) :=
  s.splitOn sep |>.head!

def String.trimLine (line: String): String :=
  line.dropAfter "--"

def List.foldLines: List String → String :=
  (·.foldl (s!"{·}\n{·}") "" |>.drop 1)

def String.filterPrefix(s: String)(pre: String): Option String :=
  if s.startsWith pre then
    some (s.drop pre.length)
  else
    none

def readLeanImports(path: FilePath): IO ((List String) × String) := do
  let content ← readFile path
  let lines := content.splitOn "\n"
  let (imports, rest) := lines.span (λ l =>
    let l := l.trimLine
    l.startsWith "import"
    || l.startsWith "-- import"
    || l.isEmpty
    || l.startsWith "--"
  )
  return (imports, rest.foldLines)

def filterImports(lines: List String): List String :=
  lines.map (·.trimLine) |>.filterMap (·.filterPrefix "import ")

def filterUncommentedImports(lines: List String): List String :=
  lines.filterMap (·.filterPrefix "-- import " |>.map (·.trimLine))

def readImports(path: FilePath): IO (List String) := do
  return (←(readLeanImports path)).fst |> filterImports

def readUncommentedImports(path: FilePath): IO (List String) := do
  return (←(readLeanImports path)).fst |> filterUncommentedImports
