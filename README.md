自己学习云编译n60 pro固件
我要用github云编译237的高功率固件，不拉取源码到我的仓库，我还要只安装OpenClash插件与 iStore，不要安装AdBlock，Docker。尽量保持与官方版本的纯净。我用路由pppoe拨号，IPV6要能自动使用。访问路由用192.168.6.1地址，云编译时自动全新编译，不要选false或main。给我生成一个工作流。
237源码地址：https://github.com/padavanonly/immortalwrt-mt798x-24.10
请给我出一个详细的教程，我要怎么实现云编译。
高功率配置文件地址为https://github.com/padavanonly/immortalwrt-mt798x-6.6/blob/2410/defconfig/nx60pro-ipailna-high-power.config
================================================================================================
最终用https://github.com/moshanghuakai01/237-6.6里的方法编译成功。

237大佬的源码已经更新了6.6内核版本了，N60 PRO也可以在线编译了。
原帖地址：https://www.right.com.cn/forum/thread-8423011-1-1.html，这个地址大佬分享了5.4内核版本和6.6内核版本的固件。
源码地址：https://github.com/padavanonly/immortalwrt-mt798x-6.6

利用P3TERX大佬的项目https://github.com/P3TERX/Actions-OpenWrt 在线编译的时候，修改源码文件.github/workflows/openwrt-builder.yml 第20和21行
REPO_URL: https://github.com/coolsnowwolf/lede
REPO_BRANCH: master
为
REPO_URL: https://github.com/padavanonly/immortalwrt-mt798x-6.6
REPO_BRANCH: openwrt-24.10-6.6

6.6内核版本固件编辑配置文件.config，最开始几行输入
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_netcore_n60-pro=y
CONFIG_TARGET_DEVICE_PACKAGES_mediatek_filogic_DEVICE_netcore_n60-pro=""

剩下的照搬defconfig/mt7986-ax6000.config或者defconfig/nx60pro-ipailna-high-power.config配置文件的内容即可。
修改工作流权限为Read and write permissions，输入个人github账户生成的token就可以在线编译了，顺利的话1个小时左右就能编译完成，如果集成插件比较多的话，时间也会长一些。

附上我自己编译的项目https://github.com/moshanghuakai01/netcore-n60-pro，这个集成了定时重启、终端ttyd、组播代理omcproxy、组播转换msd_lite插件和ADGuardHome的luci。

如果需要纯净固件的，用这个编译即可,https://github.com/moshanghuakai01/237-6.6，可以编译5.4内核和6.6内核版本的固件。

刷入方法：uboot用天灵大佬的mt7986-netcore_n60-pro-fip.bin，uboot下刷机即可。需要更新固件也需要从uboot下刷入新固件，web页面刷入虽然提示成功，但实际是失败的，可能是由于没有刷BL2的关系。
