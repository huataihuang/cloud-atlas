.. _linux_jail:

=====================
FreeBSD Linux Jail
=====================

FreeBSD 可以使用 :ref:`linuxulator` 和 ``debootstrap`` 在jail中运行Linux。由于jail没有内核，所以物理主机上需要启用Linux二进制兼容:

.. note::

   由于我的笔记本 :ref:`freebsd_wifi_bcm43602` 需要运行Linux :ref:`bhyve` 虚拟机，所以已经启用了 :ref:`linuxulator` 支持

- 在启动时启用Linux ABI:

.. literalinclude:: linux_jail/linux_enable
   :caption: 启动时启用Linux ABI

- 一旦配置了启动时启用Linux ABI，就可以立即用命令启用linux兼容，无需重启操作系统

.. literalinclude:: linux_jail/linux_start
   :caption: 启动Linux兼容

准备 :ref:`thin_jail`
==================================

为方便调整，我设置了环境变量来方便后续操作

.. literalinclude:: vnet_thin_jail/env
   :caption: 设置 jail目录和release版本环境变量

:ref:`thin_jail` 初始化
----------------------------------

需要先构建一个FreeBSD常规Jail，例如 :ref:`thin_jail` ，但是不能直接执行配置，而是在配置前还有一个构建Linux兼容层的步骤。

- 现在先完成一个常规的 :ref:`thin_jail` (部分步骤已经在 :ref:`thin_jail` 做过，所以跳过):

(已完成,跳过)为模板创建发行版，这个是只读的:

.. literalinclude:: thin_jail/zfs
   :caption: 在ZFS中创建模板数据集

(已完成,跳过)和 :ref:`thick_jail` 一样下载用户空间:

.. literalinclude:: vnet_thin_jail/fetch
   :caption: 下载用户空间

(已完成,跳过)将下载内容解压缩到模板目录:

.. literalinclude:: thin_jail/template
   :caption: 内容解压缩到模板目录

(已完成,跳过)将时区和DNS配置复制到模板目录:

.. literalinclude:: thin_jail/template_conf
   :caption: 时区和DNS配置复制到模板目录

(已完成,跳过)更新模板补丁:

.. literalinclude:: thin_jail/template_update
   :caption: 更新补丁

(已完成,跳过)从模板创建 :ref:`zfs` 快照:

.. literalinclude:: thin_jail/template_snapshot
   :caption: 模板创建 :ref:`zfs` 快照

.. note::

   以上步骤因为已经在实践 :ref:`thin_jail` 时做过，只需要做一次，所以在这里创建 Linux jail 的时候仅记录，但跳过不支持。

   **下面的步骤才是实际创建名为 d2l 的thin jail**

- ``需要执行`` 使用 OpenZFS 克隆功能创建名为 ``d2l`` 的thin jail，为后续构建 Linux jail 做准备:

.. literalinclude:: linux_jail/d2l
   :caption: 使用 OpenZFS 克隆功能创建名为 ``d2l`` 的thin jail

第一次启动 :ref:`thin_jail` d2l ( ``我跳过这步`` )
--------------------------------------------------------------

.. warning::

   我仔细看了FreeBSD Handbook，感觉手册中说第一次命令行启动 ``d2l`` 这样的jail，并在jail中安装 ``debootstrap`` ，然后执行 ``debootstrap`` 似乎有点折腾。

   :ref:`debootstrap` 是可以直接把 :ref:`debian` 系的操作系统直接复制到指定目录的，那么我为何不直接在物理主机上完成？

.. warning::

   我最终采用了跳过这步启动，而采用host主机上执行 :ref:`debootstrap`

.. note::

   现在我们启动一个常规的 :ref:`thin_jail` 名为 ``d2l`` ，但是还没有Linux兼容层的内容，需要启动以后通过 :ref:`debootstrap` 获取

- 执行以下命令 ``flying`` 方式启动 ``d2l`` :ref:`thin_jail` :

.. literalinclude:: linux_jail/start_j2l_first
   :caption: 首次命令 ``flying`` 方式启动 ``d2l`` :ref:`thin_jail`

这里采用命令方式而不是配置文件方式临时启动jail，以便能够进一步通过 :ref:`debootstrap` 来获得兼容

现在使用 ``jls`` 可以看到已经运行起来一个 ``d2l`` 的容器:

.. literalinclude:: linux_jail/start_j2l_first_jls
   :caption: 使用 ``jls`` 可以看到已经运行起 ``d2l`` jail

进入jail通过 :ref:`debootstrap` 获取Linux( ``我跳过这步`` )
---------------------------------------------------------------

.. warning::

   我最终采用了跳过这步启动，而采用host主机上执行 :ref:`debootstrap`

- 通过 ``jexec`` 进入 ``d2l`` jail:

.. literalinclude:: linux_jail/exec_d2l
   :caption: 通过 ``jexec`` 进入 ``d2l`` jail

- 完成后在host主机上停止 ``d2l`` :

 .. literalinclude:: linux_jail/stop_d2l
    :caption: 停止 ``d2l`` jail

