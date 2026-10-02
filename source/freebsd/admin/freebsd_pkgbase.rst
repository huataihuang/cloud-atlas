.. _freebsd_pkgbase:

==========================
FreeBSD pkgbase
==========================

之前旧版本 :ref:`freebsd_update_upgrade` 实践中，对于 **版本升级** 可以使用 ``freebsd-update`` 工具来完成。但是，当我尝试将 ``15.0-RELEASE`` 升级到 ``15.1-RELEASE`` ，使用如下命令:

.. literalinclude:: freebsd_pkgbase/freebsd-update
   :caption: 尝试 ``freebsd-update`` 来升级RELEASE

提示信息却是:

.. literalinclude:: freebsd_pkgbase/freebsd-update_output
   :caption: 尝试 ``freebsd-update`` 提示和 ``packaged base`` 不兼容

所以仔细阅读了 `FreeBSD Wiki: Packaging FreeBSD base <https://wiki.freebsd.org/action/show/pkgbase>`_

``pkgbase`` 是使用 ``pkg`` 包管理工具(就像在prts和package集合用于第三方软件那样)管理FreeBSD的base系统。

``pkgbase`` 取代了:

- 使用 ``bsdinstall`` 的操作系统安装的 ``.txz`` 发布软件
- 使用 ``freebsd-update`` 来更新操作系统

``pkgbase`` 补充了 :ref:`freebsd_build_from_source` :

- FreeBSD-CURRENT和FreeBSD-STABLE的简单安装可以使用 ``pkg`` 进行更新，已经不再需要从源代码编译

配置文件
===========

在 ``/etc/pkg/`` 目录下有系统发行版默认配置文件 ``FreeBSD.conf`` ，定义了 ``pkg`` 更新的范围。需要注意，默认情况下， ``FreeBSD-base`` 没有激活更新:

.. literalinclude:: freebsd_pkgbase/FreeBSD.conf
   :caption: 系统默认 ``/etc/pkg/FreeBSD.conf`` 没有激活 ``FreeBSD-base`` 更新
   :emphasize-lines: 3,31

注意，这个 ``/etc/pkg/FreeBSD.conf`` 是发行版维护的配置文件，所以不要直接修改。因为即使修改生效，下次更新有可能被发行版覆盖。所以按照注释说明，标准做法应该是修改 ``/usr/local/etc/pkg/repos/FreeBSD.conf`` :

``/usr/local/etc/pkg/repos/`` 目录是用户自定义配置目录，该目录下的配置文件优先级高于发行版维护的 ``/etc/pkg/`` 目录下配置文件。因为 ``pkg`` 是先读取 ``/etc/pkg/`` 目录下配置文件，然后再读取 ``/usr/local/etc/pkg/repos/`` 目录下配置文件，同名的配置文件内容会以后读取的内容覆盖先读取的内容，所以用户自定义目录 ``/usr/local/etc/pkg/repos/`` 目录下同名配置文件优先级更高。

将 ``/etc/pkg/FreeBSD.conf`` 配置复制到 ``/usr/local/etc/pkg/repos/`` 目录下进行修改，这样就能够覆盖发行版默认配置:

.. literalinclude:: freebsd_pkgbase/user_FreeBSD.conf
   :caption: 用户自定义 ``/usr/local/etc/pkg/repos/FreeBSD.conf``
   :emphasize-lines: 7

.. warning::

   我发现我可能理解错了，直接修改 ``/usr/local/etc/pkg/repos/FreeBSD.conf`` 似乎不是规范方法，我修订上述配置发现并没有进行RELEASE更新(原因是配置文件就是指定当前 ``url: "pkg+https://pkg.FreeBSD.org/${ABI}/base_release_${VERSION_MINOR}"`` )

   所以下文按照官方文档 `FreeBSD 15.1-RELEASE Upgrading Instructions <https://www.freebsd.org/releases/15.1R/upgrading/>`_ 进行

.. _upgrade_freebsd_pkgbase:

