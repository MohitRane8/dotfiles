#!/bin/sh
# Define the file name to check
FILE="Session.vim"
# Check if the file exists in the current directory
if [ -f "$FILE" ]; then
    # If the file exists, open it with neovim using the -S option
    nvim -S "$FILE"
else
    # If the file does not exist, open neovim with all the user arguments
    nvim $@
fi
