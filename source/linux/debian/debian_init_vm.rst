.. _debian_init_vm:

===========================
Debian虚拟机精简系统初始化
===========================

在 :ref:`run_debian_in_qemu` 采用了只选择安装 ``SSH Server`` 和基本运维工具包。完成后进行初始化

.. note::

   Debian/Ubuntu 不允许普通用户账号设置为 ``admin`` ，所以我设置一个普通账号 ``chief``

串口设置
============

默认没有启用串口控制台，这导致虚拟机console无法使用，所以按照 :ref:`ubuntu_serial_console` 调整:

- 创建一个 ``/etc/init/ttyS0.conf`` :

.. literalinclude:: ../ubuntu_linux/admin/ubuntu_serial_console/ttyS0.conf
   :caption: ``/etc/init/ttyS0.conf`` 配置getty

- 修订 ``/etc/default/grub`` 配置 ``GRUB_CMDLINE_LINUX`` :

.. literalinclude:: ../ubuntu_linux/admin/ubuntu_serial_console/grub
   :caption: 修订 ``/etc/default/grub`` 配置 ``GRUB_CMDLINE_LINUX`` 添加控制台
   :emphasize-lines: 2

.. note::

   上述串口配置仅针对Linux Kernel，所以只有在Linux内核获得主机控制时才会有串口输出，这样就不包含grub自身的串口输出，会导致grub刚启动时看不到选择启动项的页面。所以还需要补充 ``grub`` 的串口配置

- **补充** 增加GRUB串口配置，修订 ``/etc/default/grub`` 配置，配置 ``GRUB_TERMINAL`` 和 ``GRUB_SERIAL_COMMAND`` :

.. literalinclude:: ../ubuntu_linux/admin/ubuntu_serial_console/grub
   :caption: 修订 ``/etc/default/grub`` 配置 ``GRUB_TERMINAL`` 和 ``GRUB_SERIAL_COMMAND``
   :emphasize-lines: 5,6

- 更新GRUB:

.. literalinclude:: ../ubuntu_linux/admin/ubuntu_grub/update-grub
   :caption: 更细GRUB

重启系统后， :ref:`run_debian_in_qemu` 就能在运行 ``qemu`` 执行的命令行访问虚拟机控制台，方便运维

系统仓库 ``sources.list``
============================

由于 :ref:`run_debian_in_qemu` 使用CDROM ISO安装，我发现完成后仓库源文件 ``/etc/apt/sources.list`` 只配置了CDROM，所以参考 `debian wiki: SourcesList <https://wiki.debian.org/SourcesList>`_ 更新设置:

.. literalinclude:: debian_init_vm/sources.list
   :caption: 配置 ``/etc/apt/sources.list``

系统软件仓库更新
==================

- 在安装和更新软件包之前，我们通常需要先更新软件仓库索引(update)，并完成一次现有安装软件的全面更新(upgrade):

.. literalinclude:: debian_init/apt_upgrade.sh
   :caption: debian更新软件仓库索引，并全面更新已安装软件

软件安装步骤
===============

- 服务器系统，安装必要的管理工具:

.. literalinclude:: debian_init/debian_init_devops
   :language: bash
   :caption: 安装运维管理工具

- 对于纯后台服务器系统，可以采用如下精简安装:

.. literalinclude:: debian_init/debian_init_vimrc_dev
   :caption: 安装vim以及服务器开发所需软件集

- debian发行版中， ``mlocate`` 已经被 ``plocate`` (更快)替代( ``/usr/bin/locate --> /etc/alternatives/locate --> /usr/bin/plocate`` ): 使用方法相同 ``updatedb && locate XXX``