( ``我的步骤`` )直接Host执行 :ref:`debootstrap` 获取Linux
-------------------------------------------------------------

.. literalinclude:: linux_jail/host_debootstrap
   :caption: 在host上完成 :ref:`debootstrap`

完成以后，在 ``/usr/local/jails/containers/d2l/compat/debian`` 目录下就是一个剥离出来独立的debian系统

- 检查对比 ``/etc/jail.conf`` 配置，将 Linux Jail 差异部分都写入 ``/etc/jail.conf.d/d2l.conf`` 中:

.. literalinclude:: linux_jail/d2l.conf
   :caption: Linux Jail差异部分配置在 ``/etc/jail.conf.d/d2l.conf``

.. note::

   在 ``d2l.conf`` 配置中，最后两行挂载文件系统采用了 ``nullfs`` ，这是一种回环文件系统，用于在host主机和jail之间共享文件: 多个jail可以挂载相同的host主机目录

启动Linux Jail
================

.. literalinclude:: linux_jail/start_d2l
   :caption: 启动 ``d2l`` Linux Jail

完成启动 ``d2l`` Linux Jail之后，在Host物理主机上可以看到容器挂载了Linux对应的设备文件系统以及procfs系统，所以此时在Host物理主机上执行 ``df -h`` 会看到:

.. literalinclude:: linux_jail/host_df
   :caption: 在Host主机上 ``df -h`` 可以看到Linux的设备兼容层已经挂载

注意，对于Linux Jail的使用其实分两部分:

- 直接使用 ``jexec d2l`` 进入的是常规 FreeBSD Jail

- 执行以下 ``jexec`` 结合 ``chroot`` 将访问 :ref:`debian` 系统Linux二进制兼容:

.. literalinclude:: linux_jail/jexec_chroot
   :caption: ``jexec`` 结合 ``chroot`` 将访问 :ref:`debian` 系统Linux二进制兼容

此时虽然 ``df -h`` 看不出差别:

.. literalinclude:: linux_jail/df
   :caption: ``df -h`` 看到似乎和之前普通Jail一样挂载

但是执行 ``ls /etc/`` 就可以看到该目录下都是 ``debian`` 相关配置文件，例如 ``cat /etc/debian_version`` 可以看到版本是 ``12.8`` 。接下来的操作就好像是在 :ref:`debian` 中进行，例如可以执行 ``apt update`` 更新debian系统

此时检查Linux环境:

.. literalinclude:: linux_jail/uname
   :caption: 使用 ``uname`` 检查Linux环境

输出类似:

.. literalinclude:: linux_jail/uname_output
   :caption: 使用 ``uname`` 检查Linux环境输出案例

異常排查
=============

普通用户身份无法使用网络
--------------------------

我发现一个问题，我在 :ref:`linux_jail_init` 中为jail中创建了一个 ``admin`` 帐号(并设置了 ``sudo`` ):

.. literalinclude:: linux_jail_init/admin
   :caption: Linux jail中创建用户组和用户admin

但是这个 ``admin`` 用户默认无法使用网络，例如 ``ping www.baidu.com`` 提示错误:

.. literalinclude:: linux_jail_init/admin_sock_error
   :caption: Linux jail中普通用户无法使用网络错误

只有通过 ``sudo ping www.baidu.com`` 才行。

这个问题仅在 ``chroot /compat/debian /bin/bash`` 之后才存在，如果没有进入Linux环境，仅仅是FreeBSD :ref:`thin_jail` 环境普通用户是完全正常使用网络的。

:strike:`也就是说Linux Jail中普通用户无法使用网络?`

通过 ``getcap`` 命令可以获得程序能力设置属性( `getcap: command not found <https://www.thegeekdiary.com/getcap-command-not-found/>`_ )，不过，在linux jail环境中， ``getcap`` 执行没有效果(无返回内容)

`Pinging from a base user wsl tumbleweed 5.15.90.1-microsoft-standard-WSL2 <https://www.reddit.com/r/openSUSE/comments/14neo41/pinging_from_a_base_user_wsl_tumbleweed/>`_ 看起来Windows的WSL环境中普通用户也不能执行 ``ping`` 。

参考 `ping as non-root fails due to missing capabilities #143 <https://github.com/grml/grml-live/issues/143>`_ 我尝试:

.. literalinclude:: linux_jail_init/setcap
   :caption: 通过 ``setcap`` 为ping程序手工设置能力

但是设置失败:

.. literalinclude:: linux_jail_init/setcap_error
   :caption: 通过 ``setcap`` 为ping程序手工设置能力，但是失败

- ``admin`` 用户使用 ``ssh`` 程序正常，可以远程访问其他系统

- 似乎和UDP协议相关会失败，而TCP协议似乎正常:

  - 尝试 ``dig www.baidu.com`` 提示 ``communications error to 192.168.0.1#53: connection refused`` ，但是 ``nslookup www.baidu.com`` 能常常解析
  - 尝试 ``nc -v 192.168.0.1 53`` 显示TCP的53端口正常打开 ``Connection to 192.168.0.1 53 port [tcp/domain] succeeded!`` ，但是指定UDP协议 ``nc -uv 192.168.0.1 53`` 则直接返回无输出

