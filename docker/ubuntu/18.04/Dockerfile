FROM ubuntu:18.04
MAINTAINER Shengzhou Liu <shengzhou.liu@nxp.com>

ARG http_proxy
ENV http_proxy $http_proxy
ARG https_proxy
ENV https_proxy $https_proxy
ARG no_proxy
ENV no_proxy $no_proxy
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN echo "Acquire::http::proxy \"$http_proxy\";" | tee -a /etc/apt/apt.conf && \
    echo "Acquire::https::proxy \"$https_proxy\";" | tee -a /etc/apt/apt.conf && \
    echo 'PS1="[\u@\h \W]\$ "' | tee -a /root/.bashrc 1>/dev/null
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && export LANG=en_US.utf8

RUN apt-get install -y \
        u-boot-tools device-tree-compiler autoconf automake dh-autoreconf libssl-dev zip \
        openssl python-pip flex bison bc git gcc vim ethtool wget ftp make makedev tclsh \
        binfmt-support qemu-system-common qemu-user-static debootstrap sudo ncurses-dev  \
        gcc-arm-linux-gnueabihf crossbuild-essential-arm64 gcc-aarch64-linux-gnu file    \
        build-essential gdb u-boot-tools device-tree-compiler python python-dev curl     \
        libxml2-dev libsensors4-dev libssl-dev libedit-dev liblzma-dev tree binutils-dev \
        libnuma-dev libpcap-dev libtool mtd-utils libncurses5-dev libelf-dev net-tools   \
        libcunit1-dev pkg-config autotools-dev crossbuild-essential-armhf openssh-server \
        openssh-client crossbuild-essential-armhf qemu-utils kmod g++-aarch64-linux-gnu  \
	cpp-arm-linux-gnueabihf dosfstools ruby iputils-ping cpio rsync libtclap-dev     \
	parted android-tools-fsutils rpm2cpio lsb-release xutils-dev libwayland-bin cmake \
	locales texinfo chrpath diffstat gawk

RUN pip install six
