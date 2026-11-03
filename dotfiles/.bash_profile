# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# Autostart Minecraft server in tmux
# if command -v tmux >/dev/null 2>&1; then
#     if ! tmux has-session -t minecraft 2>/dev/null; then
#         tmux new-session -d -s minecraft "$HOME/server/start.sh"
#     fi
# fi
. "$HOME/.cargo/env"
