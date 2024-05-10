.. _gentoo_genkernel:

===========================
Gentoo genkernel
===========================

在解决 :ref:`gentoo_mbp_wifi` 安装 ``net-wireless/broadcom-sta`` ( Broadcom 的私有 ``wl`` 驱动)，需要完成内核编译。为了方便完成内核编译，按照推荐先安装 ``sys-kernel/genkernel`` ，然后使用这个工具来完成自动的内核编译

``genkernel`` 是一个由Gentoo创建的用于自动化完成 :ref:`kernel` 和 :ref:`initramfs` 构建的工具:

- 配置内核源代码
- 编译压缩的内核 ``bzImage`` 并复制到 ``/boot``
- 创建 :ref:`initramfs` 并复制到 ``/boot``
- 在 ``/boot`` 中创建软链接
- 添加指向initramfs的定制内容，例如加密相关文件，启动splash图像，扩展模块等
- 配置bootloader来启动新创建的kernel和initramfs

.. note::

   ``genkernel`` 并不是 "自动" 生成自定义内核配置，它只是自动执行内核构建过程并组装initramfs，所以并不会生成自定义配置文件。

   如果没有提供内核配置，那么 ``genkernel`` 将使用 "通用内核配置" (generic kernel configuration) 文件，来生成适合日常使用的通用内核(代价就是非常大的模块化内核)

   ``genkernel`` 的 ``initramfs`` 也是如此:  :ref:`initramfs` 主要用途 是 调用挂载包含根文件系统的块设备，以便能够尽快将控制权转交给真实的系统(磁盘上的操作系统)

安装
=======

- 安装 ``genkernel`` :

.. literalinclude:: gentoo_genkernel/install_genkernel
   :caption: 安装 ``genkernel``

使用
========

``genkernel`` 的大多数选线可以在 ``/etc/genkernel.conf`` 配置，或者通过 ``genkernel`` 命令参数传递。通过命令行参数传递的选项优先级高于配置文件

内核源代码
--------------

- 首先在系统中安装内核源代码:

.. literalinclude:: gentoo_genkernel/install_kernel_source
   :caption: Gentoo安装内核源代码

.. note::

   在 :ref:`install_gentoo_on_mbp` 安装的内核是 ``Distribution Kernel`` ，也就是通用的(庞大的) ``sys-kernel/gentoo-kernel`` 。需要注意这个 ``sys-kernel/gentoo-kernel`` 也是源代码，只不过gentoo为原生内核源代码打过补丁，并且每次(重新)安装 ``sys-kernel/gentoo-kernel`` 都会全面重新编译一次内核，这个内核编译是不需要任何人工干预的，编译生成的是最通用的内核。类似于其他发行版，如 :ref:`ubuntu_linux` 安装的发行版内核

- 编辑 ``/etc/genkernel.conf`` 参考注释修改配置参数:

.. literalinclude:: gentoo_genkernel/genkernel.conf
   :caption: 修改 ``/etc/genkernel.conf``

- 执行创建内核:

.. literalinclude:: gentoo_genkernel/genkernel_all
   :caption: 编译内核

采用 :ref:`install_gentoo_on_mbp` 同样的 ``efibootmgr`` 设置启动，不过需要注意内核名称稍微有所调整(因为编译配置时修改了后缀名):

.. literalinclude:: gentoo_genkernel/efibootmgr_set_mba13
   :language: bash
   :caption: :ref:`mba13_early_2014` 设置efibootmgr，启动 ``genkernel`` 新编译的内核

报错: failed to compile the "prepare" target
---------------------------------------------

首次使用 ``genkernel all`` 遇到报错:

.. literalinclude:: gentoo_genkernel/genkernel_error_prepare
   :caption: 报错信息

检查 ``/var/log/genkernel.log`` :

.. literalinclude:: gentoo_genkernel/genkernel.log
   :caption: ``genkernel.log`` 错误

参考 `make[1]: *** No rule to make target <https://www.reddit.com/r/Gentoo/comments/13k9z2b/make1_no_rule_to_make_target/>`_ 原因是系统中安装了两个Kernel source: 之前 :ref:`install_gentoo_on_mbp` 安装了 ``Distribution Kernel`` ，也就是 ``sys-kernel/gentoo-kernel`` ，然后我又安装了 ``sys-kernel/gentoo-sources`` ，所以执行:

