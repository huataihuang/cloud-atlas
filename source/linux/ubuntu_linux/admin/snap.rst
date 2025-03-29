.. _snap:

=================
snap软件包管理
=================

在其他Linux发行版也可以使用snap来构建一个沙箱系统运行软件，例如 :ref:`archlinux_snap` 就可以用来安装大型开发软件 Jetbrains 的系列开发IDE，也可以安装 :ref:`anbox` 。

snap - 统一Linux软件包
========================

snaps是一个自包含软件包，可以工作在不同Linux发行版。snap文件系统是一个使用SquashFS格式带有 ``.snap`` 后缀名的单个压缩文件系统。这个文件系统包含了应用程序，以及应用程序以阿里的库和申明元数据。元数据提供了snapd如何设置应用程序的安全沙箱。安装snap之后，会挂载到主机操作系统并且在文件使用时解压缩。虽然这样可以使snaps使用更少磁盘，但是对于大型程序则启动较为缓慢。

.. note::

   我将在今后需要时候具体研究和实践snaps，目前仅在安装 :ref:`anbox` 时使用过，不过比较遗憾，anbox实用性较差，暂时达不到日常使用阶段，所以暂时没有运行 snaps 的需求。待补充...

参考
=====

- `What do snap, snapd and Snappy refer to? <https://askubuntu.com/questions/963404/what-do-snap-snapd-and-snappy-refer-to>`_
- `Snap documentation <https://snapcraft.io/docs>`_
- `Snap (package manager) <https://en.wikipedia.org/wiki/Snap_(package_manager)>`_
