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

- 方法二:  在 ``/etc/portage/package.accept_keywords`` 中添加你想安装的被mask的关键字

.. literalinclude:: gentoo_makeconf/package.accept_keywords
   :caption: 创建 ``/etc/portage/package.accept_keywords`` 包含接受的软件包关键字

参考
=====

- `gentoo linux wiki: /etc/portage/make.conf <https://wiki.gentoo.org/wiki//etc/portage/make.conf>`_
