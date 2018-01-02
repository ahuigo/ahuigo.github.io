# todo
http://flight-manual.atom.io/

# File

## clipboard
copy to the relative path is better.
https://github.com/bigyuki/markdown-image-helper
https://github.com/noizbuster/img-paste/blob/master/lib/img-paste.coffee
upload
https://github.com/sagaraya/image-copipe/blob/master/lib/image-copipe.coffee

## filePath

  editor = atom.workspace.getActivePaneItem()
  file = editor?.buffer.file
  filePath = file?.path

# debug
`alt-cmd-I`

## reload
When working on packages locally, here's the recommended workflow:

  # Clone your package from GitHub using
  apm develop <package-name> #This will clone the package's repo to your local ~/.atom/dev/packages/<package-name>
  cd into this directory
  #Start Atom in this directory using:
  atom -d .

Now you can work on the package, make changes, etc.
Once you're ready to reload, you can use `View > Reload` to restart Atom with the changed package.

If you have your package sources locally on your machine, you can skip the first step (apm develop) and simply create a symbolic link from your sources to `~/.atom/dev/packages/<package-name>`