.. literalinclude:: gentoo_genkernel/eselect_kernel
   :caption: 执行 ``eselect kernel`` 检查系统中内核源代码

输出显示:

.. literalinclude:: gentoo_genkernel/eselect_kernel_output
   :caption: 执行 ``eselect kernel`` 可以看到当前内核源代码是发行版内核
   :emphasize-lines: 3

此时检查 ``ls -lh /usr/src/linux`` 可以看到引用的是 ``-dist`` 内核::

   lrwxrwxrwx 1 root root 24 Dec 17 15:22 /usr/src/linux -> linux-6.1.67-gentoo-dist

解决方法是修改 ``eselect kernel`` ，然后删除掉发行版源代码内核

修改成 ``kernel-srouce`` :

.. literalinclude:: gentoo_genkernel/eselect_kernel_set
   :caption: 设置成 ``kernel-source`` 源代码

现在再次检查 ``eselect kernel list`` 输出就可以看到切换到了标准内核:

.. literalinclude:: gentoo_genkernel/eselect_kernel_output_1
   :caption: 执行 ``eselect kernel`` 可以看到当前内核源代码切换到标准内核
   :emphasize-lines: 2

:strike:`此时可以手工删除` 保留 ``/usr/src/linux-6.1.67-gentoo-dist`` (只要安装了 ``sys-kernel/gentoo-kernel`` 这个目录即使手工删除也会在 :ref:`upgrade_gentoo` 时重新编译 ``gentoo-kerenl`` 发行版kernel，再次生成)

升级内核
============

我在部署初期Gentoo提供的内核是 6.1.67 ，但是近期升级提供了 6.6.9 ，我将原先 ``/usr/src/linux-6.1.67-gentoo`` 目录下 ``.config`` 复制到新的 ``/usr/src/linux-6.6.9-gentoo`` 目录下(以便减少重新配置项)，然后执行 ``genkernel all`` 。

调用 ``make menuconfig`` 没有问题，正常的交互界面，稍作修改后，我保存退出。此时 ``genkernel`` 开始执行下一步时候报错:

.. literalinclude:: gentoo_genkernel/miss_config_microcode_amd_err
   :caption: ``genkernel`` 报错显示缺少 ``CONFIG_MICROCODE_AMD`` 配置项

检查 ``/var/log/genkernel.log`` 有报错详情:

.. literalinclude:: gentoo_genkernel/genkernel_microcode.log
   :caption: ``genkernel.log`` 日志中有关 ``MICROCODE`` 错误
   :emphasize-lines: 21,22,34

- 这个问题在以下帖子中讨论:

  - `solved! genkernel force CONFIG_MICROCODE=AMD as well <https://forums.gentoo.org/viewtopic-p-8719100.html>`_
  - `Need help with genkernel (Microcode option for Intel) <https://forums.gentoo.org/viewtopic-t-1165728-highlight-.html>`_
  - `Bug 913659 - genkernel needs adaptation to microcode changes in linux-6.6 (Why genkernel forces CONFIG_MICROCODE AND INTEL AND AMD microcode loading option?) <https://bugs.gentoo.org/913659>`_

原因是 ``CONFIG_MICROCODE_AMD`` 和 ``CONFIG_MICROCODE_INTEL`` 已经从内核中移除

解决方法

- 传递 ``--microcode=none`` 参数给 ``genkernel`` :

.. literalinclude:: gentoo_genkernel/genkernel_microcode_none
   :caption: ``genkernel --micorcode=none``

- **或者** 修订 ``/etc/genkernel.conf`` 配置:

.. literalinclude:: gentoo_genkernel/genkernel_microcode_none.conf
   :caption: 配置 ``/etc/genkernel.conf`` 设置 MICROCODE="none"
   :emphasize-lines: 4

.. _genkernel_initramfs:

``genkernel`` 生成 :ref:`initramfs`
=======================================

使用 ``genkernel`` 还可以用来构建 :ref:`initramfs` :

.. literalinclude:: gentoo_genkernel/genkernel_initramfs
   :caption: 使用 ``genkernel`` 工具构建 :ref:`initramfs`

参考
======

- `gentoo linux wiki: genkernel <https://wiki.gentoo.org/wiki/Genkernel>`_
- `Installation: Genkernel command not found <https://www.reddit.com/r/Gentoo/comments/ffuku5/installation_genkernel_command_not_found/>`_
