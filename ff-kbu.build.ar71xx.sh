#!/bin/sh

## Build Script for kbu.freifunk.net firmware
# Version 0.2

# hint: copy $OPENWRT_SDK and $OPENWRT_IMAGEBUILDER to $BUILD_DIR if it's 
#       locally available and it won't be downloaded each time the script runs

#### variables ####

BUILD_DIR=/tmp/ff-kbu-build/
TARGET=/tmp/ff-kbu-packages/
OPENWRT_CODENAME=barrier_breaker
OPENWRT_VERSION=14.07
OPENWRT_SDK=OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2
OPENWRT_IMAGEBUILDER=OpenWrt-ImageBuilder-ar71xx_generic-for-linux-x86_64
OPENWRT_EXT=.tar.bz2
KBU_DL_URL=http://packages.der-he.de/austausch
#KBU_DL_NAME=141222-ff-kbu-alpha1.tar.gz
KBU_DL_NAME=150118-ff-kbu-alpha2.tar.gz
BUILD_DEPENDS="build-essential gawk unzip python wget subversion file libncurses5-dev zlib1g-dev ccache git"

OPENWRT_REPOSITORY="http://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/generic/packages/"
OPENWRT_DEPS="packages/fastd_14-1_ar71xx.ipk packages/collectd_4.10.8-3_ar71xx.ipk packages/collectd-mod-interface_4.10.8-3_ar71xx.ipk packages/collectd-mod-network_4.10.8-3_ar71xx.ipk packages/collectd-mod-ping_4.10.8-3_ar71xx.ipk packages/collectd-mod-iwinfo_4.10.8-3_ar71xx.ipk packages/avahi-daemon_0.6.31-6_ar71xx.ipk routing/alfred_2014.3.0-0_ar71xx.ipk routing/batctl_2014.2.0-1_ar71xx.ipk packages/liboping_1.6.2-1_ar71xx.ipk packages/libavahi_0.6.31-6_ar71xx.ipk packages/libexpat_2.1.0-1_ar71xx.ipk packages/libdaemon_0.14-4_ar71xx.ipk packages/libdbus_1.8.6-1_ar71xx.ipk"


#PROFILES="TLWDR4300 TLWR741 TLWR841 TLWR842 TLWR740 TLWR1043"
PROFILES="TLWDR4300 TLWR841"
#(http://wiki.openwrt.org/doc/howto/obtain.firmware.generate#configure_package_repositories)
#(http://pastebin.com/WbudpBDJ)

#### end variables ####

set -e

#### functions ####

need_deps() {
  echo
  echo "Please install all dependencies: "
  echo "apt-get install $BUILD_DEPENDS"
  exit 1
}

#### install build dependencies ####

#sudo apt-get install build-essential 
#sudo apt-get install gawk unzip python wget subversion file libncurses5-dev zlib1g-dev ccache

if [ $# -gt 0 -a "$1" = "depinst" ]
then
  apt-get -y install $BUILD_DEPENDS
else
  for i in $BUILD_DEPENDS
  do
    dpkg -s "$i" > /dev/null || need_deps
  done
fi

echo "All Dependencies installed, continuing..."

#### dowload ####

mkdir -p "$BUILD_DIR"
[ -e "$TARGET" ] && rm -rf "$TARGET"
mkdir -p "$TARGET"

cd "$BUILD_DIR"

echo "Downloads..."
[ -e "$OPENWRT_SDK$OPENWRT_EXT" ] || wget "http://downloads.openwrt.org/$OPENWRT_CODENAME/$OPENWRT_VERSION/ar71xx/generic/$OPENWRT_SDK$OPENWRT_EXT"
[ -e "$OPENWRT_IMAGEBUILDER$OPENWRT_EXT" ] || wget "http://downloads.openwrt.org/$OPENWRT_CODENAME/$OPENWRT_VERSION/ar71xx/generic/$OPENWRT_IMAGEBUILDER$OPENWRT_EXT"
[ -e "$KBU_DL_NAME" ] || wget "$KBU_DL_URL/$KBU_DL_NAME"

echo "Downloading OpenWRT dependencies..."
mkdir -p openwrt-deps
cd openwrt-deps
for dep in $OPENWRT_DEPS
do
  depfile=$(basename "$dep")
  [ -e "$depfile" ] || wget "$OPENWRT_REPOSITORY$dep"
done
cd ..

echo "$OPENWRT_SDK..."
[ -e "$OPENWRT_SDK" ] && (echo "delete..." ; rm -rf "$OPENWRT_SDK")
echo "extract..."
tar xjf "$OPENWRT_SDK$OPENWRT_EXT"
echo "$OPENWRT_IMAGEBUILDER..."
[ -e "$OPENWRT_IMAGEBUILDER" ] && (echo "delete..." ; rm -rf "$OPENWRT_IMAGEBUILDER")
echo "extract..."
tar xjf "$OPENWRT_IMAGEBUILDER$OPENWRT_EXT"
echo "copy dependencies to ImageBuilder..."
cp "$BUILD_DIR"/openwrt-deps/*ipk "$BUILD_DIR/$OPENWRT_IMAGEBUILDER/packages/"

echo "extracting kbu packages..."
tar xzf "$KBU_DL_NAME" -C "$BUILD_DIR/$OPENWRT_SDK/package/"

#### compile ####

cd "$BUILD_DIR/$OPENWRT_SDK"
echo "compile kbu packages..."
make world

echo "copy ipks to ImageBuilder..."
cp ./bin/ar71xx/packages/base/*ipk "$BUILD_DIR/$OPENWRT_IMAGEBUILDER/packages/"
cp ./bin/ar71xx/packages/base/*ipk "$TARGET"

cd "$BUILD_DIR/$OPENWRT_IMAGEBUILDER"

echo "making images..."
#make V=s image PROFILE=TLWDR4300 PACKAGES="kmod-batman-adv-cv14 kbu-ff"
#make image PACKAGES="kmod-batman-adv-cv14 kbu-ff"
for i in $PROFILES
do
  echo "making $i..."
  make image PROFILE="$i" PACKAGES="kmod-batman-adv-cv14 kbu-ff"
done

echo "copy images to $TARGET..."
cp -r ./bin/ar71xx "$TARGET"

#### packages and images now should be in $TARGE dir ####
