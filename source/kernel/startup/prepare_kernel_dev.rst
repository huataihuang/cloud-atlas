.. _prepare_kernel_dev:

=======================
内核开发学习准备工作
=======================

内核版本
===========

`Linux Kernel Development <https://www.amazon.com/Linux-Kernel-Development-Developers-Library-ebook-dp-B003V4ATI0/dp/B003V4ATI0/>`_ (2.6.34)和 `Professional Linux Kernel Architecture <https://www.amazon.com/Professional-Kernel-Architecture-Wolfgang-Mauerer/dp/0470343435/>`_ (2.6.24) 解析Linux版本采用的是稳定内核系列 2.6.x ，大约相当于 RHEL/CentOS 6.x 时代主流Linux发行版采用的内核版本。这个系列内核具备了现代Linux系统的特性，同时代码量尚未急剧膨胀。

我采用 CentOS 6.10 系统，然后安装 `kernel v2.6 <https://kernel.org/pub/linux/kernel/v2.6/>`_ 内核

.. note::

   目前(2023年)，除了学习目的采用早期稳定内核v2.6，其他体验最新技术可以选择v6.1: 2023年2月，Linux 6.1成为2022 LTS(长期支持)内核，计划维护到2026年12月，特定LTS(通常是主要行业参与者协调，如Android)可能会一直维护到2028年12月。 `Linux 6.1 被选为 LTS 长期支持内核 <https://www.solidot.org/story?sid=74088>`_

开发环境准备
===============

- 在 :ref:`vmware_fusion` 安装 CentOS 6.10，采用最小化安装

- 注意，由于CentOS已经停止CentOS 6的更新，所以原先软件仓库配置已经不能使用。需要 :ref:`fix_centos6_repo`

- 操作系统安装完成后，采用 :ref:`init_centos` 中相似方法安装必要开发工具::

   yum install vim sysstat nfs-utils gcc gcc-c++ make \
     flex autoconf automake ncurses-devel zlib-devel git

安装索引工具
===============

在内核源代码浏览，需要使用索引工具，推荐使用 ``cscope`` 和 ``ctags`` ，以下命令进行安装::

   sudo yum install cscope ctags-etags

如果是debian系统，则安装 ``cscope exuberant-ctags``

.. note::

   - ``cscope`` 是用于在代码函数间转跳，可以跳到符号定义，搜索所有符号使用等
   - ``ctags`` 是 ``Tagbar`` 插件所需要的，也是 ``Omni completion`` (vim内置的自动补全机制) 所使用等，也可以用于代码函数转跳。 不过 ``ctags`` 不如 ``cscope`` 的转跳功能，因为 ``ctags`` 只能挑到符号定义位置。

在内核源代码目录下，有2种方式可以创建索引：

- 手工创建索引
- 使用内核提供的脚本创建索引

如果你不知道哪种方式更适合，推荐使用内核脚本

使用 scripts/tags.sh 脚本创建索引
----------------------------------

内核源代码提供了一个很好的脚本 ``scripts/tags.sh`` 来创建内核索引数据库，也就是使用 ``make cscope`` 和 ``make tags`` 规则来创建索引，类似如下::

   make O=. ARCH=arm SUBARCH=omap2 COMPILED_SOURCE=1 cscope tags

这里:

