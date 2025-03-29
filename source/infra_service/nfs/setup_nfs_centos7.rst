.. _setup_nfs_centos7:

=======================
CentOS 7 配置NFS
=======================

CentOS 7使用 ``systemctl`` 管理和设置NFS，以下按照服务端和客户端设置分别介绍。

设置Linux服务端
===================

将移动硬盘挂载到 ``/data`` 目录::

   mount /dev/sdb1 /data

使用以下命令安装 NFS 支持::

   yum install nfs-utils

启动nfs服务并设置nfs相关服务在操作系统启动时启动::

   systemctl enable --now rpcbind
   systemctl enable --now nfs-server
   systemctl enable --now nfs-lock
   systemctl enable --now nfs-idmap  

服务器端设置NFS卷输出，即编辑 ``/etc/exports`` 添加::

   /data   192.168.122.0/24(rw,sync,no_root_squash,no_subtree_check)

参数解析:

- ``/data`` – 共享目录

- ``192.168.122.0/24/24`` – 允许访问NFS的客户端IP地址段(这里使用是针对libvirt虚拟化NAT网段)

- ``rw`` – 允许对共享目录进行读写

- ``sync`` – 实时同步共享目录，设置同步

- ``no_root_squash`` – 允许root访问

- ``no_all_squash`` - 允许用户授权

- ``no_subtree_check`` - 如果卷的一部分被输出，从客户端发出请求文件的一个常规的调用子目录检查验证卷的相应部分。如果是整个卷输出，禁止这个检查可以加速传输。 

NFS服务器排查
----------------

启动 ``nfs-server`` 时候报错 ::

   # systemctl start nfs-server
   Job for nfs-server.service failed. See 'systemctl status nfs-server.service' and 'journalctl -xn' for details.

   # systemctl status nfs-server.service
   nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled)
   Active: failed (Result: exit-code) since Wed 2015-09-16 16:54:14 CST; 51s ago
   Process: 17476 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=1/FAILURE)

   Sep 16 16:54:14 ats-30-1 systemd[1]: Starting NFS server and services...
   Sep 16 16:54:14 ats-30-1 exportfs[17476]: exportfs: /iso requires fsid= for NFS export
   Sep 16 16:54:14 ats-30-1 systemd[1]: nfs-server.service: control process exited, code=exited status=1
   Sep 16 16:54:14 ats-30-1 systemd[1]: Failed to start NFS server and services.
   Sep 16 16:54:14 ats-30-1 systemd[1]: Unit nfs-server.service entered failed state.
   Hint: Some lines were ellipsized, use -l to show in full.

参考 `Using exportfs with NFSv4 <https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-nfs-server-config-exports.html>`_ ::

   NFSv4客户端可以查看NFSv4服务器输出的所有exorts作为一个单一文件系统，称为 NFSv4 伪文件系统( ``NFSv4 pseudo-file system`` )。在Red Hat Enterprise Linux上，这个伪文件系统被标识伪一个单一的，真实文件系统，通过 ``fsid=0`` 选项输出。

修改 ``/etc/exportfs`` ，添加 ``fsid=0`` ::

   /iso    *(fsid=0,rw,sync,no_subtree_check,all_squash,anonuid=36,anongid=36)

NFS客户端挂载
=============

Linux挂载NFS的客户端非常简单的命令，先创建挂载目录，然后用 ``-t nfs`` 参数挂载就可以了 ::

   mount -t nfs  192.168.122.1:/data /data

如果要设置客户端启动时候就挂载NFS，可以配置 ``/etc/fstab`` 添加以下内容 ::

   192.168.122.1:/data    /data  nfs auto,rw,vers=3,hard,intr,tcp,rsize=32768,wsize=32768      0   0

然后在客户端简单使用以下命令就可以挂载 ::

   mount /data

如果出现以下类似报错，则检查一下系统是否缺少 ``mount.nfs`` 程序，如果缺少，则表明尚未安装 ``nfs-utils`` 工具包，需要补充安装后才能作为客户端挂载NFS ::

   mount: wrong fs type, bad option, bad superblock on 192.168.122.1:/data,
          missing codepage or helper program, or other error
          (for several filesystems (e.g. nfs, cifs) you might
          need a /sbin/mount.<type> helper program)

          In some cases useful info is found in syslog - try
          dmesg | tail or so.

通过防火墙挂载NFS服务
=====================

在生产环境，可能会因为安全需求在NFS服务器和客户端之间部署防火墙。此时，NFS客户端挂载的时候会有如下输出报错 ::

   mount.nfs: Connection timed out

