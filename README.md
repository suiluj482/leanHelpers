# leanHelpers

> Unrelated Tip: 
Did you know you can lock tab groups in vscode, so that new tabs don't open in it? I find this very usefull when having the lean infoview open on the side.

## features

### import graph
> found better existing solution https://github.com/leanprover-community/import-graph

In big projects which file imports which (especially for testing) can get confusing. This small skript will help by generating a .dot file of the import structure that can be rendered using graphviz.
To generate the .dot file
```
import-graph projectSrcDir out.dot
```
Using graphviz to generate an image
```
dot -Tpng out.dot -o out.png
```

### generate All.lean files
In big projects you often want to import all files of a directory. Lean doesn't yet have a buildin function for this. 
So this skript will look throuhg the project and in it all All.lean files it finds it will add imports for all files in the current directory and all All.lean in a immediate subdirectory.
It will put this imports at the top of the file. Leaving everything behind a "---" in the file as is. It will also keep commented out imports commented out.
It will also ignore files and directories starting with a '.' or '-'.
```
gen-all projectSrcDir
```


## build
The helpers are written in Lean and build with nix
```
nix build
```

This results in executeables under result/bin/
