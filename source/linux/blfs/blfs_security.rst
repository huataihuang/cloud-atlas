.. _blfs_security:

=====================
BLFS Security
=====================

OpenSSH
========

- openssh:

.. literalinclude:: lfs_ssh/ssh
   :caption: 安装openssh

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

异常排查
----------

遇到一个非常奇怪的问题，完全一样的 ``authorized_keys`` ，分别存放在 ``root`` 用户和 ``admin`` 用户的 ``~/.ssh/`` 目录下 ， ``root`` 用户无密码登陆完全正常，但是 ``admin`` 用户登陆直接拒绝:

.. literalinclude:: lfs_ssh/ssh_permission_denied_publickey
   :caption: 公钥登陆被拒绝

已经核对:

- ``~/.ssh/`` 目录 ``700`` , ``~/.ssh/authorized_keys`` 文件 ``644`` 或者 ``600``
- ``~/.ssh/authorized_keys`` 文件内容和md5都对比一致

我以前遇到类似密钥无法登陆，基本上就是认证密钥文件属性设置不正确，但这次不是。

我在检查 ``/etc/shadow`` 文件时意外发现 ``admin`` 账号没有设置过密码。我原本以为我强制通过密钥认证可以不用设置这个普 通用户密码，但是实践发现， **用户账号必须设置密码，即使SSH是通过密钥认证登陆**

也就是说，在 ``/etc/ssh/sshd_config`` 中设置了(默认)如下:

.. literalinclude:: lfs_ssh/sshd_config_default
   :caption: 默认设置sshd不可以空白密码
   :emphasize-lines: 2,3

这个不允许用户空密码原来不是指ssh客户端连接以后，用户输入的空密码，而是服务器端用户账号本身就不允许空密码。只要服务器上 的用户密码没有设置，ssh就禁止该账号登陆，哪怕SSH客户端密钥认证是正确的也不行。 **空密码校验逻辑在前**

sudo
=======

.. literalinclude:: blfs_security/sudo
   :caption: sudo

配置
------

.. literalinclude:: blfs_security/sudoers
   :caption: ``/etc/sudoers``

将 ``admin`` 用户加入 ``wheel`` 组，这样可以无密码切换到 ``root``
