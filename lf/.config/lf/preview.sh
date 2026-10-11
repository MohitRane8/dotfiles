#!/bin/sh

# References:
# https://github1s.com/ericmurphyxyz/dotfiles/blob/master/.config/lf/lf_kitty_preview#L2-L6
# https://github1s.com/LukeSmithxyz/voidrice/blob/master/.config/lf/scope#L35

case "$(file --dereference --brief --mime-type -- "$1")" in
    # *.tar*) tar tf "$file" ;;
    # *.zip) unzip -l "$file" ;;
    # *.rar) unrar l "$file" ;;
	text/troff) man ./ "$1" | col -b ;;
	text/* | */xml | application/json | application/x-ndjson) bat --terminal-width "$(($4-2))" -f "$1" ;;
    application/octet-stream)
        # Preview .bin files as hex dump with hexyl
        if command -v hexyl > /dev/null 2>&1; then
            hexyl --block-size=512 --length=36block "$1"
        else
            xxd -g 4 "$1" | head -n 100 | bat --style=plain --paging=never
        fi
        ;;
esac
exit 1
