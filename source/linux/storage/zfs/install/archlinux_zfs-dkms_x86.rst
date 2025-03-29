.. _archlinux_zfs-dkms_x86:

==========================================
使用zfs-dkms在arch linux(X86)编译安装ZFS
==========================================

.. warning::

   本文正在根据自己近期 :ref:`archlinux_on_mba` 之后的ZFS实践重写，和以前 :ref:`archlinux_zfs-dkms_arm` 有所不同。部分内容参考和基于以前的 :ref:`archlinux_zfs-dkms_arm` (可能有重复)

``zfs-dkms`` 软件包提供了 :ref:`dkms` 支持，可以自动为兼容内核编译ZFS内核模块

优点:

- 可以定制自己的内核
- 可以不必等待内核发行版更新

缺点:

- 编译比较缓慢(对于现代超强CPU可以忽略)
- 如果DKMS编译失败很少有告警(需要仔细关注)


需要自己按照内核来编译，也就是采用 :ref:`dkms` 安装对应的 ``zfs-dkms`` 

安装
=======

- 检查内核variant(变种):

.. literalinclude:: archlinux_zfs-dkms_arm/archlinux_check_kernel_variant
   :language: bash
   :caption: 检查当前内核variant

验证::

   echo $INST_LINVAR

输出是::

   linux

- 检查内核版本:

.. literalinclude:: archlinux_zfs/archlinux_check_kernel_version
   :language: bash
   :caption: 检查当前内核版本

可以验证一下::

   echo $INST_LINVER

输出是::

   6.11.3.arch1-1

- 安装内核头文件:

.. literalinclude:: archlinux_zfs/archlinux_install_kernel_headers
   :language: bash
   :caption: 安装当前内核版本对应头文件

可以看到对应安装的是::

   linux-headers-6.11.3.arch1-1

- 安装zfs-dkms:

.. literalinclude:: archlinux_zfs/archlinux_install_zfs-dkms
   :language: bash
   :caption: 安装zfs-dkms

.. note::

   安装过程需要从 github 下载 ``zfs-2.2.6.tar.gz`` ，这个过程会被GFW阻塞，所以需要设置 :ref:`linux_proxy_env`

- 加载内核模块:

.. literalinclude:: archlinux_zfs/archlinux_load_zfs
   :language: bash
   :caption: 加载zfs内核模块

我这里遇到报错显示zfs内核模块不存在:

.. literalinclude:: archlinux_zfs-dkms_x86/modprobe_zfs_error
   :caption: 加载zfs内核模块显示模块没有存在于当前内核目录

仔细检查  ``yay`` 安装 ``zfs-dkms`` 安装输出信息，可以看到在内核模块 :ref:`dkms` 安装时会提示信息显示不支持过高内核:

.. literalinclude:: archlinux_zfs-dkms_x86/dkms_error
   :caption: 由于内核版本只支持 6.10 以下导致无法编译

这个问题在 :ref:`archlinux_zfs-dkms_arm` 也遇到过，但是当时我采用了 :ref:`btrfs` 来替换ZFS绕开这个问题。不过，这个问题毕竟需要解决

参考 `archlinux wiki: ZFS#DKMS <https://wiki.archlinux.org/title/ZFS#DKMS>`_ 可以看到有如下 ``DKMS`` 解决方法:

- ``zfs-dkms`` 是面向稳定版本的动态内核模块支持，也就意味着它可能不能支持最新内核
- ``zfs-dkms-staging-compat-git`` 从ZFS最新补丁加上backport来支持最新内核
- ``zfs-dkms-staging-git`` 跟踪最新发布候选版本(release candidate, RC)以及最新ZFS分支(如果还没有RC)
- ``zfs-dkms-git`` DKMS的开发者版本

我决定回退到特定内核版本(6.1)，然后重新安装 ``zfs-dkms`` 。需要注意 :ref:`archlinux_kernel` 安装 ``6.1`` LTS内核是通过 :ref:`archlinux_aur` 实现的，所以执行:

.. literalinclude:: ../../../arch_linux/archlinux_kernel/yay_linux6.1
   :caption: 通过:ref:`archlinux_aur` 安装指定的 Kernel 6.1 

.. note::

   没有使用安装 ``linux-lts`` 是因为当前 ``长期稳定支持`` 内核已经滚动升级到 ``6.5`` 系列，已经超出了zfs支持范围。

.. warning::

   编译安装最新的内核非常消耗计算资源，所以务必先在系统激活 :ref:`makepkg_parallel_jobs` ( 不是配置 :ref:`parallel_make` )以充分利用CPU的多核心，否则效率会低到无法忍受的程度。我曾经在 :ref:`mba11_late_2010` 单CPU核心编译超过16小时依然失败，实在非常低效。

内核编译错误处理
------------------

内核编译oom
~~~~~~~~~~~~~

.. literalinclude:: archlinux_zfs-dkms_x86/kernel_btf_error
   :caption: 内核编译 BTF 相关报错

可以看到编译进程被突然杀死，检查系统 ``dmesg -T`` 日志查找可能OOM的killer日志

再次编译时，我关闭所有图形程序，退出 :ref:`sway` 桌面，采用 :ref:`tmux` 运行编译，以节约内存使用。

内核编译需要大量空间
~~~~~~~~~~~~~~~~~~~~~~

.. literalinclude:: archlinux_zfs-dkms_x86/build_space_error
   :caption: 编译完成，但是安装时空间不足
   :emphasize-lines: 3

检查可以看到 :ref:`archlinux_aur` 使用了用户目录下 ``$HOME/.cache/`` 目录来保存编译过程数据，而编译内核达到了惊人的 ``21GB`` 空间占用。也就是说，要完整编译 ``linux-lts61`` 需要 **至少21GB磁盘空间**

检查zfs内核:

.. literalinclude:: archlinux_zfs/archlinux_lsmod_zfs
   :language: bash
   :caption: 检查zfs内核模块

此时可以看到zfs相关内核模块已经加载:

.. literalinclude:: archlinux_zfs/archlinux_lsmod_zfs_output
   :language: bash
   :caption: 检查zfs内核模块输出显示模块加载


参考
=======

- `arch linux: zfs <https://wiki.archlinux.org/title/ZFS>`_
- `OpenZFS Getting Started: Arch Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/index.html>`_
- `A reference guide to ZFS on Arch Linux <https://kiljan.org/2018/09/23/a-reference-guide-to-zfs-on-arch-linux/>`_ 提供了实践经验，可参考
