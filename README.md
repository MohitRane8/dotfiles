# dotfiles

## Installing
Install using GNU Stow

Clone into you `$HOME` directory or `~`

`git clone git@github.com:MohitRane8/dotfiles.git`

Run `stow` to symlink everything or just select what you want

`stow --target=${HOME} */ # Everything (the '/' ignores the README)`

`stow --target=${HOME} zsh # Just the zsh config`


After installing zsh from dotfiles, run the following without sudo:

`chsh -s $(which zsh)`

To go back to using bash, do:

`chsh -s /bin/bash`


Create the following directory for zsh to save history ($XDG_DATA_HOME value is present in ~/.zprofile):
`mkdir $XDG_DATA_HOME/zsh`

