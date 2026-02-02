#!/bin/bash
# =========================================================
# GL-MT300N-V2 32M Flash 终极适配脚本
# =========================================================

# 定义文件路径，方便后续引用
DTS_FILE="target/linux/ramips/dts/mt7628an_glinet_gl-mt300n-v2.dts"
MK_FILE="target/linux/ramips/image/mt76x8.mk"

# ---------------------------------------------------------
# 1. 核心适配：修改 DTS 分区表 (16MB -> 32MB)
# ---------------------------------------------------------
# 解释：将 firmware 分区大小从 0xfb0000 改为 0x1fb0000
echo "Modifying DTS partition size..."
sed -i 's/<0x50000 0xfb0000>/<0x50000 0x1fb0000>/g' $DTS_FILE

# ---------------------------------------------------------
# 2. 救命补丁：添加 broken-flash-reset (防止重启死机)
# ---------------------------------------------------------
# 解释：在 spi-max-frequency 下方插入 broken-flash-reset;
# 如果不加这一行，32MB 闪存重启后会卡死
echo "Adding broken-flash-reset patch..."
sed -i '/spi-max-frequency/a \\t\tbroken-flash-reset;' $DTS_FILE

# ---------------------------------------------------------
# 3. 编译限制：修改 Makefile 允许生成大固件
# ---------------------------------------------------------
# 解释：将编译限制放宽到 32448k (约 31.6MB)，否则编译时会报错说文件太大
echo "Adjusting Makefile IMAGE_SIZE limit..."
sed -i '/mt7628an_glinet_gl-mt300n-v2/,/IMAGE_SIZE/s/IMAGE_SIZE := .*/IMAGE_SIZE := 32448k/' $MK_FILE

# ---------------------------------------------------------
# 4. 个性化：第一次启动默认开启 WiFi (免密)
# ---------------------------------------------------------
# 解释：生成一个一次性脚本，刷机后首次启动自动打开 WiFi
echo "Enabling WiFi by default..."
mkdir -p files/etc/uci-defaults
cat <<EOF > files/etc/uci-defaults/99-enable-wifi
uci set wireless.@wifi-device[0].disabled='0'
uci set wireless.@wifi-iface[0].ssid='OpenWrt-MT300N'
uci set wireless.@wifi-iface[0].encryption='none'
uci commit wireless
exit 0
EOF

echo "所有适配修改已完成！"