参考 `Running NFS Behind a Firewall <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Storage_Administration_Guide/nfs-serverconfig.html#s2-nfs-nfs-firewall-config>`_ 设置防火墙允许访问NFS服务器的服务端口，注意，需要配置NFS服务使用固定端口。

可以在Linux NFS服务器上执行以下命令获得NFS端口信息 ::

   rpcinfo -p

输出::

      program vers proto   port  service
       100000    4   tcp    111  portmapper    <= rpcbind 服务
       100000    3   tcp    111  portmapper    <= rpcbind 服务
       100000    2   tcp    111  portmapper    <= rpcbind 服务
       100000    4   udp    111  portmapper    <= rpcbind 服务
       100000    3   udp    111  portmapper    <= rpcbind 服务
       100000    2   udp    111  portmapper    <= rpcbind 服务
       100024    1   udp  33948  status        <= rpc.statd 服务
       100024    1   tcp  35264  status        <= rpc.statd 服务
       100005    1   udp  20048  mountd        <= rpc.mount 服务
       100005    1   tcp  20048  mountd        <= rpc.mount 服务
       100005    2   udp  20048  mountd        <= rpc.mount 服务
       100005    2   tcp  20048  mountd        <= rpc.mount 服务
       100005    3   udp  20048  mountd        <= rpc.mount 服务
       100005    3   tcp  20048  mountd        <= rpc.mount 服务
       100003    3   tcp   2049  nfs
       100003    4   tcp   2049  nfs
       100227    3   tcp   2049  nfs_acl
       100003    3   udp   2049  nfs
       100003    4   udp   2049  nfs
       100227    3   udp   2049  nfs_acl
       100021    1   udp  48508  nlockmgr
       100021    3   udp  48508  nlockmgr
       100021    4   udp  48508  nlockmgr
       100021    1   tcp  38808  nlockmgr
       100021    3   tcp  38808  nlockmgr
       100021    4   tcp  38808  nlockmgr

- ``rpc.mount`` 服务端口:

通过 ``lsof | grep rpc.mount`` 命令检查，可以看到 ``rpc.mount`` 服务使用的端口是 ::

   rpc.mount 27681          root    7u     IPv4           18221951        0t0        UDP *:mountd
   rpc.mount 27681          root    8u     IPv4           18221953        0t0        TCP *:mountd (LISTEN)

这里 ``*:mountd`` 可以从 ``/etc/serives`` 配置文件中找出对应的端口是 ``20048`` ::

   #grep mountd /etc/services
   mountd          20048/tcp               # NFS mount protocol
   mountd          20048/udp               # NFS mount protocol

- ``rpc.statd`` 服务端口

``lsof | grep rpc.statd`` 命令检查可以看到 ::

   rpc.statd 27663       rpcuser    8u     IPv4           18236210        0t0        UDP *:33948
   rpc.statd 27663       rpcuser    9u     IPv4           18236212        0t0        TCP *:35264 (LISTEN)

- ``rpcbind`` 服务端口

``lsof | grep rpcbind`` 命令可以查看到 ::

   rpcbind   43419           rpc    4u     IPv4              28734        0t0        TCP *:sunrpc (LISTEN)
   rpcbind   43419           rpc    7u     IPv4           11838817        0t0        UDP *:sunrpc
   rpcbind   43419           rpc    8u     IPv4           11838818        0t0        UDP *:766

检查对应端口::

   #grep sunrpc /etc/services
   sunrpc          111/tcp         portmapper rpcbind      # RPC 4.0 portmapper TCP
   sunrpc          111/udp         portmapper rpcbind      # RPC 4.0 portmapper UDP

设置RPC服务使用端口
-------------------

由于NFS需要rpcbind，动态分配RPC服务端口会导致无法配置防火墙规则。

默认情况下，NFS使用的rpcbind使用动态设置RPC服务端口，需要修改以下配置：

- 配置 ``/etc/sysconfig/nfs`` 文件来设置RPC服务使用的端口 ::

   # 需要固定端口设置项前面的"#"符号需要去除，以便激活静态配置端口

   # Optional arguments passed to rpc.mountd. See rpc.mountd(8)
   RPCMOUNTDOPTS=""
   # Port rpc.mountd should listen on. 
   MOUNTD_PORT=892

   # Optional arguments passed to rpc.statd. See rpc.statd(8)
   STATDARG=""
   # Port rpc.statd should listen on.
   STATD_PORT=662

   # Outgoing port statd should used. The default is port
   # is random
   STATD_OUTGOING_PORT=2020

- 配置 ``/etc/modprobe.d/lockd.conf`` 中设置 ``nlockmgr`` 服务端口 ::

   options lockd nlm_tcpport=32768
   options lockd nlm_udpport=32768
   options nfs callback_tcpport=32764  # 可选参数

