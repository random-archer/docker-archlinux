#!/bin/bash

log() {
    1>&2 echo "### aur: $1"
}

is_root() {
    [[ $(id -u) == "0" ]]
}

sudo_user() {
    is_root && printf "sudo -u $user"    
}

assert_sudo() {
    sudo sh -c "echo 'sudo is ok'"
}

build() {
    log "$name build"
    set -e
    is_root && echo "$user ALL=(ALL) NOPASSWD: ALL" > "$sudo_file"
    cd "$temp"
    git clone "$repo"
    cd "$name"
    is_root && chown -R "$user" "$temp"
    $(sudo_user) $command
}

clean() {
    log "$name clean"
    set +e
    [[ -e "$temp" ]] && rm -r -f "$temp"
    [[ -e "$sudo_file" ]] && rm -f "$sudo_file"
    cd "$work"
}

error() {
    log "$name error: $1"
}

name="$1"
repo="http://aur.archlinux.org/${name}.git"
work=$(pwd)
temp=$(mktemp -d /tmp/bash_aur_${name}.XXXXXXX)
command="makepkg -s -r -i -c -f -L --skippgpcheck   --noconfirm"
user="nobody"
sudo_file="/etc/sudoers.d/$(cat /dev/urandom | tr -d -c 'a-z' | fold -w 32 | head -n 1)"

[[ $name ]] || { log "missing package name" ; exit 1 ; }

###

log "$name init"

trap 'error $LINENO' ERR
trap clean EXIT

assert_sudo
    
build

log "$name done"
