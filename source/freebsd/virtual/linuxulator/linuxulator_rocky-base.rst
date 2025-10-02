.. _linuxulator_rocky-base:

==============================================================
使用 ``Rocky-Container-base`` tgz 包部署Linuxulator userland
==============================================================

我在 :ref:`linuxulator_nvidia_cuda` 实践中遇到执行 ``miniconda-installer`` 运行报错，推测和Python3运行环境相关。想对比尝试 :ref:`linuxulator_startup` 中更新 ``linuxulator`` 中 Rocky Linux 9 的Python(系统提供的 ``linux-rl9`` 中python配置有问题)。但是发现发行版的 ``linuxulator`` linux userland实际上是非常非常精简的系统，甚至没有提供 :ref:`dnf` 包管理器。

考虑到 ``linuxulator`` 和 :ref:`linux_jail` 实际底层原理一致，既然 :ref:`linux_jail_ubuntu-base` 能够通过Ubuntu core来构建，那么Rocky Linux应该也可以以相同方式构建 ``linuxulator`` userland 环境。

`Rocky Linux download > 9 > images > x86_64 <https://download.rockylinux.org/pub/rocky/9/images/x86_64/>`_ 提供了 `Rocky-9-Container-base.latest.x86_64.tar.xz <https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-base.latest.x86_64.tar.xz>`_ ，虽然是针对 :ref:`container` 的镜像压缩包，但是jail非常类似container，实际上都剥离了 :ref:`systemd` ，应该可以共用。

激活Linuxulator
===================

- 执行以下命令激活 ``Linuxulator`` :

.. literalinclude:: linuxulator_startup/kldload
   :caption: 加载linux模块激活 ``Linuxulator``

- 配置持久化，修改 ``/etc/rc.conf`` 添加:

.. literalinclude:: linuxulator_startup/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 持久化激活 ``Linuxulator``

部署Linuxulator userland
===========================

.. note::

   不要使用 ``Rocky-9-Container-Minimal.latest.x86_64.tar.xz`` ，这个 ``minimal`` 版本不包含 :ref:`dnf` 包管理器，也就是说，实际上FreeBSD ``linuxulator`` 提供的userland其实就是 ``minimal`` 版本。

- 解压缩下载 ``Rocky-9-Container-Base.latest.x86_64.tar.xz`` :

.. literalinclude:: linuxulator_rocky-base/tar
   :caption: 解压缩

重启一次系统，重启后系统会自动挂载Linux兼容文件系统(或者如 :ref:`linuxulator_startup` 配置 ``/etc/fstab`` 并挂载)  ``<= 因为我之前部署安装linuxulator，系统自动为挂载了 /compat/linux 目录下的 proc sys shem 文件系统，所以这步我实际没有执行，但事后复盘我觉得如果我手工解压缩Rocky-9-Container-Minimal包，并且也enable linux，那么系统也会自动挂载这些linux文件系统`` 

.. note::

   执行上述解压缩之前，请先停止FreeBSD服务器上linux服务 ``service linux stop`` ，如果不行，则注释掉 :ref:`linuxulator_startup` 中配置启动linux兼容层的 ``/etc/rc.conf`` 部分并重启主机。

   完成上述解压缩部署 Rocky Linux 之后，再恢复 ``linux`` 服务

- 在FreeBSD Host主机上将 ``/etc/resolv.conf`` 复制给Jail使用:

.. literalinclude:: ../../container/jail/linux_jail_rocky-base/cp_resolv
   :caption: 将Host主机的 ``/etc/resolv.conf`` 复制给Jail

- 更新:

.. literalinclude:: ../../container/jail/linux_jail_rocky-base/update
   :caption: 更新系统

.. note::

   ``linuxulator`` 不需要复杂完整的环境，所以更新系统后就可以顺利使用了。对于 :ref:`linux_jail` 则参考 :ref:`linux_jail_rocky-base` 继续设置包管理以及安装必要的工具软件。

参考
=======

- `Chapter 12. Linux Binary Compatibility <https://docs.freebsd.org/en/books/handbook/linuxemu/>`_
- `Davinci Resolve install on Freebsd using an Rocky Linux Jail <https://github.com/NapoleonWils0n/davinci-resolve-freebsd-jail-rocky>`_
