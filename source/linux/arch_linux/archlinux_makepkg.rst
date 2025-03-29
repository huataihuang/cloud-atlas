.. _archlinux_makepkg:

======================
Arch Linux makepkg
======================

.. _makepkg_parallel_jobs:

makepkg并行任务
==================

我在使用 :ref:`archlinux_aur` 完成 :ref:`archlinux_zfs-dkms_x86` 编译内核时发现，默认情况下 make 只使用一个CPU core，导致编译效率非常低。最初，我以为只要采用 :ref:`parallel_make` 一样的设置方法，即配置 ``alias`` 就可以，所以给我当前普通用户 ``admin`` 设置了环境变量配置:

.. literalinclude:: archlinux_makepkg/alias
   :caption: 配置 ``make`` 命令 ``alias``

但是我惊奇地发现完全没有效果， ``yay`` 安装编译过程依然只使用1个CPU core。

原来 ``yay`` 编译生成软件包是通过 ``makepkg`` 来完成的，而 ``makepkg`` 控制运行参数位于 ``/etc/makepkg.conf`` ，其中有独立参数控制了如何并行使用主机CPU。默认情况下， ``makepkg`` 没有启用多处理器设置，所以需要手工修订 ``/etc/makepkg.conf`` 将 ``DistCC/CMP`` 开关打开:

.. literalinclude:: archlinux_makepkg/makepkg.conf
   :caption: 修订 ``/etc/makepkg.conf`` 启用并行任务设置
   :emphasize-lines: 2

参考
======

- `archlinux: makepkg <https://wiki.archlinux.org/title/Makepkg>`_
- `[solved] make -j (parallel jobs) in PKGBUILD ? <https://bbs.archlinux.org/viewtopic.php?id=178411>`_
