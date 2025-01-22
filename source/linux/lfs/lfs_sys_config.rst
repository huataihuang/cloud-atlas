.. _lfs_sys_config:

=================
LFS系统配置
=================

引导 Linux 系统需要完成若干任务:

- 挂载虚拟和真实文件系统
- 初始化设备
- 检查文件系统完整性
- 挂载并启用所有交换分区或文件
- 设定系统时钟
- 启用网络
- 启动系统需要的守护进程
- 完成用户自定义的其他工作

System V
===========

System V 是自 1983 年以来就在 Unix 和 Linux 等类 Unix 系统中被广泛应用的经典引导过程。它包含一个小程序 init，该程序设定 login (通过 getty) 等基本进程，并运行一个脚本。

脚本一般被命名为 rc，控制一组附加脚本的运行，这些附加脚本完成初始化系统需要的各项工作。

``init`` 程序受到 ``/etc/inittab`` 文件的控制，被组织为用户可以选择的系统运行级别:

- 0 — 停止运行
- 1 — 单用户模式
- 2 — 用户自定义模式
- 3 — 完整的多用户模式
- 4 — 用户自定义模式
- 5 — 拥有显示管理器的完整多用户模式
- 6 — 重启系统

通常的默认运行级别是 ``3`` 或 ``5``

优点:

- 完备的，已经被详细理解的系统。
- 容易定制。

缺点:

- 引导速度较慢。一个中等速度的基本 LFS 系统从第一个内核消息开始，到出现登录提示符为止，需要 8-12 秒的引导时间，之后还需要约 2 秒启动网络连接。
- 串行执行引导任务。这与前一项缺点相关。引导过程中的延迟 (如文件系统检查) 会拖延整个引导过程。
- 不支持控制组 (cgroups) 和每用户公平共享调度等高级特性。
- 添加脚本时，需要手动决定它在引导过程中的次序。

安装LFS-Bootscripts
========================

.. literalinclude:: lfs_sys_config/lfs-bootscripts
   :caption: 安装 LFS-Bootscripts

设备和模块管理
==================

传统的 Linux 系统通常静态地创建设备，即在 /dev 下创建大量设备节点 (有时有数千个节点)，无论对应的硬件设备是否真的存在。这种方式会导致 ``/dev`` 目录下有大量无用的通过 ``MAKEDEV`` 脚本创建的设备文件(包含以相关的主设备号和次设备号) 。

使用 ``udev`` 时，则只有那些被内核检测到的设备才会获得为它们创建的设备节点。这些设备节点在每次引导系统时都会重新创建；它们被储存在 ``devtmpfs`` 文件系统中 (一个虚拟文件系统，完全驻留在系统内存)。设备节点不需要太多空间，它们使用的系统内存可以忽略不计。

``sysfs`` 在2.6 系列稳定内核中发布。sysfs 的工作是将系统硬件配置信息提供给用户空间进程，有了这个用户空间可见的配置描述，就可能开发一种 ``devfs`` (已被淘汰)的用户空间替代品。

udev实现
----------

编译到内核中的驱动程序在对应设备被内核检测到时，直接将它们注册到 sysfs (内部的 devtmpfs)。对于那些被编译为模块的驱动程序，注册过程在模块加载时进行。只要 sysfs 文件系统被挂载好 (位于 /sys)，用户空间程序即可使用驱动程序注册在 sysfs 中的数据，udev 就能够使用这些数据对设备进行处理 (包括修改设备节点)。

内核通过 devtmpfs 直接创建设备文件，任何希望注册设备节点的驱动程序都要通过 devtmpfs (经过驱动程序核心) 进行注册。当一个 devtmpfs 实例被挂载到 /dev 时，设备节点将被以固定的名称、访问权限和所有者首次创建。

内核会向 udevd 发送一个 uevent。根据 /etc/udev/rules.d，/usr/lib/udev/rules.d，以及 /run/udev/rules.d 目录中文件指定的规则，udevd 将为设备节点创建额外的符号链接，修改其访问权限，所有者，或属组，或者修改该对象的 udevd 数据库条目 (名称)。

如果 udevd 找不到它正在创建的设备对应的规则，它将会沿用 devtmpfs 最早使用的配置。

管理设备
----------

网络设备
~~~~~~~~~~

Udev 在默认情况下，根据固件或 BIOS 的数据，或总线、插槽，以及 MAC 地址等物理特性命名网络设备。这种命名法的主要目的是保证网络设备在每次引导时获得一致的命名，而不是基于网卡被系统发现的时间进行命名。

