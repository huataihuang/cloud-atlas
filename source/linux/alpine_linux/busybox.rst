.. _busybox:

==================
BusyBox
==================

``BusyBox`` 是在一个单一执行程序中实现大量Unix命令的工具，可以在不同的 ``POSIX`` 环境运行，包括 :ref:`linux` , :ref:`android` ( :ref:`android_busybox` ) 和 :ref:`freebsd` ，尽管很多 ``BusyBox`` 提供的工具最初设计是通过Linux :ref:`kernel` 提供的界面来工作的。 ``BusyBox`` 被设计成在资源非常有限的嵌入式操作系统工作，它的设计者称其为 ``嵌入式Linux的瑞士军刀`` ，在一个单一执行程序中可以替代超过300个常用命令。

``BusyBox`` 是1995年由Bruce Perens编写的，最初目标是将完整的可启动系统塞入一张软盘，以便能够为 :ref:`debian` 发行版提供installer或作为救援盘。之后，它被扩展成嵌入式Linux设备和Linux发行版inatallers的标准核心用户工具集。由于每个Linux执行只需要几K资源，即使BusyBox程序结合了数百个程序，它依然节约了大量的磁盘和内存空间。

``busybox`` 提供的命令
========================

当直接执行 ``busybox`` 不带任何参数，则会显示其提供的命令，例如我在 :ref:`alpine_linux` 上执行 ``busybox`` 可以看到支持 ``304`` 个命令，甚至包括了 ``awk`` 和 ``sed`` 这样常用的编程语言和流编辑器。

此外，可以看到 :ref:`alpine_linux` 上的 ``init`` 命令，也就是作为系统服务的启动的第一个 ``PID 1`` 进程，也是 ``busybox``  。这意味着 ``BuysBox`` 是作为取代 :ref:`systemd` , OpenRC, sinit, init 等launch daemons 的服务。

安装 ``busybox``
=================

- 在 :ref:`redhat_linux` 系上使用 :ref:`dnf` 可以安装 ``busybox`` :

.. literalinclude:: busybox/dnf_install
   :caption: ``dnf`` 安装 ``busybox``

- 在 :ref:`debian` 系上使用 :ref:`apt` 可以安装 ``busybox`` :

.. literalinclude:: busybox/apt_install
   :caption: ``apt`` 安装 ``busybox``

当然，在 :ref:`alpine_linux` 默认就使用了 ``busybox`` 无需单独安装

使用 ``busybox``
==================

使用 ``busybox`` 非常简单，就是在其支持的命令前使用 ``busybox`` 就可以，例如 ``busybox echo`` 就是用 ``busybox`` 来实现独立的 ``echo`` 等效命令。

当然，类似 :ref:`alpine_linux` 已经默认将 ``busybox`` 作为 ``PID 1`` 进程启动，所有在系统中执行的 ``busybox`` 命令，都可以直接使用(对于操作系统就是软链接到 ``/bin/busybox`` 的对应命令链接)

请通过 ``busybox`` 不加参数看看当前系统安装的 ``busybox`` 支持哪些替代命令，就可以使用上述方法来执行。

参考
=======

- `Wikipedia: BusyBox <https://en.wikipedia.org/wiki/BusyBox>`_
- `How to use BusyBox on Linux <https://opensource.com/article/21/8/what-busybox>`_
