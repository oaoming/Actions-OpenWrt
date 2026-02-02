#!/bin/bash
# =========================================================
# GL-MT300N-V2 32M Flash + WiFi + I2C 终极适配脚本
# =========================================================

DTS_FILE="target/linux/ramips/dts/mt7628an_glinet_gl-mt300n-v2.dts"
MK_FILE="target/linux/ramips/image/mt76x8.mk"

# ---------------------------------------------------------
# 1. 核心适配：修改 DTS 分区表 (32MB)
# ---------------------------------------------------------
sed -i 's/<0x50000 0xfb0000>/<0x50000 0x1fb0000>/g' $DTS_FILE

# ---------------------------------------------------------
# 2. 救命补丁：防止重启死机
# ---------------------------------------------------------
sed -i '/spi-max-frequency/a \\t\tbroken-flash-reset;' $DTS_FILE

# ---------------------------------------------------------
# 3. 硬件开启：激活 I2C 总线 (新增!)
# ---------------------------------------------------------
# 解释：默认 DTS 里 I2C 是关闭的 (disabled)。我们需要在文件末尾追加配置把它打开。
# 这样驱动才能控制主板左侧的 I2C_SCLK 和 I2C_SD 引脚。
cat <<EOF >> $DTS_FILE

&i2c {
	status = "okay";
};
EOF
echo "I2C node enabled in DTS."

# ---------------------------------------------------------
# 4. 软件驱动：添加 I2C 驱动包到配置文件 (新增!)
# ---------------------------------------------------------
# 解释：不需要手动去 make menuconfig 选了，直接在这里强制写入 .config
echo "CONFIG_PACKAGE_kmod-i2c-mt7628=y" >> .config
echo "CONFIG_PACKAGE_i2c-tools=y" >> .config
echo "I2C drivers added to .config."

# ---------------------------------------------------------
# 5. 编译限制：允许大固件
# ---------------------------------------------------------
sed -i '/mt7628an_glinet_gl-mt300n-v2/,/IMAGE_SIZE/s/IMAGE_SIZE := .*/IMAGE_SIZE := 32448k/' $MK_FILE

# ---------------------------------------------------------
# 6. 默认开启 WiFi
# ---------------------------------------------------------
mkdir -p files/etc/uci-defaults
cat <<EOF > files/etc/uci-defaults/99-enable-wifi
uci set wireless.@wifi-device[0].disabled='0'
uci set wireless.@wifi-iface[0].ssid='OpenWrt-MT300N'
uci set wireless.@wifi-iface[0].encryption='none'
uci commit wireless
exit 0
EOF

echo "所有适配修改已完成！"
