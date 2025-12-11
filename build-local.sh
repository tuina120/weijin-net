#!/bin/sh
# Local helper to build luci-app-weijin with a given OpenWrt SDK
# Usage: ./build-local.sh /path/to/openwrt-sdk

SDK="$1"
[ -z "$SDK" ] && { echo "Usage: $0 /path/to/openwrt-sdk"; exit 1; }

if [ ! -d "$SDK" ]; then
  echo "SDK dir not found: $SDK"
  exit 1
fi

cp -r luci-app-weijin "$SDK/package/"
cd "$SDK" || exit 1

make package/luci-app-weijin/compile V=s
