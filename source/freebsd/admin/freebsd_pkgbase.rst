.. _freebsd_pkgbase:

==========================
FreeBSD pkgbase
==========================

.. warning::

   本文升级实践有点问题，改为 :ref:`upgrade_freebsd_pkgbase`

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

   按照官方文档 `FreeBSD 15.1-RELEASE Upgrading Instructions <https://www.freebsd.org/releases/15.1R/upgrading/>`_ 进行 :ref:`upgrade_freebsd_pkgbase`

参考
=========

- `FreeBSD Wiki: Packaging FreeBSD base <https://wiki.freebsd.org/action/show/pkgbase>`_
- `FreeBSD 15.1-RELEASE Upgrading Instructions <https://www.freebsd.org/releases/15.1R/upgrading/>`_
