#!/bin/bash

function usubmodules {

  cd $base/packages/gluon;  git pull
  cd $base/packages/openwrt-community; git pull
  cd $base/packages/openwrt_routing; git pull
  cd $base/packages/pkg_fastd; git pull
  git commit -a -m "Pulled submodules"
}


function build {
  base=$(pwd)
  # Link packages To build

  #fastd (incl. depends
  ln -s $base/packages/pkg_fastd/net/ $BUILD_DIR/$OPENWRT_SDK/package/net
  ln -s $base/packages/pkg_fastd/libs/ $BUILD_DIR/$OPENWRT_SDK/package/libs
  ln -s $base/packages/openwrt-community/libs/nacl/ $BUILD_DIR/$OPENWRT_SDK/package/nacl

  #batman-adv, batctl, alfred (incl depends)
  ln -s $base/packages/openwrt_routing/alfred $BUILD_DIR/$OPENWRT_SDK/package/alfred
  ln -s $base/packages/openwrt_routing/batctl $BUILD_DIR/$OPENWRT_SDK/package/batctl
  ln -s $base/packages/openwrt_routing/batman-adv $BUILD_DIR/$OPENWRT_SDK/package/batman-adv
  ln -s $base/packages/gluon/net/batman-adv-legacy  $BUILD_DIR/$OPENWRT_SDK/package/batman-adv-legacy


  # Patch batman-adv
  #cp -a $base/patches/batman-adv/* $BUILD_DIR/$OPENWRT_SDK/package/batman-adv/patches

  # Bird
  ln -s $base/packages/openwrt_routing/bird $BUILD_DIR/$OPENWRT_SDK/package/bird
  ln -s $base/packages/openwrt_routing/bird-openwrt $BUILD_DIR/$OPENWRT_SDK/package/bird-openwrt
  ln -s $base/packages/openwrt_routing/bmx6 $BUILD_DIR/$OPENWRT_SDK/package/bmx6

  # OLSRv2
  ln -s $base/packages/olsrv2/openwrt $BUILD_DIR/$OPENWRT_SDK/package/olsrv2

  #### compile ####

  make -C $BUILD_DIR/$OPENWRT_SDK world V=99

  ### Deploy
  cp -a $BUILD_DIR/$OPENWRT_SDK/bin/ar71xx/packages/base/* $TARGET

}