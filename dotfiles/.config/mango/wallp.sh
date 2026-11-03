#!/usr/bin/env bash

exec >>/tmp/wallpaper.log 2>&1
echo "=== $(date) args: $* PATH=$PATH WAYLAND_DISPLAY=$WAYLAND_DISPLAY"

LIST="${XDG_CONFIG_HOME:-$HOME/.config}/mango/wallpapers.list"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper-index"
DEFAULT_MODE=fill
VALID_MODES=" stretch fit fill center tile "

mkdir -p "$(dirname "$STATE")"
touch "$LIST"

# Load list: "path" or "path|mode"
walls=(); modes=()
while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  if [[ "$line" == *"|"* ]]; then p=${line%|*}; m=${line##*|}; else p=$line; m=$DEFAULT_MODE; fi
  [[ "$VALID_MODES" == *" $m "* ]] || m=$DEFAULT_MODE
  [[ -f "$p" ]] && { walls+=("$p"); modes+=("$m"); }
done < "$LIST"

n=${#walls[@]}
idx=$(cat "$STATE" 2>/dev/null || echo -1)

set_wall() {  # path mode
  local old
  old=$(pgrep -x swaybg)
  setsid swaybg -m "$2" -i "$1" >/dev/null 2>&1 &
  sleep 0.3
  [[ -n "$old" ]] && kill $old
}

has() {
  P="$1" awk '$0==ENVIRON["P"] || index($0, ENVIRON["P"] "|")==1 {f=1} END{exit !f}' "$LIST"
}

# Set/replace the mode for a path in place (keeps list order), or append it
setentry() {  # path mode
  if has "$1"; then
    P="$1" M="$2" awk '
      $0==ENVIRON["P"] || index($0, ENVIRON["P"] "|")==1 { print ENVIRON["P"] "|" ENVIRON["M"]; next }
      { print }' "$LIST" > "$LIST.tmp" && mv "$LIST.tmp" "$LIST"
  else
    echo "$1|$2" >> "$LIST"
  fi
}

add() {  # [-m mode] FILE...
  local mode=""
  if [[ "$1" == -m ]]; then mode=$2; shift 2; fi
  [[ -n "$mode" && "$VALID_MODES" != *" $mode "* ]] && { echo "invalid mode: $mode"; exit 1; }
  local f
  for f in "$@"; do
    f=$(realpath "$f")
    if [[ -n "$mode" ]]; then setentry "$f" "$mode"
    else has "$f" || echo "$f" >> "$LIST"
    fi
  done
}

case "$1" in
  add)  shift; add "$@"; exit ;;
  pick) find "$HOME/Pictures" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
          | rofi -dmenu -multi-select -i -p "Add wallpapers" \
          | while IFS= read -r f; do add "$f"; done
        exit ;;
esac

(( n == 0 )) && { notify-send "Wallpaper" "List is empty: $LIST" 2>/dev/null; exit 1; }

case "$1" in
  next)    idx=$(( (idx + 1) % n )) ;;
  prev)    idx=$(( (idx - 1 + n) % n )) ;;
  random)  idx=$(( RANDOM % n )) ;;
  restore) (( idx < 0 || idx >= n )) && idx=0 ;;
  mode)    # change mode of the CURRENT wallpaper: wallpaper.sh mode fit
           (( idx < 0 || idx >= n )) && exit 1
           [[ "$VALID_MODES" == *" $2 "* ]] || { echo "invalid mode: $2"; exit 1; }
           setentry "${walls[$idx]}" "$2"; modes[$idx]=$2 ;;
  toggle)  # flip current wallpaper between fill and fit
           (( idx < 0 || idx >= n )) && exit 1
           [[ "${modes[$idx]}" == fit ]] && m=fill || m=fit
           setentry "${walls[$idx]}" "$m"; modes[$idx]=$m ;;
  *)       echo "usage: $0 {next|prev|random|restore|mode M|toggle|add [-m M] FILE...|pick}"; exit 1 ;;
esac

echo "$idx" > "$STATE"
set_wall "${walls[$idx]}" "${modes[$idx]}"
