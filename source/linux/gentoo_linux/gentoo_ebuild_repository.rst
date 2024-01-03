.. _gentoo_ebuild_repository:

================================
Gentoo ebuild repository
================================

在 :ref:`gentoo_chinese_input` 安装了 :ref:`fcitx` ``5`` ，带来一个问题，就是相应的输入法引擎的 ``ebuild`` 都是采用了 :ref:`version_by_slot` ``4`` 。

这样就需要自己修改 ``ebuild`` ，然后通过自建的 ebuild repository 来提供overlay仓库:

- 创建ebuild repository可以存放Portage安装的 ebuild
- 在 ebuild repository 中添加 ebuild 之后，就可以与他人共享
- 创建 ebuild repository 和 ebuild 可以帮助我们从根本上了解跟多有关 Gentoo的工作原理
- 发布 ebuild repository 也是为社区作出贡献的好方法

创建一个空的 ebuild repository
=======================================

- 首先安装 ``app-eselect/eselect-repository`` 和 ``dev-util/pkgdev`` (用于创建ebuild包Manifest文件):

.. literalinclude:: gentoo_ebuild_repository/eselect-repository_pkgdev
   :caption: 安装 ``app-eselect/eselect-repository`` 和 ``dev-util/pkgdev``

- 使用 ``eselect repository create <repository_name>`` 可以创建仓库名:

.. literalinclude:: gentoo_ebuild_repository/repository_create
   :caption: 创建 repository ，我这里使用名字 ``cloud-atlas``

此时输出显示:

.. literalinclude:: gentoo_ebuild_repository/repository_create_output
   :caption: 创建 repository 输出
   :emphasize-lines: 10,12

检查生成的 ``/etc/portage/repos.conf/eselect-repo.conf`` 配置文件，就可以看到 ``cloud-atlas`` 命名的仓库对应的指定位置就是 ``/var/db/repos/cloud-atlas`` :

.. literalinclude:: gentoo_ebuild_repository/eselect-repo.conf
   :caption: ``/etc/portage/repos.conf/eselect-repo.conf``
   :emphasize-lines: 3,4

.. note::

   一些用户会将只用于单台主机的个人软件包存凡在一个名为 ``local`` 的 ebuild repository，也就是使用 ``eselect repository create local`` 命令来创建

如果创建一个用于发布的repository，该repository包含一个主要的软件包以及依赖软件包，那么给仓库器一个和内容相关的名称会有所绊住(ebuild仓库通常以维护人的名字命名，但不总是最具描述性的名称)。这个方式同样适合伯阿汉特定主题为中心的软件包仓库。

跟踪变化(可选)
================

在创建和维护任何ebuild仓库是，使用版本控制系统是良好的做法:

- 版本控制系统可以跟踪ebuild文件的更改并允许撤销错误
- 版本控制提供了检索信息方便了解ebuild仓库变化
- Portage 支持多个版本控制系统自动提供ebuild仓库同步，可以从Portage可用的ebuild仓库检索更新

git
--------

git维护ebuild仓库优点:

- git允许不同的版本分支，这对测试非常有用
- git提供了简单的 ``diff`` 工具以及其他功能，可以帮助创建和维护ebuild仓库

执行步骤:

- 对上文创建的 ``cloud-atlas`` 仓库进行git初始化:

.. literalinclude:: gentoo_ebuild_repository/git_init_ebuild_repos
   :caption: 使用 ``git init`` 初始化 ebulid 仓库

添加ebuild到仓库
==================

- 创建按照类别名和应用名的目录，例如我这里为 :ref:`gentoo_chinese_input` 构建一个 :ref:`version_by_slot` ``5`` 的 ``app-i18n/fcitx-rime`` ebuild，则对应建立子目录 ``app-i18n/fcitx-rime`` ，然后在目录下复制好自己定制的 ``fcitx-rime-0.3.2.ebuild`` :

.. literalinclude:: gentoo_ebuild_repository/put_ebuild_repos
   :caption: 将定制的 ebuild 复制到仓库目录下

这里采用了自己修订的 ``fcitx-rime-0.3.2.ebuild`` (修订为 ``SLOT 5`` 依赖) :

.. literalinclude:: gentoo_ebuild_repository/fcitx-rime-0.3.2.ebuild
   :caption: 自己修订的 :ref:`version_by_slot` ``5`` ``app-i18n/fcitx-rime`` ebuild
   :emphasize-lines: 28,30

在完成索引之后，就可以进行安装:

.. literalinclude:: gentoo_ebuild_repository/install_fcitx-rime_5
   :caption: 安装定制的 :ref:`version_by_slot` ``5`` ``app-i18n/fcitx-rime``

此时输出显示:

.. literalinclude:: gentoo_ebuild_repository/install_fcitx-rime_5_output
   :caption: 安装定制的 :ref:`version_by_slot` ``5`` ``app-i18n/fcitx-rime`` 输出信息
   :emphasize-lines: 10,22

可以看到安装 ``app-i18n/fcitx-rime`` 采用了我定制的 ``cloud-atlas`` 仓库下的 ``ebuild`` ，覆盖(overlay)了默认的 ``gentoo`` 仓库

.. note::

   我发现 ``app-i18n/fcitx-rime`` 安装软件包非常庞大，主要是因为它依赖了Google提供的 ``leveldb`` ( ``tcmalloc`` 参数引入了庞大的 ``dev-libs/boost`` )，这是一个性能非常好的KV数据库，但是感觉我为了一个输入法安装如此庞大的依赖有些得不偿失。

   方法已经走通，我目前先尝试采用 ``fcitx`` 内置的简单拼音输入法(可能选词算法比较差些)

参考
=====

- `gnetoo linux wiki: Creating an ebuild repository <https://wiki.gentoo.org/wiki/Creating_an_ebuild_repository>`_
