#!/bin/bash


function build {
  base=$(pwd)
  # Link packages To build

  #fastd (incl. depends
  ln -s $base/packages/pkg_fastd/net/ $BUILD_DIR/$OPENWRT_SDK/package/net
  ln -s $base/packages/pkg_fastd/libs/ $BUILD_DIR/$OPENWRT_SDK/package/libs
  ln -s $base/packages/openwrt-community/libs/nacl/ $BUILD_DIR/$OPENWRT_SDK/package/nacl

  #nginx - minimal - patch default options for minimal build
  #ln -s $base/packages/openwrt-community/net/lighttpd/ $BUILD_DIR/$OPENWRT_SDK/package/lighttpd
  ln -s $base/packages/openwrt-community/libs/libxml2/ $BUILD_DIR/$OPENWRT_SDK/package/libxml2
  #ln -s $base/packages/openwrt-community/libs/sqlite3  $BUILD_DIR/$OPENWRT_SDK/package/sqlite3
  ln -s $base/packages/openwrt-community/libs/pcre/  $BUILD_DIR/$OPENWRT_SDK/package/pcre
  #ln -s $base/packages/openwrt-community/utils/mysql/ $BUILD_DIR/$OPENWRT_SDK/package/mysq
  ln -s $base/packages/pkg_lighttpd/lighttpd/ $BUILD_DIR/$OPENWRT_SDK/package/lighttpd

  #batman-adv, batctl, alfred (incl depends)
  ln -s $base/packages/openwrt_routing/alfred $BUILD_DIR/$OPENWRT_SDK/package/alfred
  ln -s $base/packages/openwrt_routing/batctl $BUILD_DIR/$OPENWRT_SDK/package/batctl
  ln -s $base/packages/openwrt_routing/batman-adv $BUILD_DIR/$OPENWRT_SDK/package/batman-adv
  ln -s $base/packages/gluon/net/batman-adv-legacy  $BUILD_DIR/$OPENWRT_SDK/package/batman-adv-legacy
  ln -s $base/packages/fff-config-mode/luci/ $BUILD_DIR/$OPENWRT_SDK/package/config-mode

  # Patch batman-adv
  cp -a $base/patches/batman-adv/* $BUILD_DIR/$OPENWRT_SDK/package/batman-adv/patches

  # Bird
  ln -s $base/packages/openwrt_routing/bird $BUILD_DIR/$OPENWRT_SDK/package/bird
  ln -s $base/packages/openwrt_routing/bird-openwrt $BUILD_DIR/$OPENWRT_SDK/package/bird-openwrt
  
  #bmx6
  ln -s $base/packages/openwrt_routing/bmx6 $BUILD_DIR/$OPENWRT_SDK/package/bmx6

  # OLSRv2
  ln -s $base/packages/olsrv2/openwrt $BUILD_DIR/$OPENWRT_SDK/package/olsrv2

  #patch SDK (https://projects.universe-factory.net/issues/206#change-438)
  patch -d  $BUILD_DIR/$OPENWRT_SDK -p1 < $base/patches/sdk/0001-build-fix-CMake-assembly-builds-with-ccache.patch
  #### compile ####
  
   
  make -C $BUILD_DIR/$OPENWRT_SDK clean world V=99

  ### Deploy
  cp -a $BUILD_DIR/$OPENWRT_SDK/bin/$ARCH/packages/base/* $TARGET

}
