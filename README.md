# dotfiles

## Installing
Install using GNU Stow

Clone into you `$HOME` directory or `~`

`git clone git@github.com:MohitRane8/dotfiles.git`

Run `stow` to symlink everything or just select what you want

`stow --target=${HOME} */ # Everything (the '/' ignores the README)`

`stow --target=${HOME} zsh # Just the zsh config`

