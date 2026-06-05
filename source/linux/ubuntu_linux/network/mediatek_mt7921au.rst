.. _mediatek_mt7921au:

==========================
联发科(MediaTek) MT7921AU
==========================

联发科(MediaTek) MT7921AU是目前Linux开源社区支持最好的无线网卡，官方驱动很早就直接并入Linux 主线内核（Mainline Kernel），只要Linux Kernel 5.18+ （Ubuntu 22.04.2+、24.04 及更新版本）原生支持。

MT7921AU (WiFi 6E / AX1800 级别):

- 状态：绝对的免驱之王。Linux Kernel 5.18+（Ubuntu 22.04.2+、24.04 及更新版本）原生支持。
- 特性：支持 WiFi 6 甚至 6E，延迟低、吞吐量大，非常适合高带宽需求的边缘计算节点。

我在淘宝上找了一家 **CHANEVE MT7921AU (带双天线 / 支持 Kali 抓包注入)** :

- 底层芯片：联发科 MT7921AU
- 卖家申明: **明确支持 Kali Linux 的抓包（Monitor Mode，监听模式）和注入（Packet Injection）** 说明它的固件和 Linux 驱动是非常纯血且无阉割的。这对于网络调试、安全审计或折腾 Homelab 来说是硬核刚需。
- 外置天线: **扁平折叠一体式** ，天线横向折叠在网卡主体两侧。这种扁平紧凑的设计，整体重心离主机的 USB 接口近，不容易因为意外碰触而折断或者把主机的 USB 接口压松导致断连。

.. figure:: ../../../_static/linux/ubuntu_linux/network/mt7921au.png

安装
========

- 插入 ****CHANEVE MT7921AU** USB无线网卡后，使用 ``dmesg -T`` 观察，果然立即识别出设备并标记为 ``wlan0`` :

.. literalinclude:: mediatek_mt7921au/dmesg
   :caption: 设备识别的系统日志
   :emphasize-lines: 9-11

注意，现代Linux默认不使用传统的 ``wlan0`` ，而是使用了 **可预测网络接口命名（Predictable Network Interface Names）** 机制，所以使用 ``iwconfig`` 检查可以看到无线网卡如下:

.. literalinclude:: mediatek_mt7921au/iwconfig
   :caption: 使用iwconfig检查看到的无线网卡

- 前缀 ``wlx`` ：代表这是一块 Wireless（无线）网卡，且使用的是 **X** （MAC 地址）进行唯一标识
- 后缀 ``fc221c500043`` : 无线网卡的 物理 MAC 地址（即 ``fc:22:1c:50:00:43`` ）

- 软件堆栈安装:

.. literalinclude:: mediatek_mt7921au/apt_install
   :caption: 安装无线相关软件包

.. note::

   现在 ``wap_supplicant`` 的软件包名被修改为 ``wpasupplicant`` 了!!! ( :ref:`apt-file` 搜索提供文件的软件包名 )

.. csv-table:: 无线网络软件堆栈
   :file:  mediatek_mt7921au/wifi_software.csv
   :widths: 20,20,60
   :header-rows: 1

可选软件包:

.. literalinclude:: mediatek_mt7921au/apt_install_options
   :caption: 安装可选的软件包(方便运维)

.. csv-table:: **可选的** 无线网络软件堆栈
   :file:  mediatek_mt7921au/wifi_software_options.csv
   :widths: 20,20,60
   :header-rows: 1

- 编辑 ``/etc/netplan/60-wireless.yaml`` (不要直接修改 ``/etc/netplan/50-cloud-init.yaml`` 该文件是 ``cloud-init`` 处理的)

.. literalinclude:: mediatek_mt7921au/60-wireless.yaml
   :caption: 配置 ``/etc/netplan/60-wireless.yaml``

.. note::

   建议加上 ``optional: true`` 。因为服务器默认在开机时，如果发现有网卡处于“未联网”状态，系统会硬卡在开机界面等待网络就绪（通常卡 120 秒），直到超时才放行。加上这一行，即使 USB 无线网卡没插，或者 Wi-Fi 信号不好，系统也能畅通无阻地秒级开机。

- 执行测试:

.. literalinclude:: mediatek_mt7921au/netplay_try
   :caption: 验证配置

这里可能会提示警告

.. literalinclude:: mediatek_mt7921au/netplay_try_warning
   :caption: 验证配置出现WARNING
   :emphasize-lines: 7,8

这里的WARNING是因为配置文件中包含了无线的 SSID 名字，更核心的是写入了明文的 Wi-Fi 密码（Pre-Shared Key）。Linux 的系统安全原则要求：任何包含明文凭据（密码、私钥、Token）的配置文件，在物理层面上绝对不允许除了 root 以外的其他普通用户读取。

所以执行以下命令进行文件权限修订:

.. literalinclude:: mediatek_mt7921au/chmod
   :caption: 修订配置文件权限

现在不再WARNING，此时提示:

.. literalinclude:: mediatek_mt7921au/netplay_try_output
   :caption: 请在120秒内回车来接受配置，否则配置就会放弃回滚
   :emphasize-lines: 7,8

- 最后生效:

.. literalinclude:: mediatek_mt7921au/netplay_apply
   :caption: 执行生效