- ``O=.`` 使用绝对路径(如果你需要在内核源代码目录之外加载创建的 ``cscope/ctags`` 索引文件，例如开发 ``out-of-tree`` 内核模块)。如果你想使用相对路径(例如只在内核源代码目录下开发)就可以忽略这个参数
- ``ARCH=...`` 选择索引的CPU架构。例如使用 ``ARCH=arm`` 则 ``arch/arm/`` 目录将会索引，其他 ``arch/*`` 目录将被忽略
- ``SUBARCH=...`` 选择子架构(和主办相关文件)索引。例如 ``SUBARCH=omap2`` 则只有 ``arch/arm/mach-omap2/`` 和 ``arch/arm/plat-omap/`` 目录被索引，其他主机和平台被忽略。
- ``COMPILED_SOURCE=1`` 只索引编译过文件。通常只是对源代码中你编译部分索引，如果还需要所有其他不被编译的文件，就不使用这个参数
- ``cscope`` 创建cscope索引的规则
- ``tags`` 创建ctags索引的规则

例如，开发x86的代码::

   make ARCH=x86 cscope tags

手工创建索引
---------------

内核脚本 ``tags.sh`` 有可能不能正常工作，或者你需要采用更多控制索引的功能，此时你可以手工索引内核源代码(详情可参考 `Using Cscope on large projects (example: the Linux kernel) <http://cscope.sourceforge.net/large_projects.html>`_ ):

- 首先创建一个 ``cscope.files`` 文件列出所有需要索引的文件

如果是ARM架构:

.. literalinclude:: howto_learn_kernel/cscope-arm.files
   :language: bash
   :linenos:
   :caption:

如果是X86架构:

.. literalinclude:: howto_learn_kernel/cscope-x86.files
   :language: bash
   :linenos:
   :caption:

这里 ``dir`` 变量有以下值:

- ``.`` 如果直接在内核源代码目录，也就是所有命令都在源代码目录的根上执行
- ``内核源代码的绝对路径`` 则是在内核源代码目录外开发模块时候使用

当 ``cscope.files`` 文件生成后，需要运行实际索引::

   cscope -b -q -k

这里参数 ``-k`` 是让 ``cscope`` 不要索引C标准库（因为kernel不使用)

- 然后就是创建 ``ctags`` 索引数据库，这里需要重用刚才创建的 ``cscope.files`` ::

   ctags -L cscope.files

- 在完成了 ``cscope`` 和 ``ctages`` 索引数据库创建之后，我们可以删除 ``cscope.files`` 因为不再需要这个文件::

   rm -f cscpe.files

以下文件位于源代码目录下包含了索引::

   cscope.out
   cscope.out.in
   cscope.out.po
   tags

vim安装
===========

由于在内核学习过程中，使用旧版本 CentOS 6，提供的vim版本较低，所以考虑到vim插件 ``YouCompleteMe`` 对vim版本有很高要求，所以 :ref:`install_vim_centos6` ，以便能够使用最新插件。后续其他开发，我准备再使用最新的CentOS或Ubuntu重新部署开发环境，并制作docker镜像方便工作学习。

vim插件
===========

vim有多种插件管理工具，例如 `pathogen <https://github.com/tpope/vim-pathogen>`_ (这通常是vim新手安装的第一个插件)。甚至从Vim 8开始， :ref:`vim_native_package_loading` ，不过传统上方便独立包路径管理，还是使用插件管理工具 ``pathogen`` 。

- 安装 ``pathoegn`` plugin 可以只需要使用 ``git clone`` 将vim插件下载到 ``~/.vim/bundle/`` 目录下::

   mkdir -p ~/.vim/autoload ~/.vim/bundle && \
   curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

- 上述命令执行成功后设置运行时路径(Runtime Path Manipulation)，在 ``~/.vimrc`` 中添加::

   execute pathogen#infect()
   syntax on
   filetype plugin indent on


LXR Cross Referencer
=========================

`LXR Cross Referencer <https://sourceforge.net/projects/lxr/>`_ 是源代码阅读平台，可以通过浏览器阅读代码。

参考
======

- `Linux Kernel labs: Introduction <https://linux-kernel-labs.github.io/refs/heads/master/labs/introduction.html>`_ 提供了内核实验的文档，有很多可以参考的技术
- `Kernel Developer Workflow <https://cs4118.github.io/dev-guides/kernel-workflow.html>`_ - 提供了详细的插件安装以及共享了vimrc
- `Vim configuration for Linux kernel development <https://stackoverflow.com/questions/33676829/vim-configuration-for-linux-kernel-development>`_
