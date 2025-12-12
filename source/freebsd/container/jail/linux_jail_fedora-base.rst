.. _linux_jail_fedora-base:

===========================================================
使用 ``Rocky-Container-base`` tgz 包部署Linux Jail Rocky
===========================================================

类似 :ref:`linux_jail_rocky-base` ，我构建一个 :ref:`linux_jail` 环境下运行的 :ref:`fedora` ，目的是尝试对比解决 :ref:`linux_jail_rocky-base` 所遇到的 :ref:`lfs_gcc_1` 异常报错

下载版本选择
=============

我想寻找一个最简化的 :ref:`container` 类的 :ref:`fedora` tgz包，看起来 `fedora Miscellaneous Downloads <https://www.fedoraproject.org/misc>`_ 提供的 ``Fedora Container Base 43`` 最接近要求



说明
======

我在 :ref:`linuxulator_nvidia_cuda` 实践中遇到执行 ``miniconda-installer`` 运行报错，推测和Python3运行环境相关。想对比尝试 :ref:`linuxulator_startup` 中更新 ``linuxulator`` 中 Rocky Linux 9 的Python(系统提供的 ``linux-rl9`` 中python配置有问题)。但是发现发行版的 ``linuxulator`` linux userland实际上是非常非常精简的系统，甚至没有提供 :ref:`dnf` 包管理器。
