.. _intro_nfs:

====================
NFS网络文件系统简介
====================

为解决本地文件系统的限制(磁盘空间有限、无法多客户端共享访问)，网络文件系统(Network File System, NFS)被发明出来:

- 多个客户端可以共享访问服务器上相同的文件
- 非常便于集中管理NFS服务器上的文件(提供一定的安全性)，例如集中备份、冗灾等

网络文件系统(NFS)是一个守护进程，它允许其他计算机在另一台远程计算机上 ``挂载`` 磁盘文件系统目录，并像访问本地文件和文件夹一样访问这些文件。

NFS最早是Sun Microsystems公司于1984年发明

NFS架构
==========

参考
=======

- `Network File System (NFS) <https://www.geeksforgeeks.org/network-file-system-nfs/>`_
- IBM的AIX文档提供了很多NFS相关资料(但是限于AIX系统) - `AIX 7.3 Network File System <https://www.ibm.com/docs/en/aix/7.3?topic=management-network-file-system>`_
- `archlinux NFS <https://wiki.archlinux.org/title/NFS>`_
