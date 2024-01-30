.. _gentoo_makeconf:

==================
Gentoo make.conf
==================

``/etc/portage/make.conf`` 是全局范围定制Portage环境的主要配置文件，对应的 ``/etc/portage`` 目录下则存放针对单个或局部的软件编译安装配置文件。

当配置 ``make.conf`` ，则会对所有 ``emerge`` 软件包产生影响

软件包关键字
==============

.. note::

   我为了解决 :ref:`gentoo_mbp_wifi` 需要安装 ``net-wireless/broadcom-sta`` 但是系统默认mask了 ``~amd64`` ，参考 `Can't update. Package masked by amd64 keyword <https://www.reddit.com/r/Gentoo/comments/y113y9/cant_update_package_masked_by_amd64_keyword/>`_ 解决。

   我想知道 ``~amd64`` 的波浪号含义，问了 :ref:`gpt` 得到以下回答

- 方法一: 接受测试阶段的 ``amd64`` 架构:

.. literalinclude:: gentoo_makeconf/accept_keywords_test_amd64
   :caption: 在 ``/etc/portage/make.conf`` 配置接受测试阶段的AMD64架构软件包

Gentoo的 ``/etc/portage/make.conf`` 配置文件中 ``ACCEPT_KEYWORDS="~amd64"`` 是指定了系统所使用的软件包关键字:

软件包关键字（Keywords）用于指定软件包的可用性和稳定性级别，软件包的关键字通常有以下几种情况:

- 空关键字（empty keyword）：表示软件包是稳定版本，已经经过广泛测试并被认为是可靠和稳定的
- 给定关键字（given keyword）：表示软件包是非稳定版本，需要进一步测试或者尚未被广泛使用
- 波浪号关键字（tilde keyword）：表示软件包是测试版本，处于快速迭代和开发阶段

``ACCEPT_KEYWORDS="~amd64"`` 指定了系统使用的软件包关键字为波浪号关键字（tilde keyword），并且目标架构为 amd64。这意味着系统将接受安装和更新处于测试阶段的软件包，并且适用于 amd64 架构的处理器。

- 方法二:  在 ``/etc/portage/package.accept_keywords/`` 目录下添加包含你想安装的被mask的关键字的配置文件，例如，在 :ref:`gentoo_sway_fcitx` 和 :ref:`gentoo_kde_fcitx` ，为了能够支持 :ref:`wayland` 环境下的中文输入，需要安装 :ref:`gentoo_overlays` 仓库提供的非稳定版本输入法，就需要为每个 :ref:`fcitx` 相关软件包配置 ``~amd64`` 关键字。即创建 ``/etc/portage/package.accept_keywords/fcitx5`` 内容如下:

.. literalinclude:: gentoo_sway_fcitx/package.accept_keywords.fcitx5
   :caption: 创建 ``/etc/portage/package.accept_keywords/fcitx5`` 包含需要安装非稳定版本的fcitx相关软件

``mask`` 和 ``unmask``
========================

在遇到特定需要解决mask的时候，例如 :ref:`gentoo_sway_fcitx` 时候启用了 ``~amd64`` ，但是发现全局启用 ``unstable`` 带来系统问题(内核版本过于追新，firefox版本过高无法完成编译等)，所以我手工调整关闭全局 ``unstable`` ，改为上文的针对单个应用配置 ``~amd64`` 。不过，也发现一个问题， 部分依赖已经使用的高版本被mask掉了。 :strike:`所以，再次配置部分应用unmask。` 根据提示，实际采用了上文针对单个被mask掉的应用重新添加 ``~amd64`` 配置。所以，这里案例是一个举例，并非我最后的实际配置

和上文 ``软件包关键字`` 相同，有两种方法:

- 方法一: ``/etc/portage/package.unmask`` 配置文件(举例)

.. literalinclude:: gentoo_makeconf/package.unmask
   :caption: 通过 ``/etc/portage/package.unmask`` 配置unmask案例

- 方法二: 在 ``/etc/portage/package.unmask`` 目录下独立为不同应用分别创建配置文件(举例)

.. literalinclude:: gentoo_makeconf/package.unmask_files
   :caption: 在 ``/etc/portage/package.unmask`` 目录下创建独立配置文件

``mask`` 掉某个软件包配置方法其实和 ``unmask`` 类似，只不过命名是 ``/etc/portage/package.mask`` (文件或目录下独立配置文件)，所以不再重复说明。

参考
=====

- `gentoo linux wiki: /etc/portage/make.conf <https://wiki.gentoo.org/wiki//etc/portage/make.conf>`_
- `gentoo linux wiki: Knowledge Base:Unmasking a package <https://wiki.gentoo.org/wiki/Knowledge_Base:Unmasking_a_package>`_
