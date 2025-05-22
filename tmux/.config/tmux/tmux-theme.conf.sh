#!/bin/sh

# accent_color="#55ad74"
accent_color="#9e4b44"
dot_color="#c4b049"

# UTF symbols:
# 1. https://www.nerdfonts.com/cheat-sheet
# 2. https://shapecatcher.com/

# Style 1
tmux set -g status-style "bg=default"
tmux set -g status-left "#[fg=${accent_color},bg=black]#[fg=black,bg=${accent_color}]  #S  #[fg=${accent_color},bg=black]"
tmux set -g status-right "#[fg=white,bg=default]   %m/%d   #[fg=${accent_color},bg=black]#[fg=black,bg=${accent_color}]  %H:%M  #[fg=${accent_color},bg=black]"
tmux set -g window-status-separator "#[fg=${dot_color},bg=default]  ●  "
tmux setw -g window-status-format "#[fg=white,bg=default]   #W   "
tmux setw -g window-status-current-format "#[fg=${accent_color},bg=black]#[fg=black,bg=${accent_color}]  #W  #[fg=${accent_color},bg=black]"
