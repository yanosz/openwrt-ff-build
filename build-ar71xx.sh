#!/bin/bash

#### variables ####

ARCH=ar71xx
BUILD_DIR=$ARCH-build
TARGET=bin/$ARCH
OPENWRT_CODENAME=barrier_breaker
OPENWRT_VERSION=14.07
OPENWRT_SDK=OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2
OPENWRT_EXT=.tar.bz2


#### end variables ####

set -e

#### functions ####

. build-common.sh


# Control flow
mkdir -p "$BUILD_DIR"
[ -e "$TARGET" ] && rm -rf "$TARGET"
mkdir -p "$TARGET"

cd "$BUILD_DIR"

echo "Downloads..."
[ -e "$OPENWRT_SDK$OPENWRT_EXT" ] || wget "https://jenkins.ffm.freifunk.net/files/14.07.1/ar71xx/OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2"

echo "$OPENWRT_SDK..."

[ -e "$OPENWRT_SDK" ] && (echo "delete..." ; rm -rf "$OPENWRT_SDK")
echo "extract..."
tar xjf "$OPENWRT_SDK$OPENWRT_EXT"



cd ..
build

