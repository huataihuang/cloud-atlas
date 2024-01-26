.. _gentoo_overlays:

=======================
Gentoo Overlays
=======================

Gentoo Overlays 项目成员维护了独立仓库，之前采用 ``app-portage/layman`` (已经废弃)维护，现在采用 ``eselect repository`` 来选择( 参考 `gentoo linux wiki: eselect/repository <https://wiki.gentoo.org/wiki/Eselect/Repository>`_ )

安装
========

- 安装 ``app-eselect/eselect-repository`` :

.. literalinclude:: gentoo_overlays/install_eselect-repository
   :caption: 安装 ``app-eselect/eselect-repository``

.. note::

   在 :ref:`gentoo_ebuild_repository` ，我已经实践过一个简单的自建 repository 。现在我将要使用互联网上公开维护的社区仓库

配置
===========

初始设置
------------

- ``REPOS_CONF`` ``/etc/eselect/repository.conf`` 配置文件中有一个变量 ``REPOS_CONF`` 指定了repos配置文件存放在哪里 ，该目录必须存在用于模块存储: 默认是 ``/etc/portage/repos.conf/`` 目录

我在 :ref:`gentoo_ebuild_repository` 已经创建了上述目录

``repos.gentoo.org``
--------------------------

- 首先获取 ``repos.gentoo.org`` 提供的所有仓库列表:

.. literalinclude:: gentoo_overlays/eselect_repository
   :caption: 列出所有repository

输出有将近400个仓库，我选择 ``gentoo-zh`` (也就是 gentoo.cn)仓库，以便能够安装 :ref:`gentoo_sway_fcitx`

- 激活 ``gentoo-zh`` 仓库:

.. literalinclude:: gentoo_overlays/enable_repository
   :caption: 激活 ``gentoo-zh`` 仓库

输出显示:

.. literalinclude:: gentoo_overlays/enable_repository_output
   :caption: 激活 ``gentoo-zh`` 仓库的输出信息

- 此时检查 ``/etc/portage/repos.conf/eselect-repo.conf`` 就可以看到新添加仓库:

.. literalinclude:: gentoo_overlays/eselect-repo.conf
   :caption: ``/etc/portage/repos.conf/eselect-repo.conf`` 添加了激活的仓库 ``gentoo-zh`` 配置

如果要禁用仓库，则使用:

.. literalinclude:: gentoo_overlays/disable_repository
   :caption: 禁用 ``gentoo-zh`` 仓库

如果要删除仓库，则使用:

.. literalinclude:: gentoo_overlays/remove_repository
   :caption: 移除 ``gentoo-zh`` 仓库

- 使用 ``emaint`` 对新添加Portage进行软件库同步:

.. literalinclude:: gentoo_overlays/emaint_sync
   :caption: 使用 ``emaint`` 同步新添加的软件库

然后就可以按照正常方式进行 :ref:`gentoo_emerge` 安装了

参考
======

- `gentoo linux wiki: Project:Overlays/Overlays guide <https://wiki.gentoo.org/wiki/Project:Overlays/Overlays_guide>`_
- `gentoo linux wiki: eselect/repository <https://wiki.gentoo.org/wiki/Eselect/Repository>`_
