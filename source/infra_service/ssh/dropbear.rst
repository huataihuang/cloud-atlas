.. _dropbear:

================
Dropbear
================

OpenSSH 兼容
================

我在使用中发现Dropbear和OpenSSH的兼容还是有一点小麻烦:

- 配置文件 ``~/.ssh/config`` 语法不完全兼容
- Dropbear自身不支持 SFTP ，所以当使用OpenSSH 客户端来使用 SFTP 功能时，需要使用 ``scp -O`` 参数来采用旧版本SCP协议。最好的兼容SFTP方式其实是 **单独安装** openssh 提供sftp服务器:

.. literalinclude:: dropbear/install_sftp_server
   :caption: 安装openssh提供的sftp服务器来提供SFTP支持

参考
=====

- `OpenWrt > Dropbear <https://openwrt.org/docs/guide-user/base-system/dropbear>`_
