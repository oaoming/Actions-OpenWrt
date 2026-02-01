#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
# =========================================================
#  GL-MT300N-V2 32M Flash Mod - 32MB 扩容补丁
# =========================================================

# 1. 修改 DTS 分区表 (让内核识别 32MB 空间)
sed -i 's/<0x50000 0xfb0000>/<0x50000 0x1fb0000>/g' target/linux/ramips/dts/mt7628an_glinet_gl-mt300n-v2.dts

# 2. 修改 Image Makefile (解除编译生成的体积限制)
sed -i '/mt7628an_glinet_gl-mt300n-v2/,/IMAGE_SIZE/s/IMAGE_SIZE := .*/IMAGE_SIZE := 32448k/' target/linux/ramips/image/mt76x8.mk

# 3. (已删除修改IP的命令，默认保持 192.168.1.1)
