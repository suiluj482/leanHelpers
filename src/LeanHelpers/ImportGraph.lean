import Std
import LeanHelpers.Utils

open System
open Std

def ImpGraph := List (String × List String)

def getImpGraph (path: FilePath): IO ImpGraph:= do
  let allFiles ← path.walkDir
    (return ·.fileName.map (!·.startsWith ".") |>.getD true) -- exclude folders starting with .
  let leanFiles := allFiles.filter
    (·.extension.map (·=="lean") |>.getD false) -- filter .lean files
  let impGraph ← leanFiles.mapM (λ path' => do
    return (
      path'.toModuleName path,
      ←readImports path'
    )
  )
  return impGraph.toList

def ImpGraph.filter(impGraph: ImpGraph): ImpGraph :=
  impGraph.map (λ n => n.map id (λ prevs =>
    prevs.filter (λ prev =>
      true -- todo filter indirect and not part of project, trim path?
    )
  ))

def ImpGraph.print(impGraph: ImpGraph): String :=
  "diimpGraph G {" ++ (
    List.flatMap (λ (n, prevs) =>
      s!"\"{n}\";" ::
      prevs.map (λ p =>
        s!"\"{p}\" -> \"{n}\";"
      )
    ) impGraph |>.foldLines
  ) ++ "\n}"

def genImportImpGraph'(path: FilePath)(out: FilePath): IO Unit := do
  let impGraph ← getImpGraph path
  let erg := impGraph.filter.print
  IO.FS.writeFile out erg

def main(args: List String): IO Unit :=
  let path := args.getD 0 "."
  let out  := args.getD 1 "out.dot"
  genImportImpGraph' path out

-- #eval return (← getImpGraph (mkFilePath ["."])).print
-- #eval return (←(mkFilePath ["."]).walkDir).filter (λ path:FilePath => path.extension.map (·=="lean") |>.getD false)
