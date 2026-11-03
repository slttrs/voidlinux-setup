#!/bin/sh
rm -f "$XDG_RUNTIME_DIR/wob.sock"
mkfifo "$XDG_RUNTIME_DIR/wob.sock"
tail -f "$XDG_RUNTIME_DIR/wob.sock" | wob
