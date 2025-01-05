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

:ref:`thin_jail` 初始化
----------------------------------

需要先构建一个FreeBSD常规Jail，例如 :ref:`thin_jail` ，但是不能直接执行配置，而是在配置前还有一个构建Linux兼容层的步骤。

- 现在先完成一个常规的 :ref:`thin_jail` (部分步骤已经在 :ref:`thin_jail` 做过，所以跳过):

(已完成,跳过)为模板创建发行版，这个是只读的:

.. literalinclude:: thin_jail/zfs
   :caption: 在ZFS中创建模板数据集

(已完成,跳过)和 :ref:`thick_jail` 一样下载用户空间:

.. literalinclude:: thick_jail/fetch
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

启动Linux Jail
================

.. literalinclude:: linux_jail/start_d2l
   :caption: 启动 ``d2l`` Linux Jail

注意，对于Linux Jail的使用其实分两部分:

- 直接使用 ``jexec d2l`` 进入的是常规 FreeBSD Jail

- 执行以下 ``jexec`` 结合 ``chroot`` 将访问 :ref:`debian` 系统Linux二进制兼容:

.. literalinclude:: linux_jail/jexec_chroot
   :caption: ``jexec`` 结合 ``chroot`` 将访问 :ref:`debian` 系统Linux二进制兼容

此时虽然 ``df -h`` 看不出差别:

.. literalinclude:: linux_jail/df
   :caption: ``df -h`` 看到似乎和之前普通Jail一样挂载

但是执行 ``ls /etc/`` 就可以看到该目录下都是 ``debian`` 相关配置文件，例如 ``cat /etc/debian_version`` 可以看到版本是 ``12.8`` 。接下来的操作就好像是在 :ref:`debian` 中进行，例如可以执行 ``apt update`` 更新debian系统

