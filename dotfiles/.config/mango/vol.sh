#!/bin/sh
case "$1" in
  up)   wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+ ;;
  down) wpctl set-volume @DEFAULT_SINK@ 5%- ;;
  mute) wpctl set-mute @DEFAULT_SINK@ toggle ;;
esac

out=$(wpctl get-volume @DEFAULT_SINK@)
case "$out" in
  *MUTED*) echo 0 > "$XDG_RUNTIME_DIR/wob.sock" ;;
  *) echo "$out" | awk '{printf "%d\n", $2*100}' > "$XDG_RUNTIME_DIR/wob.sock" ;;
esac
