.. _ubuntu_nfs:

==================
Ubuntu NFS部署
==================

NFS服务器安装
=============

- 执行以下命令安装NFS服务器::

   sudo apt install nfs-kernel-server

- 执行以下命令启动NFS服务器::

   sudo systemctl start nfs-kernel-server.service

- 配置操作系统启动时启动NFS服务器::

   sudo systemctl enable nfs-kernel-server.service

NFS服务器配置
==============

- 在服务器上配置 ``/etc/exports`` 如下::

   /data   *(rw,sync,no_root_squash,no_subtree_check)

以上配置说明如下：

  - ``rw`` 允许客户端读写该卷
  - ``sync`` NFS在实际完成磁盘写入后才回复客户端，这样可以保证数据安全性，但是也带来了性能的下降
  - ``no_root_squash`` 默认情况下，NFS会把远程的 ``root`` 用户访问映射成服务器上的一个普通非特权账户，这样可以保护服务器安全性，避免客户端root用户直接具备服务器root账户权限。但是很多时候对于维护不便，所以还是需要结合其他安全措施来加固。
  - ``no_subtree_check`` 避免子目录检查，原因是host主机需要每次收到请求都检查整个输出目录树文件是否实际存在，这导致客户端打开一个文件时如果文件被重命名引发很多问题，所以通常这个参数要设置用来禁止子目录检查。
  - 在最前面的参数选项 ``*`` 表示允许网络中所有IP的客户端访问，这是一个安全性很松的设置，仅适合测试使用。实际生产环境需要配置运训访问的客户端IP地址以限制非授权访问。

- 创建NFS目录 ``/data`` ::

   sudo mkdir /data

- 输出配置的 ``/data`` 目录::

   sudo exportfs -a

- 完成NFS卷输出以后，可以再次检查确认::

   sudo exportfs

输出如下表明已经对外提供了 ``/data`` NFS卷::

   /data         	<world>

- 其他的NFS配置案例可参考如下::

   /srv     *(ro,sync,subtree_check)
   /home    *.hostname.com(rw,sync,no_subtree_check)
   /scratch *(rw,async,no_subtree_check,no_root_squash,noexec)


NFS客户端安装
=============

- 安装NFS客户端:

.. literalinclude:: ubuntu_nfs/instatll_nfs_client
   :language: bash
   :caption: Ubuntu安装NFS客户端

NFS客户端配置
==============

直接挂载
---------

NFS客户端可以不用配置，直接如同本地目录挂载一般挂载上述配置在 ``192.168.6.11`` 服务器上的NFS输出目录 ``/data`` ::

   sudo mkdir /data
   sudo mount 192.168.6.11:/data /data

挂载完成后，执行 ``df -h`` 可以看到目录如下::

   192.168.6.11:/data  117G   11G  102G  10% /data

现在我们就能够读写这个 ``/data`` 目录把文件存放到NFS服务器上了。

持久化配置
-----------

为了能够持久配置，即在NFS客户端操作系统启动时就挂载NFS并且能够做必要的优化，我们通常会在NFS客户端配置 ``/etc/fstab`` 如下::

   192.168.6.11:/data  /data  nfs  rw,soft,intr,vers=3,proto=tcp,rsize=32768,wsize=32768 0 0

然后挂载就比较简单了，只需要执行::

   mount /data

就可以，并且操作系统重启也会自动挂载

NFS挂载参数解释:

  - ``rw`` 允许读写
  - ``soft`` 软挂载

参考
=====

- `How To Set Up an NFS Mount on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-20-04>`_
- `Ubuntu doc: Network File System (NFS) <https://ubuntu.com/server/docs/service-nfs>`_
