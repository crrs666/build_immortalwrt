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


# 移除要替换的包
#rm -rf feeds/packages/net/v2ray-geodata

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}


# 添加额外插件
#git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 添加主题
#git clone -b js --single-branch https://github.com/gngpp/luci-theme-design package/luci-theme-design
# git clone https://github.com/derisamedia/luci-theme-alpha.git package/luci-theme-alpha

# 添加测速插件
# git clone https://github.com/sirpdboy/netspeedtest.git package/netspeedtest
# 添加 万能推送
# git clone https://github.com/zzsj0928/luci-app-pushbot package/luci-app-pushbot
# 添加关机插件
#git clone https://github.com/VPN-V2Ray/luci-app-poweroff.git package/luci-app-poweroff
# 添加passwall2
# git clone https://github.com/xiaorouji/openwrt-passwall2.git package/luci-app-passwall2
# 添加应用过滤
# git clone  https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
#加入turboacc
#curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh
#chmod -R 777 add_turboacc.sh
#bash add_turboacc.sh --no-sfe


echo "
# 主题
#CONFIG_PACKAGE_luci-theme-design=y

CONFIG_PACKAGE_luci-theme-argon=y

CONFIG_PACKAGE_luci-theme-material=y

CONFIG_PACKAGE_luci-theme-openwrt-2020=y

#CONFIG_PACKAGE_luci-theme-alpha=y

# 测速插件
#CONFIG_PACKAGE_luci-app-netspeedtest=y

# 万能推送
#CONFIG_PACKAGE_luci-app-pushbot=y

# TurboAcc
#CONFIG_PACKAGE_luci-app-turboacc=y

# 应用过滤
# CONFIG_PACKAGE_luci-app-oaf=y

" >> .config

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 修改默认子网掩码
sed -i 's/255.255.255.0/255.255.252.0/g' package/base-files/files/bin/config_generate

# 修改默认主题
#sed -i 's/luci-theme-openwrt-2020/luci-theme-alpha/g' feeds/luci/collections/luci/Makefile

# 修改主机名
sed -i 's/ImmortalWrt/OpenWrt/g' package/base-files/files/bin/config_generate

# 修改Ping 默认网址 immortalwrt.org
#cat feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_network/diagnostics.htm

# 修改系统信息
# cp -f $GITHUB_WORKSPACE/99-default-settings package/emortal/default-settings/files/99-default-settings
cp -f $GITHUB_WORKSPACE/banner package/base-files/files/etc/banner

# 修改主题背景
#cp -f $GITHUB_WORKSPACE/argon/img/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
#cp -f $GITHUB_WORKSPACE/argon/img/argon.svg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/argon.svg
#cp -f $GITHUB_WORKSPACE/argon/favicon.ico feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/favicon.ico
#cp -f $GITHUB_WORKSPACE/argon/icon/android-icon-192x192.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/android-icon-192x192.png
#cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-144x144.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-144x144.png
#cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-60x60.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-60x60.png
#cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-72x72.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-72x72.png
#cp -f $GITHUB_WORKSPACE/argon/icon/favicon-16x16.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-16x16.png
#cp -f $GITHUB_WORKSPACE/argon/icon/favicon-32x32.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-32x32.png
#cp -f $GITHUB_WORKSPACE/argon/icon/favicon-96x96.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-96x96.png
#cp -f $GITHUB_WORKSPACE/argon/icon/ms-icon-144x144.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/ms-icon-144x144.png
#cp -f $GITHUB_WORKSPACE/argon/favicon.ico package/luci-theme-design/htdocs/luci-static/design/favicon.ico

# ==========================================================================
# AP-DK07.1-C1 (IPQ4019) device support injection
# 注入自定义设备支持：DTS / 镜像定义 / WiFi caldata hotplug / 内核 cmdline
# ==========================================================================
DEVICE_DIR=$GITHUB_WORKSPACE/device/ap-dk07.1-c1
DTSDIR=target/linux/ipq40xx/files-6.12/arch/arm/boot/dts/qcom

# 1. 设备树 overlay（覆盖主线 DK07.1-C1：1GB 内存、厂商 NAND 分区表、
#    禁用 PCIe(GPIO38 冲突)、rx8010 RTC、厂商按键等）
mkdir -p $DTSDIR
cp -f $DEVICE_DIR/qcom-ipq4019-ap-dk07.1-c1.dts $DTSDIR/

# 2. 追加镜像定义 qcom_ap-dk07.1-c1（FitImage + UbiFit, 128k/2048）
cat $DEVICE_DIR/generic-device.mk >> target/linux/ipq40xx/image/generic.mk

# 3. 替换 ath10k caldata hotplug（本板从 "0:ART" 提取：
#    2.4G a000000 @0x1000, 5G a800000 @0x5000）
cp -f $DEVICE_DIR/11-ath10k-caldata target/linux/ipq40xx/base-files/etc/hotplug.d/firmware/11-ath10k-caldata

# 4. 强制内核 cmdline：QCA U-Boot 传递的是厂商 bootargs
#    (ubi.mtd=rootfs ubi.mtd=data root=mtd:ubi_rootfs rootfstype=squashfs)，
#    那是 3.14 + GLUEBI 的写法，6.12 不可用，必须整体覆盖。
#    本板 squashfs rootfs 通过 ubiblock 挂载（本 target 未启用 GLUEBI）：
#    ubi0 在 mtd13("rootfs") 上，卷序为 kernel(vol0) / rootfs(vol1) / rootfs_data(vol2)，
#    故块设备名为 /dev/ubiblock0_1，需用 ubi.block= 提前创建（ubiblock 不自动建卷）
cat >> target/linux/ipq40xx/config-6.12 <<'EOF'