在新的命名架构中，典型的网络设备名称类似 enp5s0 或 wlp3s0。

在内核命令行中禁用一致性命名
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**我感觉不推荐这个方法，毕竟还是要区分每个设备**

类似 eth0，eth1 这样的命名格式可以通过在内核命令行中加入 ``net.ifnames=0`` 而恢复: 适合主机上没有两块同类的网络设备(否则会混淆)

创建自定义 Udev 规则
~~~~~~~~~~~~~~~~~~~~~

可以创建自定义 Udev 规则，定制命名架构。系统中包含一个生成初始规则的脚本，执行以下命令生成初始规则:

.. literalinclude:: lfs_sys_config/udev-init
   :caption: 初始化udev规则

此时会生成 ``/etc/udev/rules.d/70-persistent-net.rules`` 内容是每个网络接口设备(NIC))，类似:

.. literalinclude:: lfs_sys_config/70-persistent-net.rules
   :caption: ``/etc/udev/rules.d/70-persistent-net.rules`` 案例


CD-ROM符合链接 / 处理重复设备
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

这段我没有实践，看情况再说

一般网络配置
===============

.. note::

   这段网络配置根据实际情况修订，我是根据上述 ``/etc/udev/rules.d/70-persistent-net.rules`` 识别网卡MAC来确定主网卡配置

.. literalinclude:: lfs_sys_config/ifconfig.eno1
   :caption: 配置网卡静态IP

``/etc/resolv.conf``
---------------------

.. literalinclude:: lfs_sys_config/resolv
   :caption: 配置 ``/etc/resolv.conf``

主机名
--------------

.. literalinclude:: lfs_sys_config/hostname
   :caption: 配置主机名

自定义 ``/etc/hosts``
-------------------------

.. literalinclude:: lfs_sys_config/hosts
   :caption: ``/etc/hosts``

System V 引导脚本使用与配置
=============================

当前构建的 LFS 版本使用一种称为 SysVinit 的特殊引导架构，它的设计基于一组运行级别 (run level)。不同系统的引导过程可能会区别很大；一般不能假设那些在某个 Linux 发行版上正常工作的方法也能在 LFS 正常工作。LFS 有一些独特的工作方式，但它也遵守被广泛接受的标准。

.. literalinclude:: lfs_sys_config/inittab
   :caption: ``/etc/inittab``

切换运行级别
--------------

通过命令 ``init <runlevel>`` 可以切换运行级别

在 /etc/rc.d 中有一些名字如同 rc?.d 的目录 (这里 ? 是运行级别编号)，以及一个目录 rcS.d，这些目录都包含一些符号链接。它们的文件名都以 K 或 S 开头，且文件名中这两个字母之后一定有两位数字。K 表示停止 (杀死，kill) 一个服务，而 S 表示启动 (start) 一个服务。两位数字决定脚本运行的顺序，从 00 到 99 —— 数字更小的脚本更早执行。当 init 切换到另一个运行级别时，它会执行这些脚本，从而适当地启动或停止服务，满足选择的运行级别要求。

Udev 引导脚本
-----------------

/etc/rc.d/init.d/udev 初始化脚本启动 udevd，触发内核已经创建的“冷插拔”设备，并等待所有 udev 规则执行完毕。

配置系统时钟
----------------

setclock 脚本从硬件时钟读取时间，硬件时钟也常被称为 BIOS 时钟或互补金属氧化物半导体 (CMOS) 时钟。如果硬件时钟被设为 UTC 时间，该脚本会根据 /etc/localtime 文件 (它告知 hwclock 程序用户处于哪个时区)，将硬件时钟的时间转换成本地时间。不存在确定硬件时钟是否为 UTC 的方法，因此这必须手动设置。

不确定您的硬件时钟是否设置为 UTC，运行 ``hwclock --localtime --show`` 命令，它会显示硬件时钟给出的当前时间。

执行以下命令，创建新的 /etc/sysconfig/clock 文件:

.. literalinclude:: lfs_sys_config/clock
   :caption: 设置时钟

配置Linux控制台
------------------

console 脚本读取 /etc/sysconfig/console 中的配置信息。它根据配置决定使用何种键映射和控制台字体。一些与特定语言相关的 HOWTO 文档可以帮助您进行配置:  `TLDP: 4.7. Other (human) Languages <https://tldp.org/HOWTO/HOWTO-INDEX/other-lang.html>`_

