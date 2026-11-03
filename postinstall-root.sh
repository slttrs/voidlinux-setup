#!/bin/sh
set -e

[ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }

cd "$(dirname "$0")"

# Update first. If xbps itself is outdated, this updates xbps and may ask you to run the command again.
xbps-install -Suy

# Repositories
echo "Installing repositories..."
xbps-install -y void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree

# Update again after adding new repos
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

# Config files
echo "Installing config files..."

HOMEDIR="${1:-/root}"

# Copy .config directory contents
if [ -d "dotfiles/.config" ]; then
    mkdir -p "$HOMEDIR/.config/"
    cp -r dotfiles/.config/* "$HOMEDIR/.config/"
fi

# Copy home dotfiles
for f in .bashrc .bash_profile; do
    if [ -f "dotfiles/$f" ]; then
        cp "dotfiles/$f" "$HOMEDIR/"
    fi
done

# Copy runit shutdown step
if [ -f "dotfiles/runit/shutdown" ]; then
    cp "dotfiles/runit/shutdown" /etc/runit/runsvdir/default/
    chmod 755 /etc/runit/runsvdir/default/shutdown
fi


echo "Done."
