#!/bin/bash
set -e # 遇到错误即停止

echo "=== 开始为 N60 PRO 编译高功率固件 ==="

# 1. 安装基础编译环境
echo "[1/7] 安装编译环境..."
sudo apt-get update
sudo apt-get install -y build-essential clang flex bison g++ gawk \
  gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
  python3 python3-pip rsync unzip zlib1g-dev file wget curl

# 2. 克隆源码
echo "[2/7] 克隆 ImmortalWrt 源码..."
git clone --depth 1 --branch main https://github.com/padavanonly/immortalwrt-mt798x-24.10 openwrt
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a

# 3. 创建并应用配置文件
echo "[3/7] 配置目标设备和软件包..."
cat > .config << 'CONFIG_EOF'
CONFIG_TARGET_MEDIATEK_FILOGIC=y
CONFIG_TARGET_MEDIATEK_FILOGIC_DEVICE_CMCC_N60_PRO=y
CONFIG_TARGET_PROFILE="CMCC N60 PRO"
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-istore=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_coreutils-nohup=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_luci-app-adblock=n
CONFIG_PACKAGE_luci-app-docker=n
CONFIG_EOF

make defconfig

# 4. 创建网络预配置脚本
echo "[4/7] 创建网络预配置文件..."
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom << 'UCI_EOF'
#!/bin/sh
# LAN 设置
uci set network.lan.ipaddr='192.168.6.1'
uci set network.lan.netmask='255.255.255.0'
# PPPoE 设置
uci set network.wan.proto='pppoe'
uci set network.wan.username='15828860970'
uci set network.wan.password='147258'
uci set network.wan.ipv6='auto'
# IPv6 设置
uci set dhcp.lan.dhcpv6='server'
uci set dhcp.lan.ra='server'
# WiFi 2.4G
uci set wireless.default_radio0.ssid='locust'
uci set wireless.default_radio0.key='36925888'
uci set wireless.default_radio0.encryption='psk2'
# WiFi 5G
uci set wireless.default_radio1.ssid='locust-5G'
uci set wireless.default_radio1.key='36925888'
uci set wireless.default_radio1.encryption='psk2'
uci commit
exit 0
UCI_EOF
chmod +x files/etc/uci-defaults/99-custom

# 5. 下载依赖并编译
echo "[5/7] 下载依赖包（需要较长时间）..."
make download -j$(nproc)
echo "[6/7] 开始编译固件（需要很长时间，请耐心等待）..."
make -j$(nproc) || make -j$(($(nproc)/2)) || make -j1 V=s

# 6. 收集编译好的固件
echo "[7/7] 编译完成，收集固件文件..."
cd ..
mkdir -p firmware_output
find openwrt/bin/targets -name "*cmcc_n60pro*sysupgrade.bin" -exec cp {} firmware_output/ \;
if [ -z "$(ls -A firmware_output/)" ]; then
  # 如果没找到特定名称，复制所有sysupgrade文件
  find openwrt/bin/targets -name "*sysupgrade.bin" -exec cp {} firmware_output/ \;
fi

echo "=== 固件编译流程结束 ==="
echo "生成的文件在 'firmware_output' 目录中。"
ls -lh firmware_output/