Upgrading with Base System Packages
======================================

使用 ``pkgbase`` 系统部署也通过 ``pkg`` 升级:

- 当前安装快照 (如果系统使用 :ref:`zfs` ):

.. literalinclude:: freebsd_pkgbase/bectl
   :caption: 创建快照

此时 ``boot loader`` 会提供一个菜单来启动这个快照(如果更新需要回滚的话)

- 更新安装的系统

在升级到新release之前，需要确保安装的系统已经更新到最新

.. literalinclude:: freebsd_pkgbase/upgrade
   :caption: 首先确保更新系统up to date

- 更新Base系统:

.. literalinclude:: freebsd_pkgbase/upgrade_base
   :caption: 更新base系统

更新以后，需要review一下 ``pkg`` 输出的信息，一些软件包需要进一步的配置，例如运行 ``service <name> setup``

.. literalinclude:: freebsd_pkgbase/upgrade_base_output
   :caption: 更新base系统提示信息

.. note::

   按照提示检查系统是否使用 :ref:`local-unbound` 以做对应处理 

- 更新第三方内核模块(如果已经安装了第三方模块):

.. literalinclude:: freebsd_pkgbase/upgrade_ports-kmods
   :caption: 更新第三方内核模块

如果没有异常，且没有安装第三方模块，输出类似:

.. literalinclude:: freebsd_pkgbase/upgrade_ports-kmods_output
   :caption: 更新第三方内核模块信息

- 检查是否存在失败的配置更新

如果 ``pkg`` 在更新时不能合并配置文件，就会将新的配置文件安装成 ``.pkgnew`` 文件，则检查方法如下:

.. literalinclude:: freebsd_pkgbase/check_failed_config
   :caption: 检查是否存在失败配置升级

如果存在 ``.pkgnew`` 则需要对比部署版本(例如, ``diff /etc/rc.conf /etc/rc.conf.pkgnew`` )并合并任何需要的配置

- 更新Boot Loader:

AArch64系统已经使用了UEFI boot loader，要检查AMD64系统使用的boot loader，执行以下命令

.. literalinclude:: freebsd_pkgbase/check_bootloader
   :caption: 检查boot loader

这里可能看到的是UEFI:

.. literalinclude:: freebsd_pkgbase/check_bootloader_output
   :caption: 检查boot loader

- 标记ESP - 使用以下命令来检查boot loader的EFI System Partition(ESP)

.. literalinclude:: freebsd_pkgbase/efibootmgr
   :caption: 检查ESP分区

输出案例

.. literalinclude:: freebsd_pkgbase/efibootmgr_output
   :caption: 检查ESP分区案例

当前激活的boot loader项目的前面会有一个 ``+`` 符号

- 挂载ESP: 如果ESP分区没有挂载到 ``/boot/efi`` 则执行以下命令挂载:

.. literalinclude:: freebsd_pkgbase/mount_esp
   :caption: 挂载ESP分区

- 安装Boot Loader

在AMD64系统中，通过以下命令更新以配置和额默认位置的boot loader

.. literalinclude:: freebsd_pkgbase/upgrade_boot_loader
   :caption: 更新boot loader

注意一些安装可能使用相反大写路径(例如 ``EFI/BOOT/BOOTX64.EFI`` )或者没有使用 ``freebsd/loader.efi``

在AArch64系统中，执行以下命令:

.. literalinclude:: freebsd_pkgbase/upgrade_boot_loader_aarch64
   :caption: 更新boot loader(AArch64)

- 最后重启完成FreeBSD 15.1-RELEASE的升级:

.. literalinclude:: freebsd_pkgbase/finish
   :caption: 完成更新重启系统

参考
=========

- `FreeBSD Wiki: Packaging FreeBSD base <https://wiki.freebsd.org/action/show/pkgbase>`_
- `FreeBSD 15.1-RELEASE Upgrading Instructions <https://www.freebsd.org/releases/15.1R/upgrading/>`_
