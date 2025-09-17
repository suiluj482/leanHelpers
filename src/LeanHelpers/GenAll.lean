import Std
import LeanHelpers.Utils
import LeanHelpers.Utils

open System
open Std

-- todo:
-- - subfolders All files?
-- - ignore commented out imports
-- - ignore code under imports

partial def genAll(path: FilePath)(pre: String): IO (List String) := do
  if !(←path.isDir) then pure [] else
  let files := (←path.readDir).toList

  -- update subdirectories if they arent hidden
  let subfoldersImp ← files.filter (λ f =>
      !(f.fileName.startsWith "." ∨ f.fileName.startsWith "-")
    )
    |>.flatMapM (λ f => genAll f.path (
      s!"{pre}{if pre.isEmpty then "" else "."}{f.fileName}"
    ))

  -- update All.lean if present
  match files.find? (·.fileName == "All.lean") with
  | none => return []
  | some allFile =>
    let pSep := "---" -- persistend Seperator
    let extension := ".lean"

    let allPath := allFile.path
    let (lines, rest) ← readLeanImports allPath
    let uncommented := filterUncommentedImports lines
    let (_, restLines) := lines.span (!·.startsWith pSep)

    let files ← files.filterM (do let b ← ·.path.isDir; return !b)
    let content := files
      |>.map (·.fileName)
      |>.filter (λ f =>
          f.endsWith extension
          ∧ f≠"All.lean"
          ∧ !f.startsWith "-" ∧ !f.startsWith "."
        )
      |>.map (s!"{pre}.{toModuleName ·}")
      |>.append subfoldersImp
      |>.map (λ s =>
          (if uncommented.contains s then "-- " else "")
          ++ s!"import {s}"
        )
      |>.foldLines

    writeFile allPath (
        content ++ "\n"
        ++ restLines.foldLines ++ "\n"
        ++ rest
      )
    return [ s!"{pre}.All" ]


def main(args: List String): IO Unit := do
  IO.println s!"workingdir: {(←IO.Process.getCurrentDir).addExtension (args.getD 0 "")}"

  let path := args.getD 0 "."
  let _ ← genAll path ""
  return ()

-- #eval genAll "." ""
-- #eval readImports "LeanHelpers/Test/All.lean"
-- #eval readUncommentedImports "LeanHelpers/Test/All.lean"
