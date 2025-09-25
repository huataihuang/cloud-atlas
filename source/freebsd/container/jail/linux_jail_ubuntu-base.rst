.. _linux_jail_ubuntu-base:

===================================================
使用 ``ubuntu-base`` tgz 包部署Linux Jail Ubuntu
===================================================

.. note::

   我在 :ref:`freebsd_15_alpha_update_upgrade` 后实践 :ref:`linux_jail` 遇到了不少问题，在将底层Host主机文件系统更换到UFS之后，虽然解决了 :ref:`apt` 运行问题，但是由于 ``debootstrap`` 没有正常工作，导致Linux Jail内部强制安装软件包出现混乱依赖。所以，我考虑从最基本的base系统开始构建Ubuntu环境，主要目标是:

   - 解决目前FreeBSD 15 Alpha 2环境下 ``debootstrap`` 不能正确构建Ubuntu chroot环境(我突然想到实际上是Jail内部是FreeBSD 14 RELEASE-14.3，为何R14.3提供的 ``debootstrap`` 会受到Host主机15 Alpha 2影响？)
   - 部署FreeBSD Linux Jail默认不支持的Ubuntu 24.04 系统(默认只有 ``22.04`` jammy)

   另外，参考中提及的 `GitHub: NapoleonWils0n/davinci-resolve-freebsd-jail <https://github.com/NapoleonWils0n/davinci-resolve-freebsd-jail>`_ 提供了在FreeBSD Jail中运行Ubuntu系统来支持Nvidia和Cuda (方案是为了推广 `DaVinci Resolve <https://www.blackmagicdesign.com/uk/products/davinciresolve>`_ 好莱坞级别的专业剪辑软件，但是对于如何在FreeBSD Jail中使用NVIDIA CUDA有很好的参考价值)

下载Ubuntu base
==================

- 前置工作: :ref:`vnet_thick_jail`

- 参考 `ubuntu base download <https://github.com/NapoleonWils0n/davinci-resolve-freebsd-jail/tree/master?tab=readme-ov-file#ubuntu-base-download>`_ 也就是从Ubuntu官方下载一个基本系统压缩包 `Ubuntu Base 24.04.3 (Noble Numbat) <https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/>`_

.. note::

   Ubuntu官方release提供了不同架构的base系统包，可以用来构建基本系统

.. literalinclude:: linux_jail_ubuntu-base/ubuntu_base
   :caption: 下载Ubuntu官方提供的base系统压缩包

- 将 Ubuntu Base 包解压缩到 ``ludev`` 的 ``/compat/ubuntu`` 目录:

.. literalinclude:: linux_jail_ubuntu-base/tar
   :caption: 解压缩

- 启动 ``ludev`` jail

.. literalinclude:: vnet_thick_jail/start
   :caption: 启动 ``ludev``

- 进入Linux Jail的Ubuntu环境:

.. literalinclude:: linux_jail/jexec_chroot_ludev
   :caption: 进入Linux Jail的Ubuntu环境

.. note::

   非常成功，解决了 :ref:`linux_jail` 在 FreeBSD 15 Alpha 2上古怪的bug(不能使用ZFS作为底层存储，不能使用 ``debootstrap`` 来构建Ubuntu环境)，终于能够正常使用Linux on FreeBSD了

参考
========

- `Ubuntu 24.04 Noble Numbat Jail debootstrap systemd errors <https://forums.freebsd.org/threads/ubuntu-24-04-noble-numbat-jail-debootstrap-systemd-errors.94678/>`_