# AP-DK07.1-C1: force cmdline (QCA U-Boot passes vendor bootargs)
CONFIG_CMDLINE="console=ttyMSM0,115200n8 ubi.mtd=rootfs ubi.block=0,rootfs root=/dev/ubiblock0_1 rootfstype=squashfs rootwait"
CONFIG_CMDLINE_FORCE=y
EOF

# 5. 替换升级脚本 /lib/upgrade/platform.sh，为 qcom,ap-dk07.1-c1 增加：
#    - platform_check_image: 厂商遗留卷 ubi_rootfs 占用 681 LEB，
#      不先删除则新 kernel/rootfs 卷无空间可建，升级中途删了 kernel 卷会变砖
#    - platform_do_upgrade: 本板 UBI 容器分区名为 "rootfs"，需覆盖 nand.sh
#      默认的 CI_UBIPART="ubi"，否则 nand_attach_ubi 找不到分区
cp -f $DEVICE_DIR/platform.sh target/linux/ipq40xx/base-files/lib/upgrade/platform.sh

# 6. 风扇控制本地化（原厂 fan_ctl 是 uClibc 二进制且会向云端上报 dm_fan_speed_report）
#    主线 ipq4019 没有 PWM 驱动，用 pwm-gpio 在 gpio32 上做软件 PWM（25kHz），
#    用户态 /usr/sbin/fanctl 按阈值表写 duty_cycle，全程不依赖云端/AI 板。
cat >> target/linux/ipq40xx/config-6.12 <<'EOF'

# AP-DK07.1-C1: software PWM on GPIO for fan speed control (drivers/pwm/pwm-gpio.c)
CONFIG_PWM=y
CONFIG_PWM_GPIO=y
# 注意：CONFIG_PWM=y 会让 drivers/leds/rgb/Kconfig 的 LEDS_QCOM_LPG 由"不可见"变
# "可见"（本 target 已有 CONFIG_SPMI=y，依赖 SPMI+PWM 同时满足），而它在
# generic/config-6.12 里没有取值行，kconfig 会把它当作新符号(NEW)在 CI 的非 tty
# 环境里交互询问："* Restart config..." → LEDS_QCOM_LPG (NEW) → syncconfig Error 1
# → target/linux failed to build。这里显式置 n，保证合并后的内核配置里没有 NEW 符号。
# CONFIG_LEDS_QCOM_LPG is not set
# 同理，PWM_IPQ（depends on ARCH_QCOM，本 target 满足）在 generic/config-6.12 里
# 也没有取值行，一并显式置 n —— 我们用 pwm-gpio 软件 PWM，不用 ipq 硬件 PWM。
# CONFIG_PWM_IPQ is not set
EOF

cp -a $DEVICE_DIR/files/. target/linux/ipq40xx/base-files/
chmod 0755 target/linux/ipq40xx/base-files/etc/init.d/fanctl \
           target/linux/ipq40xx/base-files/usr/sbin/fanctl
sed -i 's/\r$//' target/linux/ipq40xx/base-files/etc/init.d/fanctl \
                 target/linux/ipq40xx/base-files/usr/sbin/fanctl

# base-files 里的文件没有 postinst，开机自启需显式建 rc.d 软链接
mkdir -p target/linux/ipq40xx/base-files/etc/rc.d
ln -sf ../init.d/fanctl target/linux/ipq40xx/base-files/etc/rc.d/S95fanctl

# 7. HWMON：原厂温度来自 QSDK 私有 wifi 驱动的 /sys/class/net/wifiN/thermal/temp
#    （射频温度），主线 ath10k 没有该节点，但 wmi_10_4_ops 实现了
#    gen_pdev_get_temperature，只要固件声明 THERM_THROT 且 CONFIG_HWMON=y，
#    ath10k 就会注册 hwmon（temp1_input，毫摄氏度），fanctl 会自动扫描该路径。
#    注：此改动是"可能有"而非"一定有"，取决于 QCA4019 固件的服务位图；
#    开机可用 ls /sys/class/thermal/ 判断（出现 ath10k_thermal cooling_device
#    即固件支持）。若无值，fanctl 仍按 config 里的 fixed_percent 固定转速运行。
cat >> target/linux/ipq40xx/config-6.12 <<'EOF'

# AP-DK07.1-C1: expose ath10k radio temperature via hwmon (temp1_input)
CONFIG_HWMON=y
EOF

# 8. 网络接口生成：02_network 的 board 列表里没有 qcom,ap-dk07.1-c1，
#    board.d 会落到默认分支打印 "Unsupported hardware. Network interfaces
#    not initialized"，于是不生成任何 lan/wan 配置（只有 br-lan 空桥）。
#    本板内置交换机端口划分与 8devices Habanero DVK（同为 IPQ4019 内置
#    交换机 + PSGMII）一致：lan1-lan4 + wan，直接把本板名插到该分组前面。
NETWORK_SH=target/linux/ipq40xx/base-files/etc/board.d/02_network
awk '/^[[:space:]]*8dev,habanero-dvk/ && !done {
	print "\tqcom,ap-dk07.1-c1|\\"
	done=1
}
{ print }' "$NETWORK_SH" > "$NETWORK_SH.tmp" && mv "$NETWORK_SH.tmp" "$NETWORK_SH"

# 插入失败要立刻中止，否则要等整轮编译完才会发现板子还是没网络配置
grep -q 'qcom,ap-dk07.1-c1' "$NETWORK_SH" || {
	echo "ERROR: failed to add qcom,ap-dk07.1-c1 to $NETWORK_SH" >&2
	exit 1
}

