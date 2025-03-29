.. _freebsd_vm_init:

======================
FreeBSD虚拟机初始化
======================

在 :ref:`lima_run_freebsd` 中的FreeBSD系统是官方提供的 ``.qcow2`` 虚拟磁盘的镜像。FreeBSD官方虚拟机镜像是一个精简系统，启动后只能控制台登陆，需要做一定的初始化配置后才能顺畅使用。

.. note::

   部分初始化工作和 :ref:`freebsd_init` 重叠，步骤共用。

更新和升级系统
================

系统安装以后可以通过以下命令更新升级

.. literalinclude:: freebsd_init/upgrade
   :caption: 更新升级FreeBSD


终端程序安装
=============

完成FreeBSD初步安装之后，执行

- 安装运维软件:

.. literalinclude:: freebsd_init/devops
   :caption: 安装运维软件

- (放弃，感觉csh也好)修改 ``admin`` 用户默认使用 :ref:`bash` 作为SHELL:

.. literalinclude:: freebsd_init/chsh
   :caption: 设置bash作为SHELL

桌面程序安装
=================

.. literalinclude:: freebsd_init/desktop
   :caption: 安装桌面软件

提示
======

- 安装 ``keepassxc`` 提示:

.. literalinclude:: freebsd_init/keepassxc
   :caption: 安装 ``keepassxc`` 提示

参考
======

- `FreeBSD Install BASH Shell Using pkg command <https://www.cyberciti.biz/faq/freebsd-bash-installation/>`_