.. note::

   这个问题还在排查，目前仅发现是普通用户 ``admin`` 身份使用网络异常，其他执行脚本则正常(例如 :ref:`install_conda` 运行下载后的脚本安装正常)

`No internet access from inside jail! <https://forums.freebsd.org/threads/no-internet-access-from-inside-jail.78576/>`_ 提到设置 ``allow.raw_sockets;`` :

.. literalinclude:: linux_jail/d2l_raw_sockets.conf
   :caption: 在Linux Jail ``/etc/jail.conf.d/d2l.conf`` 中添加允许 ``raw_sockets``
   :emphasize-lines: 2

但是启动 ``d2l`` 容器之后，Linux的普通用户依然无法使用 ``ping`` 和 ``dig`` 这样的UDP程序。

在没有 ``chroot /compat/debian /bin/bash`` 之前的FreeBSD Jail中可以检查Jail是否允许 ``raw_sockets``

.. literalinclude:: linux_jail/sysctl
   :caption: 在FreeBSD Jail中(还没有chroot) ``sysctl`` 检查 ``allow_raw_sockets``

输出显示:

.. literalinclude:: linux_jail/sysctl_output
   :caption: 在FreeBSD Jail中(还没有chroot) ``sysctl`` 检查 ``allow_raw_sockets`` ，输出显示1表示允许

注意，默认情况下，在Host主机执行 ``sysctl security.jail.allow_raw_sockets`` 可以看到 ``security.jail.allow_raw_sockets: 0`` ，也就是默认不允许 ``raw_sockets`` 。以上在FreeBS Jail中输出显示 ``1`` 是因为我在 ``d2l.conf`` 配置中添加了 ``allow_raw_sockets;``

确实发现，在Linux Jail中，无法正常使用 ``ifconfig`` 和 ``ip`` 命令(在 `How to have network access inside a Linux jail? <https://forums.freebsd.org/threads/how-to-have-network-access-inside-a-linux-jail.76460/>`_ 讨论中提到了在Linux Jail中使用 ``ip`` 命令总是错误 ``Cannot open netlink socket: Address family not supported by protocol`` )

.. literalinclude:: linux_jail/ifconfig
   :caption: Linux Jail无法使用 ``ifconfig``
   :emphasize-lines: 16,19-21,33

同样，由于没有socks支持，运行 :ref:`jupyter` :

.. literalinclude:: linux_jail/juypter_socket_error
   :caption: 在Linux Jail中运行 :ref:`jupyter` 出现socket报错

简单小结
~~~~~~~~~~

**简单规律就是在Linux Jail中** :

- TCP协议栈是较为完整的
- 不支持UDP协议栈: DNS查询需要DNS服务器支持TCP查询协议(UDP查询会失败 ``connection refused`` )
- ``root`` 用户可以使用ICMP(ping)，但是普通用户不能
- Linux Jail没有socket支持，所以部分需要绑定sockets的服务，如 ``juypter`` 无法启动
- 可能的解决方案: 采用 :ref:`vnet_jail` 来实现独立完整的网络堆栈

``/home/admin`` 属主是root(错误)
------------------------------------

当 ``admin`` 用户通过ssh登录到Jail中(尚未 ``chroot`` 进入debian linux)，在尝试向 ``/compat/debian/home/admin`` 目录内复制文件，发现没有权限。检查发现 ``/compat/debian/home/admin`` 目录的属主是 ``root`` ，所以手工修订:

.. literalinclude:: linux_jail/fix_home
   :caption: 修订 ``/compat/debian/home/admin`` 目录属主

这里可能有一个问题，Linux系统 :ref:`debootstrap` 没有设置 ``/compat/debian/home/admin`` 内任何内容，这是因为当时目录存在，所以 ``useradd`` 命令没有使用 ``-m`` 参数，也就没有复制任何初始profile相关文件。这在后续 :ref:`install_conda` 时就没有为用户设置好环境。

所以可能需要在一开始就修复好目录，或者直接删除掉目录，创建 ``admin`` 帐号时通过 ``useradd`` 构建

改进的思路
=============

我期望在多个 Linux Jail 之间使用共享的 :ref:`debootstrap` 数据，思路是使用 :ref:`share_folder_between_jails`

参考
======

- `(Solved)How to have network access inside a Linux jail? <https://forums.freebsd.org/threads/how-to-have-network-access-inside-a-linux-jail.76460/>`_ 这个讨论非常详细，是解决Linux Jail普通用户网络问题的线索
- `(Solved)No internet access from inside jail! <https://forums.freebsd.org/threads/no-internet-access-from-inside-jail.78576/>`_
- `ping as non-root fails due to missing capabilities #143 <https://github.com/grml/grml-live/issues/143>`_ 
- `Setting up a (Debian) Linux jail on FreeBSD <https://forums.freebsd.org/threads/setting-up-a-debian-linux-jail-on-freebsd.68434/>`_ 一篇非常详细的Linux Jail实践

