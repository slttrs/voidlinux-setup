# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias mango='dbus-run-session mango'
alias startplasma='dbus-run-session startplasma-wayland'
alias ls='ls --color=auto'
alias xi='sudo xbps-install'
alias goodnight='sudo poweroff'

nv() {
  local opts=(
    -o font_family="Hack"

    # blue
    -o background="#011627" 
    -o transparent_background_colors="#061e33@0.8"    

    # green
    # -o background="#001000"
    # -o transparent_background_colors="#008000@0.7"
    
    -o background_opacity=0.8
  )
  kitty --detach "${opts[@]}" nvim "$@" && exit
}

function y() {
	local tmp flag cwd
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	flag="$(mktemp -u -t "yazi-opened.XXXXXX")"

	YAZI_OPENED_FLAG="$flag" yazi "$@" --cwd-file="$tmp"

	if [ -e "$flag" ]; then
		rm -f -- "$tmp" "$flag"
		exit
	fi

	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools

# PS1='[\u@\h \W]\$ '
PS1='[\u] \w \$ '
# fastfetch

. "$HOME/.cargo/env"
