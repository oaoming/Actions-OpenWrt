#!/bin/bash
# =========================================================
# GL-MT300N-V2 32M Flash Mod - 32MB 扩容补丁
# =========================================================

# 1. 修改 DTS 分区表 (让内核识别 32MB 空间)
# 将 firmware 分区的长度从 0xfb0000 扩大到 0x1fb0000
sed -i 's/<0x50000 0xfb0000>/<0x50000 0x1fb0000>/g' target/linux/ramips/dts/mt7628an_glinet_gl-mt300n-v2.dts

# 2. 修改 Image Makefile (解除编译生成的体积限制)
# 将 IMAGE_SIZE 限制修改为 32448k (约 31.6MB)
sed -i '/mt7628an_glinet_gl-mt300n-v2/,/IMAGE_SIZE/s/IMAGE_SIZE := .*/IMAGE_SIZE := 32448k/' target/linux/ramips/image/mt76x8.mk

# 3. 强制默认管理地址 (保险起见)
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate
