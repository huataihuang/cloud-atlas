.. _macos_nfs:

========================
macOS系统NFS服务
========================

我在构建macOS系统中 :ref:`docker_studio` ，想要在物理主机(macOS)上能够直接存储容器的数据，以避免容器销毁导致开发环境的数据丢失。例如，我可以运行数据库，代码存储。

将容器中的数据通过卷存储到远程NFS服务器上，也就是macOS物理主机上，能够方便进行数据备份和同步。需要注意，macOS上运行的Docker服务器实际上是运行在 :ref:`xhyve` 运行的一个轻量级的 :ref:`alpine_linux` 。所以，如果通过容器内部挂载NFS的方式来访问macOS物理服务器的共享存储，可以通过 :ref:`macos_docker_shell` 在虚拟机上实现对远程存储的挂载，然后映射到容器内部提供使用。

通过NFS输出macOS上目录
=======================

- 首先在macOS主机上启动NFS服务:

.. literalinclude:: macos_nfs/macos_enable_nfs
   :language: bash
   :caption: macOS主机上启动NFS服

如果系统已经启用过nfsd，则可能提示::

   The nfsd service is already enabled.
   Can't open /etc/exports, No such file or directory

- 检查nfs服务(portmapper):

.. literalinclude:: macos_nfs/rpcinfo
   :language: bash
   :caption: 使用rpcinfo检查本机的portmapper

输出显示:

.. literalinclude:: macos_nfs/rpcinfo_output
   :language: bash
   :caption: 使用rpcinfo检查本机的portmapper的输出信息

如果 ``rpcinfo -p`` 输出显示超时::

   Can't contact rpcbind on localhost
   rpcinfo: RPC: Timed out

则可以尝试重启(实际是stop)一次 ``com.apple.rpcbind`` ::

   sudo launchctl stop com.apple.rpcbind

此时你会看到::

 k  sudo launchctl list | grep rpcbind

依然显示 ``rpcbind`` 进程存在，但是该进程的pid已经改变，实际上系统会自动重新拉起 ``com.apple.rpcbind`` ，相当于重启了一次该服务。

然后再执行 ``sudo rpcinfo -p`` 就可以看到正常输出。

- 和标准的Unix/Linux系统相似，macOS也是通过 ``/etc/exports`` 文件配置NFS输出::

   /System/Volumes/Data/Users/dev -maproot=502:20 -network 192.168.6.0 -mask 255.255.255.0

.. note::

   对应macOS需要设置 ``-maproot`` 这样远程客户端的root账号才能被映射到本地到一个用户，才能读写某个目录(远程客户端的root用户被映射成NFS服务器上的某个账号进行读写)

如果是仅仅对外提供一个只读目录并且对整个网络开放，可以使用::

   /System/Volumes/Data/Users/shareall -ro -mapall=nobody -network 192.168.6.0 -mask 255.255.255.0

参数 ``mapall`` 可以将所有没有对应 gid/uid 的NFS客户端都映射到服务器上一个相同账号，例如 ``nobody`` 提供安全

- 并且检查配置的NFS是否正确::

   nfsd checkexports

- 重启一次nfs服务:

.. literalinclude:: macos_nfs/restart_nfs
   :language: bash
   :caption: 重启 :ref:`macos` 的nfs服务

- 最后检查输出的共享是否正确:

.. literalinclude:: macos_nfs/showmount
   :language: bash
   :caption: 检查服务器端输出挂载(已经在Linux挂载NFS)

显示::

   All mounts on localhost:
   192.168.6.200:/System/Volumes/Data/Users/dev

NFS客户端访问
================

.. note::

   在macOS上我曾经想 :ref:`macos_docker_shell` 在Docker VM上使用NFS来挂载macOS上的共享NFS卷，但是实践没有找到方法(难点在于 :ref:`alpine_linux` 软件包管理以及访问macOS的IP地址 )，有待探索。不过，我在使用 :ref:`alpine_kvm` 恰好需要访问macOS上共享的ISO镜像，所以采用局域网Linux来访问macOS NFS共享。

