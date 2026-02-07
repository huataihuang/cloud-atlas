.. _obsidian_freebsd:

===========================
FreeBSD环境运行Obsidian
===========================

Obsidian对Linux支持非常完美，但是在FreeBSD平台是"社区驱动"的非官方支持，官方并没有提供FreeBSD版本。不过由于Obsidian是一个Electron应用，所以FreeBSD社区通过以下方式实现运行:

- Ports 编译：可以通过 FreeBSD 的 Ports 树（ ``textproc/obsidian`` ）来安装，本质上是利用了 FreeBSD 上的 electron 运行时来加载 Obsidian 的核心文件。
- Linux 兼容层 ( :ref:`linuxulator` )：通过开启 Linux 兼容模式来运行 Linux 版的 Obsidian，但配置过程较为繁琐。

.. note::

   在 FreeBSD 上，Obsidian 的某些高级功能（如内置的自动更新或某些调用底层系统 API 的插件）可能会遇到兼容性问题。

安装
======

- 同步ports:

.. literalinclude:: ../../../freebsd/admin/freebsd_packages_ports/git_checkout_ports
   :caption: 先check out出ports

.. literalinclude:: ../../../freebsd/admin/freebsd_packages_ports/git_pull_ports
   :caption: 更新ports

- 检查依赖软件包:

.. literalinclude:: obsidian_freebsd/depends-list
   :caption: 检查依赖的软件包

.. warning::

   注意是使用 ``make depends-list`` 命令的 **depends** 和 **list`` 之间有一个连字符 ``-`` ，如果遗漏连字符 ``-`` 会 **误触发** 自动下载源代码并安装。由于Obsidian依赖 ``Electron`` 和 ``chromium`` 源代码非常庞大，纯源码编译非常耗时(甚至可能跑一整天)，所以误触发自动源码编译的话，请按 ``ctrl-c`` 终止。建议先二进制安装所有依赖，再单独编译安装obsidian来节约时间。

- 执行以下命令先安装所有 ``依赖`` 的 **二进制包** :

.. literalinclude:: obsidian_freebsd/install-missing-packages
   :caption: 快速完成依赖的二进制包安装

这里我遇到一个报错:

.. literalinclude:: obsidian_freebsd/install-missing-packages_error
   :caption: 报错

通常是因为 Ports 树版本与 pkg 软件仓库版本不一致（Desync）导致的。Ports 树里包含了一个名为 ``devel/py-ipython-pygments-lexers`` 的新包，但 FreeBSD 的官方预编译包服务器（pkg repository）还没把这个包构建出来。

解决的方法是手工编译出缺少的依赖(报错的包单独编译)然后再继续主程序安装:

.. literalinclude:: obsidian_freebsd/install-missing-packages_error_fix
   :caption: 手工编译依赖包，然后继续主程序安装

.. note::

   实际上这个依赖软件安装非常庞大，甚至涉及到安装大量的Python包，QT5，Xorg，rust等等，大约需要下载2G安装包，安装以后需要占用10GB磁盘空间

- 补齐依赖以后，只从Ports编译Obsidian包装器:

.. literalinclude:: obsidian_freebsd/install_obsidian
   :caption: 仅编译Obsidian包装器

由于 Obsidian 本身主要是 JavaScript 核心文件，只要依赖项（如 Electron）是用 pkg 装好的，这一步会非常快。

.. warning::

   由于我想保持一个精简的FreeBSD桌面，我放弃直接在FreeBSD上安装Obsidian，改为在我的持续运行的Linux服务器上运行一个轻量级桌面环境，然后通过网页流式传输画面来实现跨平台的Obsidian(利用容器化技术将 GUI 应用 Web 化): :ref:`obsidian_freebsd_web`

参考
=======

- `Official FreeBSD support? <https://forum.obsidian.md/t/official-freebsd-support/41601>`_
