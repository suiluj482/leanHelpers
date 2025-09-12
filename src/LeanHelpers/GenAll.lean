import Std

open System
open Std

partial def genAll(path: FilePath)(pre: String): IO Unit := do
  if !(←path.isDir) then pure () else
  let files ← path.readDir

  -- update All.lean if present
  match files.find? (·.fileName == "All.lean") with
  | none => pure ()
  | some allFile =>
    let extension := ".lean"
    let content := files
      |>.map    (·.fileName)
      |>.filter (λ f => f.endsWith  extension ∧ f≠"All.lean")
      |>.map    (·.dropRight extension.length
                |>.replace "/" ".")
      |>.map    (s!"import {pre}.{·}")
      |>.foldl  (s!"{·}\n{·}") ""
      |>.drop 1
    IO.FS.writeFile allFile.path content

  -- update subdirectories if they arent hidden
  let _ ← files.filter (! ·.fileName.startsWith ".")
    |>.mapM (λ f => genAll f.path (
      s!"{pre}{if pre.isEmpty then "" else "."}{f.fileName}"
    ))

  return ()

def main(args: List String): IO Unit := do
  IO.println s!"workingdir: {(←IO.Process.getCurrentDir).addExtension (args.getD 0 "")}"

  let path := args.getD 0 "."
  genAll path ""
