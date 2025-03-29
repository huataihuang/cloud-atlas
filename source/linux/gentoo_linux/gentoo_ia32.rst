.. _gentoo_ia32:

===============================
Gentoo IA32 模拟
===============================

IA32_EMULATION
==================

通过选择 ``IA32 模拟`` ( ``CONFIG_IA32_EMULATION`` )和 ``32-bit time_t`` ( ``CONFIG_COMPAT_32BIT_TIME`` ) ，可以让系统运行混合32位/64位计算。

.. literalinclude:: gentoo_ia32/processor
   :caption: 配置内核支持32位程序运行

在64位硬件上，通过 ``IA32_EMULATION`` 配置编译的内核可以支持运行32位应用。

.. literalinclude:: gentoo_ia32/zcat_config_gz
   :caption: 通过 ``zcat /proc/config.gz`` 检查内核是否支持32位

如果内核已经激活了32位支持，那么看到的输出如下:

.. literalinclude:: gentoo_ia32/zcat_config.gz_ia32
   :caption: 通过 ``zcat /proc/config.gz`` 检查内核显示支持32位

如果类似我在 :ref:`install_gentoo_on_mbp` 后编译内核去除了32位模拟支持，则显示

.. literalinclude:: gentoo_ia32/zcat_config.gz_no_ia32
   :caption: 通过 ``zcat /proc/config.gz`` 检查内核显示去除了32位支持

.. _multilib:

Multilib
==============

正如 :ref:`install_gentoo_on_mbp` 我选择纯64位 stage 3 构建 no-multilib 的系统，带来的一个问题是无法运行32位程序。通常这不是问题，但是在 :ref:`gentoo_wine` 时会遇到无法运行的问题。所以我采用一种变通方法：

- 物理主机内核启用32位支持，但是我依然选择采用纯64位 No-Multilib (见 :ref:`install_gentoo_on_mbp` 安装stage)
- 在Docker中使用 :ref:`gentoo_image` 是 Multilib(32和64位)，这样就可以在容器内部运行 :ref:`gentoo_wine`
- 保持物理主机的操作系统最精简，将所有图形运行程序迁移到Docker容器内部运行，这样有以下优点:

  - 容器可以在服务器上远程运行，使用服务器资源来解决本地物理主机性能有限的不足
  - 可以采用 :ref:`docker` 方式运行，也可以推送到 :ref:`kubernetes` 集群中，也就是说一次部署，到处运行
  - 随时随地工作，通过 :ref:`xpra` 远程运行服务器上的应用，可以保持持续的 :ref:`mobile_work`

.. note::

   实践待完成...

参考
========

- `Moving to no-multilib <https://forums.gentoo.org/viewtopic-t-1118828.html>`_
- `gentoo wiki: Handbook:AMD64/Blocks/Kernel <https://wiki.gentoo.org/wiki/Handbook:AMD64/Blocks/Kernel>`_
