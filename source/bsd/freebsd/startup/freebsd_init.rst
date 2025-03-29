.. _freebsd_init:

==================
FreeBSD初始化
==================


终端程序安装
=============

完成FreeBSD初步安装之后，执行

- 安装运维软件:

.. literalinclude:: freebsd_init/devops
   :caption: 安装运维软件

- (放弃，感觉csh也好)修改 ``admin`` 用户默认使用 :ref:`bash` 作为SHELL:

.. literalinclude:: freebsd_init/chsh
   :caption: 设置bash作为SHELL

创建admin账号以及设置sudo
============================

.. literalinclude:: ../container/jail/jail_init/user
   :caption: 创建admin

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
