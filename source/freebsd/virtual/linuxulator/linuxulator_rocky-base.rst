.. _linuxulator_rocky-base:

==============================================================
使用 ``Rocky-Container-base`` tgz 包部署Linuxulator userland
==============================================================

我在 :ref:`linuxulator_nvidia_cuda` 实践中遇到执行 ``miniconda-installer`` 运行报错，推测和Python3运行环境相关。想对比尝试 :ref:`linuxulator_startup` 中更新 ``linuxulator`` 中 Rocky Linux 9 的Python(系统提供的 ``linux-rl9`` 中python配置有问题)。但是发现发行版的 ``linuxulator`` linux userland实际上是非常非常精简的系统，甚至没有提供 :ref:`dnf` 包管理器。

考虑到 ``linuxulator`` 和 :ref:`linux_jail` 实际底层原理一致，既然 :ref:`linux_jail_ubuntu-base` 能够通过Ubuntu core来构建，那么Rocky Linux应该也可以以相同方式构建 ``linuxulator`` userland 环境。

`Rocky Linux download > 9 > images > x86_64 <https://download.rockylinux.org/pub/rocky/9/images/x86_64/>`_ 提供了 `Rocky-9-Container-base.latest.x86_64.tar.xz <https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-base.latest.x86_64.tar.xz>`_ ，虽然是针对 :ref:`container` 的镜像压缩包，但是jail非常类似container，实际上都剥离了 :ref:`systemd` ，应该可以共用。

.. note::

   不要使用 ``Rocky-9-Container-Minimal.latest.x86_64.tar.xz`` ，这个 ``minimal`` 版本不包含 :ref:`dnf` 包管理器，也就是说，实际上FreeBSD ``linuxulator`` 提供的userland其实就是 ``minimal`` 版本。

- 解压缩下载 ``Rocky-9-Container-Base.latest.x86_64.tar.xz`` :

.. literalinclude:: linuxulator_rocky-base/tar
   :caption: 解压缩

参考
=======

- `Chapter 12. Linux Binary Compatibility <https://docs.freebsd.org/en/books/handbook/linuxemu/>`_