这里 ``callback_tcpport`` 是用于 ``NFSv4.0 callback`` ，也就是设置 ``/proc/sys/fs/nfs/nfs_callback_tcpport`` ，并且还需要设置防火墙允许服务器能够连接客户端的端口 ``32764`` 。不过，对于NFSv4.1或更高版本，不需要此步骤，并且在纯NFSv4环境，也不需要 ``mountd``, ``statd`` 和 ``lockd`` 的端口。

``lockd.conf`` 配置参考 `Debian SecuringNFS <https://wiki.debian.org/SecuringNFS>`_

这个参数也可以通过 ``/etc/sysctl.conf`` 或者 ``/etc/sysctl.d/nfs-static-ports.conf`` 内核参数传递

- 在CentOS 7上，内核参数 ``fs.nfs.nlm_tcpport`` 和 ``fs.nfs.nlm_udpport`` 默认都是 ``0`` ::

   fs.nfs.nfs_callback_tcpport = 32764
   fs.nfs.nlm_tcpport = 32768
   fs.nfs.nlm_udpport = 32768

- 重新加载NFS配置和服务（貌似 ``status`` 服务和 ``nlockmgr`` 服务端口不生效）::

   systemctl restart nfs-config
   systemctl restart nfs-server

再次使用 ``rpcinfo -p`` 确认端口配置是否生效。

- 改为重启以下服务，此时检查发现 ``status`` 端口正确改成 ``662`` ，但是 ``nlockmgr`` 因为内核没有重新加载模块，所以端口没有修改 ::

   systemctl restart nfs-idmap
   systemctl restart nfs-lock
   systemctl restart nfs-server
   systemctl restart rpcbind

- 通过 ``sysctl`` 修改 ``nlockmgr`` 端口，但是发现如果不重新加载内核模块是不能订正 ``nlockmgr`` 端口 ::

   sysctl -w fs.nfs.nlm_tcpport=32768
   sysctl -w fs.nfs.nlm_udpport=32768

..

   暂时没有找到解决方法，所以还是通过重启操作系统来使得 ``nlockmgr`` 端口调整到 ``32768``

配置防火墙端口
--------------

   NFS的TCP和UDP端口2049

   rpcbind/sunrpc的TCP和UDP端口111

   设置 ``MOUNTD_PORT`` 的TCP和UDP端口

   设置 ``STATD_PORT`` 的TCP和UDP端口

   设置 ``LOCKD_TCPPORT`` 的TCP端口

   设置 ``LOCKD_UDPPORT`` 的UDP端口

-  使用 ``firewalld`` 的配置方法：

在 Linux NFS 服务器上使用以下命令开启iptables防火墙允许访问以上端口 ::

   firewall-cmd --permanent --add-port=2049/tcp
   firewall-cmd --permanent --add-port=2049/udp
   firewall-cmd --permanent --add-port=111/tcp
   firewall-cmd --permanent --add-port=111/udp
   firewall-cmd --permanent --add-port=892/tcp
   firewall-cmd --permanent --add-port=892/udp
   firewall-cmd --permanent --add-port=662/tcp
   firewall-cmd --permanent --add-port=662/udp
   firewall-cmd --permanent --add-port=32768/tcp
   firewall-cmd --permanent --add-port=32768/udp

在 Linux NFS 服务器上使用以下命令重新加载防火墙规则 ::

   firewall-cmd --reload

- 使用 ``iptables`` 的配置方法 ::

   iptables -A INPUT -p tcp -m tcp --dport 2049 -j ACCEPT
   iptables -A INPUT -p udp -m udp --dport 2049 -j ACCEPT
   iptables -A INPUT -p tcp -m tcp --dport 111 -j ACCEPT
   iptables -A INPUT -p udp -m udp --dport 111 -j ACCEPT
   iptables -A INPUT -p tcp -m tcp --dport 892 -j ACCEPT
   iptables -A INPUT -p udp -m udp --dport 892 -j ACCEPT
   iptables -A INPUT -p tcp -m tcp --dport 662 -j ACCEPT
   iptables -A INPUT -p udp -m udp --dport 662 -j ACCEPT
   iptables -A INPUT -p tcp -m tcp --dport 32803 -j ACCEPT
   iptables -A INPUT -p udp -m udp --dport 32769 -j ACCEPT

..

   如果要指定接口，也可以加上参数如 ``-i virbr0-nic`` ，例如 ``iptables -A INPUT -i virbr0-nic -p tcp -m tcp --dport 2049 -j ACCEPT``

参考
====

-  `Setting Up NFS Server And Client On CentOS 7 <http://www.unixmen.com/setting-nfs-server-client-centos-7/>`_
