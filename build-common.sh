#!/bin/bash


function build {
  base=$(pwd)
  
  # Link packages To build
  ## fastd (incl. depends
  ln -s $base/packages/pkg_fastd/net/ $BUILD_DIR/$OPENWRT_SDK/package/net
  ln -s $base/packages/pkg_fastd/libs/ $BUILD_DIR/$OPENWRT_SDK/package/libs
  ln -s $base/packages/openwrt-community/libs/nacl/ $BUILD_DIR/$OPENWRT_SDK/package/nacl

  ## collectd v5
  ln -s $base/packages/openwrt-community/utils/collectd/ $BUILD_DIR/$OPENWRT_SDK/package/collectd
  ln -s $base/packages/openwrt-community/libs/liboping $BUILD_DIR/$OPENWRT_SDK/package/liboping
  ln -s $base/packages/openwrt-community/utils/rrdtool1/ $BUILD_DIR/$OPENWRT_SDK/package/rrdtool1
  ### Disable selections due to libcurl and obscure dependencies
  echo "
# CONFIG_PACKAGE_collectd-mod-apache is not set
# CONFIG_PACKAGE_collectd-mod-ascent is not set
# CONFIG_PACKAGE_collectd-mod-bind is not set
# CONFIG_PACKAGE_collectd-mod-curl is not set
# CONFIG_PACKAGE_collectd-mod-modbus is not set
# CONFIG_PACKAGE_collectd-mod-nginx is not set
# CONFIG_PACKAGE_collectd-mod-postgresql is not set
# CONFIG_PACKAGE_collectd-mod-sensors is not set
# CONFIG_PACKAGE_collectd-mod-write-http is not set
# CONFIG_PACKAGE_collectd-mod-snmp is not set
  " >> $BUILD_DIR/$OPENWRT_SDK/.config

  ## batman-adv, batctl, alfred (incl depends)
  ln -s $base/packages/openwrt_routing/alfred $BUILD_DIR/$OPENWRT_SDK/package/alfred
  ln -s $base/packages/openwrt_routing/batctl $BUILD_DIR/$OPENWRT_SDK/package/batctl
  ln -s $base/packages/openwrt_routing/batman-adv $BUILD_DIR/$OPENWRT_SDK/package/batman-adv
  ln -s $base/packages/gluon/net/batman-adv-legacy  $BUILD_DIR/$OPENWRT_SDK/package/batman-adv-legacy
  ln -s $base/packages/fff-config-mode/luci/ $BUILD_DIR/$OPENWRT_SDK/package/config-mode

  ## Patch batman-adv
  # Patch batman-adv
  mkdir -p $BUILD_DIR/$OPENWRT_SDK/package/batman-adv/patches
  cp -a $base/patches/batman-adv/* $BUILD_DIR/$OPENWRT_SDK/package/batman-adv/patches

  ## Bird
  ln -s $base/packages/openwrt_routing/bird $BUILD_DIR/$OPENWRT_SDK/package/bird
  ln -s $base/packages/openwrt_routing/bird-openwrt $BUILD_DIR/$OPENWRT_SDK/package/bird-openwrt
  
  ## bmx6
  ln -s $base/packages/openwrt_routing/bmx6 $BUILD_DIR/$OPENWRT_SDK/package/bmx6

  ## OLSRv2
  ln -s $base/packages/olsrv2/openwrt $BUILD_DIR/$OPENWRT_SDK/package/olsrv2
  #patch SDK (https://projects.universe-factory.net/issues/206#change-438)
  patch -d  $BUILD_DIR/$OPENWRT_SDK -p1 < $base/patches/sdk/0001-build-fix-CMake-assembly-builds-with-ccache.patch
  #### compile ####
  
  # Build
  make -C $BUILD_DIR/$OPENWRT_SDK world V=99

  # Deploy
  cp -a $BUILD_DIR/$OPENWRT_SDK/bin/$ARCH/packages/base/* $TARGET

}
