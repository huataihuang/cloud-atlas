.. _upgrade_gentoo:

=======================
升级Gentoo
=======================

Gentoo有自己独特的升级方法，原因是Gentoo采用了滚动发行( :ref:`arch_linux` 也是如此 )，也就是不需要等待release来获取最新版本，软件只要进入稳定状态就可以立即安装。Gentoo通过这种设计实现了 **快速, 增量升级** 的目标，并且大多数情况下可以频繁更新到最新软件包。

一旦某个软件包安装完成， ``常规升级`` 将保持所有软件包始终最新可用版本。

很少情况下，如核心系统, 特定软件包, profile修改或者Portage一些升级，才可能会要求人工干预。

升级软件包
============

- 要升级所有安装的软件包，首先需要更新Gentoo仓库，这时需要使用工具 ``emaint`` :

.. literalinclude:: upgrade_gentoo/emaint
   :language: bash
   :caption: 使用emaint更新仓库

可以简化成:

.. literalinclude:: upgrade_gentoo/emaint_short
   :language: bash
   :caption: 使用emaint更新仓库(简化参数)

上述更新仓库可能会有一些提示需要你注意

- 完成仓库更新之后，就可以使用 ``emerge`` 升级整个系统:

.. literalinclude:: upgrade_gentoo/emerge_world
   :language: bash
   :caption: 使用emerge升级整个系统

也可以简化成:

.. literalinclude:: upgrade_gentoo/emerge_world_short
   :language: bash
   :caption: 使用emerge升级整个系统(简化参数)

参考
======

- `Upgrading Gentoo <https://wiki.gentoo.org/wiki/Upgrading_Gentoo>`_