- 配置 ``/etc/fstab`` 添加::

   192.168.6.1:/System/Volumes/Data/Users/dev /mnt nfs,noauto rw 0 0

- 挂载::

   mount /mnt

Connection refused
---------------------

我在 :ref:`alpine_linux` 上挂载macOS NFS时候出现报错::

   mount: mounting 192.168.6.1:/System/Volumes/Data/Users/dev on /mnt failed: Connection refused

但是，同样的配置，在 :ref:`ubuntu64bit_pi` ，却能够作为NFS客户端正常挂载和使用，这个报错是因为 :ref:`alpine_linux` 默认没有安装 ``nfs-utils`` 工具，并且没有启动NFS相关服务导致的。详见 :ref:`alpine_nfs`

排查方法的经验是使用 ``rpcinfo -p`` 查看远程服务是否打开了对应服务端口::

   rpcinfo -p 192.168.6.1

要检查有哪些服务列表也可以使用以下命令::

   rpcinfo -p 192.168.6.1 | cut -c30- | sort -u

可以看到::

   mountd
   nfs
   nlockmgr
   rpcbind
   rquotad
   status

此外可以检查服务器上输出的挂载点::

   showmount -e 192.168.6.1

输出显示::

   Exports list on 192.168.6.1:
   /System/Volumes/Data/Users/dev      192.168.6.0

上述输出显示NFS服务器正常，并且对比不同NFS客户端现象不同，则需要排查NFS客户端

防火墙
==========

macOS提供了一个防火墙，需要检查确认一下默认是否启用了防火墙（可能和版本相关，不同版本默认有可能开启也可能关闭了防火墙，目前最新的macOS都是默认关闭防火墙）。对于启用了防火墙的macOS系统，需要配置 ``System Preferences => Secuirty & Privancy => Firewall`` ，设置允许TCP端口 ``2049, 111`` 。

.. note::

   macOS的防火墙配置我还没有具体实践，

参考
======

- `NFS server support in OS X 10.15.x Catalina? <https://apple.stackexchange.com/questions/384806/nfs-server-support-in-os-x-10-15-x-catalina>`_
- `How to get nfsd to serve NFSv4 on High Sierra? <https://apple.stackexchange.com/questions/322229/how-to-get-nfsd-to-serve-nfsv4-on-high-sierra>`_
- `How to create an NFS share on MAC OS X (Snow Leopard) and mount (automatically during startup) from another MAC <https://community.spiceworks.com/how_to/61136-how-to-create-an-nfs-share-on-mac-os-x-snow-leopard-and-mount-automatically-during-startup-from-another-mac>`_
- `How to configure an NFS share from Mac OSX to Linux <https://www.williamrobertson.net/documents/nfs-mac-linux-setup.html>`_
- `macOS X Mount NFS Share / Set an NFS Client <https://www.cyberciti.biz/faq/apple-mac-osx-nfs-mount-command-tutorial>`_
- `Exporting Directories with NFS <https://docstore.mik.ua/orelly/unix3/mac/ch03_10.htm>`_
- `macOS Catalina: nfsd needs to change exported dir to /System/Volumes/Data/... <https://github.com/drud/ddev/issues/1869>`_
- `Snow Leopard NFS Server and no_root_squash <https://serverfault.com/questions/118816/snow-leopard-nfs-server-and-no-root-squash>`_ 解决服务器端用户uid映射问题，否则写入失败
- `Fast NFS volume on macOS <https://gist.github.com/joaomlneto/74338ef17f3591f04ee20413b5b4a57e>`_ 介绍了OS X的NFS客户端，需要使用参数 ``nolocks,locallocks`` 
- `Mounting Directory - Connection Refused <https://unix.stackexchange.com/questions/61329/mounting-directory-connection-refused>`_ 排查Connection Refused问题
