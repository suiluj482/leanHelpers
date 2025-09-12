# leanHelpers

## features

### import graph
> found better existing solution https://github.com/leanprover-community/import-graph

In big projects which file imports which (especially for testing) can get confusing. This small skript will help by generating a .dot file of the import structure that can be rendered using graphviz.
To generate the .dot file
```
import-tools projectSrcDir out.dot
```
Using graphviz to generate an image
```
dot -Tpng out.dot -o out.png
```

### generate All.lean files
In big projects you often want to import all files of a directory. Lean doesn't yet have a buildin function for this. 
So this skript will look throuhg the project, and replace the content of every All.lean file with imports to all files in its directory.
```
gen-all projectSrcDir
```

## build
The helpers are written in Lean and build with nix
```
nix build
```

This results in executeables under result/bin/
