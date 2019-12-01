#!/bin/bash
#
# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#

set -e

IMGDIR=$FBDIR/build/images
mkdir -p $IMGDIR
mkdir -p $FBDIR/packages/rfs/initrd
[ "$ENDIANTYPE" = "be" ] && endiantype=_be
cp -f  ${BINARIES_DIR}/rootfs.cpio.gz $FBDIR/packages/rfs/initrd/rootfs_buildroot_${DESTARCH}${endiantype}_$DISTROSCALE.cpio.gz
ln -sf ${BINARIES_DIR}/rootfs.ext2.gz $IMGDIR/rootfs_buildroot_${SOCFAMILY}_${DESTARCH}${endiantype}_${DISTROSCALE}.ext2.gz
ln -sf ${BINARIES_DIR}/rootfs.jffs2 $IMGDIR/rootfs_buildroot_${SOCFAMILY}_${DESTARCH}${endiantype}_${DISTROSCALE}.jffs2
ln -sf ${BINARIES_DIR}/rootfs.squashfs $IMGDIR/rootfs_buildroot_${SOCFAMILY}_${DESTARCH}${endiantype}_${DISTROSCALE}.squashfs
