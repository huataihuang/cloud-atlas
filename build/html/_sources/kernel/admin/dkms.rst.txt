.. _dkms:

========================
动态内核模块支持(DKMS)
========================

动态内核模块支持(Dynamic Kernel Module Support, DKMS)是一个用于支持使用内核源代码树之外的源代码来生成Linux内核模块的编程框架。当新内核安装时，DKMS会自动重新编译DKMS模块。

这个DKMS框架对于某些因为Lincense原因无法加入到Linux内核源码的商业或不兼容Licence开源程序非常有用。例如 :ref:`zfs` 由于CDDL开源协议不兼容Linux内核的GPL协议，所以必须采用DKMS进行编译安装。

通过使用DKMS，用户无需等待第三方公司或项目以及软件包维护者在新内核出现时发布新模块，而是用户升级内核时自动完成模块处理。

安装
=====

- 在 :ref:`arch_linux` 上安装 ``dkms`` 软件包::

   pacman -S dkms

升级
=====

虽然内核升级时通常会无痛重新build DKMS模块，但是也可能会出现rebuild失败。需要特别注意 :ref:`pacman` 输出，例如系统依赖KDMS模块启动的话更需要关注并解决DKMS编译失败的情况。如果出现以来启动的DKMS软件包编译失败，切记不要冒然重启。

使用
=====

- 手工发起DKMS::

   source /usr/share/bash-completion/completions/dkms

- 列出模块::

   dkms status

- 重建模块::

   dkms autoinstall

也可以指定内核::

   dkms autoinstall -k 3.16.4-1-ARCH

- 为当前运行的内核编译指定模块::

   dkms install -m nvidia -v 334.21

也可以简化为::

   dkms install nvidia/334.21

- 编译所有内核的一个模块::

   dkms install nvidia/334.21 --all

- 移除模块::

   dkms remove -m nvidia -v 331.49 --all

或者简化为::

   dkms remove nvidia/331.49 --all

参考
=======

- `arch linux: Dynamic Kernel Module Support <https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support>`_
