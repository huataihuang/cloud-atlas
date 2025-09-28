.. _intro_devuan:

====================
Devuan简介
====================

`Devuan社区 <https://www.devuan.org/>`_ 发行了一个特殊的Debian版本: 剥离了 :ref:`systemd` 的Debian

就像 :ref:`gentoo_linux` 和 :ref:`alpine_linux` ，剥离了大而全的 :ref:`systemd` 实现了已经较为传统(经典)且轻量级的Linux。虽然现代化的Linux发行版都深度集成了 ``systemd`` ，甚至很多应用软件没有经过改造都无法正常在缺乏 ``systemd`` 的Linux发行版上运行，但是使用 ``sysvinit`` 的经典系统适合 :ref:`container` 运行环境，也包括 :ref:`freebsd` :ref:`linux_jail` 。

.. note::

   我在尝试 :ref:`linux_jail_nvidia_cuda` 遇到无法在 :ref:`linux_jail` 中安装和运行 :ref:`systemd` ，间接导致无法安装依赖 ``systemd`` 的 ``nvidia-cuda-toolkit`` 。有一种可能性是采用剥离 ``systemd`` 的debian系统来运行安装(不确定，待实践)，所以我整理记录待后续实践。
