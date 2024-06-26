#!/bin/sh
# Define the file name to check
FILE="Session.vim"

if [ $# -eq 0 ]; then
    # If the session file exists, open it with neovim using the -S option
    if [ -f "$FILE" ]; then
        nvim -S "$FILE"
    else
        nvim
    fi
else
    # If the file does not exist, open neovim with all the user arguments
    nvim $@
fi
