#!/bin/sh

# NeoBrix helper commands
export PATH="$HOME/.local/share/neobrix-compatible/bin:$PATH"

# Launch the actual Quickshell executable.
# Do not depend on the interactive Zsh qs() function.
exec "$(command -v qs)" \
    -p "$HOME/.config/quickshell/neobrix/shell.qml" "$@"

