.. _ventoy:

=====================
Ventoy (可启动U盘)
=====================

`Ventoy: A New Bootable USB Solution <https://www.ventoy.net/>`_ 是一个开源的用于创建基于ISO/WIM/IMG/VHD(x)/EFI文件的启动U盘工具。这是一个非常巧妙的工具，你不需要格式化磁盘，只需要将 ISO/WIM/IMG/VHD(x)/EFI 文件复制到U盘中，用 ``ventoy`` 来启动运行就能自如地切换启动镜像，特别适合运行像 :ref:`winpe` 这样的工具镜像以及很多Linux的Live CD。

Ventoy提供了Linux和Windows版本二进制程序，也提供了livecd格式的iso。我这里使用了Linux版本实践，使用方法既可以通过图形交互方式也可以通过命令行执行。

下载的文件是 ``ventoy-1.1.12-linux.tar.gz`` ，解压缩以后在 ventoy-1.1.12 目录下有一系列文件:

- ``VentoyWeb.sh`` 可以运行一个WEB方式的图形化安装界面
- ``Ventoy2Disk.sh`` 是一个字符命令行脚本，可以直接生成启动U盘

.. warning::

   执行 ``Ventoy2Disk.sh`` 一定要正确选择设备路径，该命令会抹除数据!!!

- 首先检查磁盘，确认U盘设备路径

.. literalinclude:: ventoy/lsblk
   :caption: 通过 ``lsblk`` 确定设备路径

以下是我当前的设备，其中 ``sdc`` 是我刚插入的U盘:

.. literalinclude:: ventoy/lsblk_output
   :caption: 通过 ``lsblk`` 确定 ``/dev/sdc`` 是我刚插入的U盘
   :emphasize-lines: 8

- 执行

.. literalinclude:: ventoy/ventoy2disk
   :caption: 命令行创建启动U盘

输出

.. literalinclude:: ventoy/ventoy2disk_output
   :caption: 命令行创建启动U盘输出信息
   :emphasize-lines: 17,20

在完成Ventoy启动U盘制作之后，目标U盘 ``sdc`` 被划分为2个分区，其中较大的一个 ``sdc1`` 是数据分区，存放用于启动使用的ISO文件

.. literalinclude:: ventoy/ventoy_fdisk
   :caption: 目标U盘被划分为2个分区
   :emphasize-lines: 11

- 挂载sdc1分区，将 :ref:`winpe` ISO镜像复制进去，并复制一些必要的工具，例如独立运行的

.. literalinclude:: ventoy/cp
   :caption: 复制winpe.iso以及需要的工具

- 当电脑插入ventoy启动U盘并以U盘启动，就会看到ventoy的启动菜单中包含了你复制进U盘数据分区中的 :ref:`winpe` ISO启动项，请使用 ``Boot in wimboot mode (Wimboot 模式)`` 启动Windows类ISO 
