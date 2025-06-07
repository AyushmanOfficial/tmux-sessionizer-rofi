#!/usr/bin/env bash

#   _____                                            
#  |_   _|                                           
#    | |_ __ ___  _   ___  __                        
#    | | '_ ` _ \| | | \ \/ /                        
#    | | | | | | | |_| |>  <                         
#    \_/_| |_| |_|\__,_/_/\_\                        
#                                                    
#                                                    
#   _____               _             _              
#  /  ___|             (_)           (_)             
#  \ `--.  ___  ___ ___ _  ___  _ __  _ _______ _ __ 
#   `--. \/ _ \/ __/ __| |/ _ \| '_ \| |_  / _ \ '__|
#  /\__/ /  __/\__ \__ \ | (_) | | | | |/ /  __/ |   
#  \____/ \___||___/___/_|\___/|_| |_|_/___\___|_|   
#                                                    
#                                                    
#  ______          ______       __ _                 
#  |  ___|         | ___ \     / _(_)                
#  | |_ ___  _ __  | |_/ /___ | |_ _                 
#  |  _/ _ \| '__| |    // _ \|  _| |                
#  | || (_) | |    | |\ \ (_) | | | |                
#  \_| \___/|_|    \_| \_\___/|_| |_|                
#                                                    
#                                                    

ROOT_DIR="${HOME}/Documents/Dev/Projects"

sanity_check() {
    command -v tmux >/dev/null 2>&1 || { echo "tmux not found. Install it first."; exit 1; }
    command -v rofi >/dev/null 2>&1 || { echo "rofi not found. Install it first."; exit 1; }
    command -v alacritty >/dev/null 2>&1 || { echo "alacritty not found. Install it first."; exit 1; }
}

switch_to() {
    if [[ -z $TMUX ]]; then
        # Outside tmux, spawn new terminal running tmux attach
        alacritty -e tmux attach-session -t "$1"
    else
        # Inside tmux, just switch client
        tmux switch-client -t "$1"
    fi
}

has_session() {
    tmux list-sessions | grep -q "^$1:"
}

hydrate() {
    if [[ -f "$2/.tmux-sessionizer" ]]; then
        tmux send-keys -t "$1" "source $2/.tmux-sessionizer" C-m
    elif [[ -f "$ROOT_DIR/.tmux-sessionizer" ]]; then
        tmux send-keys -t "$1" "source $ROOT_DIR/.tmux-sessionizer" C-m
    fi
}

sanity_check

# Defaults if not set
[[ -n "$TS_SEARCH_PATHS" ]] || TS_SEARCH_PATHS=(
    "$ROOT_DIR"
    "$ROOT_DIR/personal"
    "$ROOT_DIR/personal/dev/env/.config"
)

if [[ ${#TS_EXTRA_SEARCH_PATHS[@]} -gt 0 ]]; then
    TS_SEARCH_PATHS+=("${TS_EXTRA_SEARCH_PATHS[@]}")
fi

find_dirs() {
    # Show TMUX sessions, excluding current if inside TMUX
    if [[ -n "$TMUX" ]]; then
        current_session=$(tmux display-message -p '#S')
        tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null | grep -vFx "[TMUX] $current_session"
    else
        tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null
    fi

    for entry in "${TS_SEARCH_PATHS[@]}"; do
        if [[ "$entry" =~ ^([^:]+):([0-9]+)$ ]]; then
            path="${BASH_REMATCH[1]}"
            depth="${BASH_REMATCH[2]}"
        else
            path="$entry"
            depth="${TS_MAX_DEPTH:-1}"
        fi

        [[ -d "$path" ]] && find "$path" -mindepth 1 -maxdepth "$depth" -path '*/.git' -prune -o -type d -print
    done
}

# Get selection
if [[ $# -eq 1 ]]; then
    selected="$1"
else
    selected=$(find_dirs | rofi -dmenu -i -p "tmux session" -theme ~/.config/rofi/tmux/style.rasi) || exit 0
fi

[[ -z "$selected" ]] && exit 0

# Extract session name if TMUX session format
if [[ "$selected" =~ ^\[TMUX\]\ (.+)$ ]]; then
    selected="${BASH_REMATCH[1]}"
fi

selected_name=$(basename "$selected" | tr '.' '_')
tmux_running=$(pgrep tmux)

if [[ -z "$TMUX" ]] && [[ -z "$tmux_running" ]]; then
    # No tmux running, create session inside new terminal
    alacritty -e tmux new-session -ds "$selected_name" -c "$selected"
    hydrate "$selected_name" "$selected"
fi

if ! has_session "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
    hydrate "$selected_name" "$selected"
fi

switch_to "$selected_name"

