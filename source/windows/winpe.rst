.. _winpe:

==============
WinPE
==============

虽然我一直在 :ref:`linux` :ref:`macos` 等类UNIX系统上工作，但是偶尔也需要一个Windows环境来运行一些运维工具，例如 :ref:`update_samsung_pm9a1_firmware_on_winpe` ，所以我尝试用一种轻巧的方法来运行一个基本的Windows精简环境，满足特定需求。

`微PE工具箱 <https://www.wepe.com.cn/>`_ 是目前国内公认最干净、无广告、无捆绑的 PE 系统，下载 **V2.3 版本 (64位)** :

- 下载完是一个 .exe 安装包，先在 Windows 环境下打开它
- 不要直接点安装到 U 盘，而是点击右下角的 “生成 ISO” 图标: 这是因为我实际上是通过 :ref:`ventoy` 来运行WinPE.iso

启动 :ref:`ventoy` 来运行WinPE.iso时，在二级菜单有如下几个选项:

- Boot in normal mode (正常模式):

  - 原理：Ventoy 会模拟一个虚拟的光驱（CD-ROM），让主板直接读取 ISO 里的引导文件
  - 适用场景：绝大多数标准 UEFI 主板
  - 优点：加载速度最快，不需要占用额外的内存来存放整个镜像
  
- Boot in wimboot mode (Wimboot 模式):

  - 原理：专门针对 Windows 家族（包括 WinPE）优化的模式，它会提取 ISO 里的核心引导镜像（.wim 文件）并利用 Windows 特有的 bootloader 引导
  - 适用场景：如果 normal mode 启动时卡在黑屏、蓝屏，或者提示找不到驱动，选这个模式的成功率极高

- Boot in memdisk mode (内存盘模式):

  - 原理：Ventoy 会先将整个 200MB 的 WePE.iso 读入内存，然后从内存里启动
  - 优点：启动后不再依赖 U 盘，读写速度极快
  - 缺点：如果你的 ISO 文件特别大（比如完整的 Win10 安装盘 5GB），这个模式会因为内存不足报错
  - 适用场景：只有当前面两个模式都死活进不去系统时，才考虑这个

我的实践验证，采用第2种方式 ``Boot in wimboot mode`` 成功启动WinPE
