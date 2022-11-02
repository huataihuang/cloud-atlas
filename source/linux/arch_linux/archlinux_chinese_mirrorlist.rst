.. _archlinux_chinese_mirrorlist:

=================================
arch linux添加国内源(mirrorlist)
=================================

在使用arch linux进行安装更新时，国内网络环境特别缓慢，甚至无法完成。此时建议更新arch linux的mirrorlists，添加国内的镜像源，这样可以大大加快更新速度

- 备份mirrorlist配置::

   cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

- 编辑 ``/etc/pacman.d/mirrorlist`` 添加如下国内源(也可以只使用国内源):

.. literalinclude:: archlinux_chinese_mirrorlist/mirrorlist
   :language: bash
   :caption: /etc/pacman.d/mirrorlist 添加国内源加速软件安装和更新

参考
====

- `arch添加国内源以及社区源 <https://www.jianshu.com/p/4444bb4f8452>`_