``/etc/sysconfig/console`` 我没有修订，根据指南中 "使用美式键盘，则可以忽略本节的大多数内容。如果不创建本节的配置文件 (且 rc.site 中没有对应的设置)，则 console 脚本什么也不做。"

对于中文，日文，韩文，以及其他一些语言文字，无论如何配置 Linux 控制台，都不可能正常显示所需要的字符。这些语言的用户应该安装 X 窗口系统，能够覆盖所需要的字符的字体，以及合适的输入法 (如 SCIM 支持许多语言的输入)。

在引导时创建文件
------------------

有时，我们希望在引导时创建一些文件，例如可能需要 /tmp/.ICE-unix 目录。为此，可以在 /etc/sysconfig/createfiles 配置脚本中创建一项。该文件的格式包含在默认配置文件的注释中。

配置 Sysklogd 脚本
--------------------

sysklogd 脚本启动 sysklogd 程序，这是 System V 初始化过程的一部分。-m 0 选项关闭 sysklogd 每 20 分钟写入日志文件的时间戳。

``rc.site``
---------------

可选的 /etc/sysconfig/rc.site 文件包含了为每个 System V 引导脚本自动设定的配置。

/etc/sysconfig/ 目录中 hostname，console，以及 clock 文件中的变量值也可以在这里设定。如果这些分立的文件和 rc.site 包含相同的变量名，则分立文件中的设定被优先使用。

rc.site 也包含自定义引导过程其他属性的参数。设定 IPROMPT 变量会启用引导脚本的选择性执行。其他选项在文件注释中描述。

自定义引导和关机脚本
----------------------

可以微调 rc.site 文件以进一步提高速度，或根据您的个人品味调整引导消息。

配置系统 Locale
==================

Glibc 支持的所有 locale 可以用以下命令列出

.. literalinclude:: lfs_sys_config/locale
   :caption: 列出所有支持locale

这里可以看到我前期中设置了少数locale支持:

.. literalinclude:: lfs_sys_config/locale_output
   :caption: 列出所有支持locale，显示少量支持

Shell 程序 /bin/bash (下文称为 “shell”) 使用一组初始化文件，以帮助创建其运行环境。这些文件有不同的使用场合，可能以不同方式影响登录和交互环境。/etc 中的文件提供全局设定。如果对应的文件同时在用户主目录中存在，它们可能覆盖全局设定。

/bin/login 在用户成功登录后，会读取 /etc/passwd 中指定的 shell，并启动一个交互式登录 shell 进程。

在确定设定所需的各项设定值后，创建 /etc/profile以设定您期望的 locale，但是在 Linux 控制台中运行时则使用 C.UTF-8 locale (以防程序输出 Linux console 无法显示的字符)：

.. literalinclude:: lfs_sys_config/locale_setup
   :caption: 设置 locale

.. note::

   C (默认 locale) 和 en_US (推荐美式英语用户使用的 locale) 是不同的。C locale 使用 US-ASCII 7 位字符集，并且将最高位为 1 的字节视为无效字符。因此，ls 等命令会将它们替换为问号。另外，如果试图用 Mutt 或 Pine 发送包含这些字符的邮件，会发出不符合 RFC 标准的消息 (发出邮件的字符集会被标为 unknown 8-bit，即“不明 8 位字符集”)。因此，只能在确信自己永远不会使用 8 位字符时才能使用 C locale。

.. note::

   我修订为 ``en_US.UTF-8``

创建 /etc/inputrc 文件
=======================

inputrc 文件是 Readline 库的配置文件，该库在用户从终端输入命令行时提供编辑功能。它的工作原理是将键盘输入翻译为特定动作。Readline 被 Bash 和大多数其他 shell，以及许多其他程序使用。

多数人不需要 Readline 的用户配置功能，因此以下命令创建全局的 /etc/inputrc 文件，供所有登录用户使用。

如果要对于某个用户覆盖掉默认直，可以在该用户的主目录下创建 .inputrc 文件，包含需要修改的映射。

.. literalinclude:: lfs_sys_config/inputrc
   :caption: 创建 ``/etc/inputrc``

创建 /etc/shells 文件
=========================

shells 文件包含系统登录 shell 的列表，应用程序使用该文件判断 shell 是否合法。该文件中每行指定一个 shell，包含该 shell 相对于目录树根 (/) 的路径。

.. literalinclude:: lfs_sys_config/shells
   :caption: 创建 ``/etc/shells``

