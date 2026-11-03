#!/bin/sh
set -e

[ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }

cd "$(dirname "$0")"

# Update first. If xbps itself is outdated, this updates xbps and may ask you to run the command again.
xbps-install -Suy

# Packages: one per line in packages.txt, # for comments
xbps-install -y $(grep -v '^#' packages.txt)

# Services
for s in dbus elogind chronyd cronie; do
    if [ -d "/etc/sv/$s" ]; then
        ln -sf "/etc/sv/$s" /var/service/
    else
        echo "Warning: service $s not found"
    fi
done

# fstab tweak, swap/zram, etc.



echo "Done."
