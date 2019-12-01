#!/bin/bash
#
# Copyright 2019 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# script to install packages from Ubuntu non-main/main repo

pkglist="mosquitto linuxptp gnupg-agent apt-transport-https redis-server netdata"

# optional_pkglist="openjdk-11-jdk"

gstream_pkg="gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-plugins-base-apps"

if ! `ping www.ubuntu.com -c 2 1>/dev/null 2>&1`; then
    echo ERROR: unable to access ubuntu.com !
    echo Please check your network to ensure the access to external Internet.
    exit
fi

if [ -n "$http_proxy" ]; then
    if ! grep -i -q 'acquire::http::proxy' /etc/apt/apt.conf 2>/dev/null; then
	echo Please set HTTP proxy in /etc/apt/apt.conf
	exit
    fi
fi

sudo apt-get -y update

for pkg in $pkglist $optional_pkglist $gstream_pkg; do
    echo Installing $pkg ...
    sudo apt install -y $pkg || true
done
echo Packages installation completed!

