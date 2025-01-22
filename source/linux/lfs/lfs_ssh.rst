.. _lfs_ssh:

===============
LFS SSH服务
===============

.. note::

   这部分不是LFS的必须，是属于BLFS的一个章节，不过对于我的远程管理服务器，显然先安装一个SSH服务很有必要

安装
======

- openssh:

.. literalinclude:: lfs_ssh/ssh
   :caption: 安装openssh

配置
======

- 设置

.. literalinclude:: lfs_ssh/ssh_config
   :caption: 配置openssh

.. note::

   ssh 使用 Linux-PAM 支持来做密码认证，如果不需要密码认证，就不需要Linux-PAM

   我采用密钥认证登陆

启动配置
---------

启动配置是通过 `BLFS Boot Scripts <https://www.linuxfromscratch.org/blfs/view/12.2/introduction/bootscripts.html>`_

.. literalinclude:: lfs_ssh/ssh_blfs-bootscripts
   :caption: 通过BLFS Boot Scripts启动ssh
