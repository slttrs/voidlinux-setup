export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=wlroots
dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
wlr-randr --output HDMI-A-1 --mode 2560x1440@100Hz &
gammastep -O 6500 -g 0.82 &

/usr/libexec/xdg-desktop-portal &
/usr/libexec/xdg-desktop-portal-wlr &
waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css >/dev/null 2>&1 &
/usr/libexec/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &
udiskie &
pipewire &
# swaybg -i /home/cray/Desktop/shelter/IMP-files/images\ 10\ GB/Pinterest/Undertale/Gaster/161d35d3a259b37a605983894435.jpg -m fit &
/home/cray/.config/mango/wallp.sh restore &
