.. _macos_docker_shell:

===============================
获取macOS平台Docker虚拟机shell
===============================

我们知道macOS上的Docker Desktop for macOS实际上是在Linux虚拟机中运行的Docker容器，这对于macOS主机上使用Docker多了一层虚拟化。有些情况下，我们需要能够访问这个Linux虚拟机，以便实现一些hack操作。

方法一: netcat(推荐)
=============================

使用 ``nc`` 命令连接Docker的debug-shell socket文件( 在 :ref:`docker_macos_vm` 详述):

.. literalinclude:: ../desktop/docker_macos_vm/netcat_docker_macos_vm_sock
   :language: bash
   :caption: 使用 ``nc`` 命令连接Docker的debug-shell socket访问docker虚拟机终端

.. note::

   这里 ``nc`` 使用 :ref:`macos` 内置的 ``nc`` 命令( ``/usr/bin/nc`` )，支持参数 ``-U`` (即 ``Use UNIX-domain sockets`` )，而不能使用 :ref:`homebrew` 提供的 ``nc`` (不支持 ``-U`` 参数)。Linux版本的 ``nc`` 是支持 ``-U`` 参数的，但是 homebrew 版本没有提供

显示的提示符比较奇怪，不过不影响使用::

   / # ^[[14;5R

我们使用 ``df -h`` 命令可以看到Docker虚拟机的存储挂载::

   Filesystem                Size      Used Available Use% Mounted on
   overlay                 994.1M      4.0K    994.1M   0% /
   tmpfs                   994.1M      8.0K    994.1M   0% /containers/onboot/000-dhcpcd/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/001-sysfs/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/002-sysctl/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/003-format/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/004-extend/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/005-mount/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/006-metadata/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/007-services0/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/008-services1/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/009-swap/tmp
   tmpfs                   994.1M         0    994.1M   0% /containers/onboot/010-mount-docker/tmp
   /dev/vda1                58.4G      9.8G     45.6G  18% /containers/services
   /dev/vda1                58.4G      9.8G     45.6G  18% /containers/services/docker
   tmpfs                   994.1M      4.0K    994.1M   0% /containers/services/acpid/tmp
   overlay                 994.1M      4.0K    994.1M   0% /containers/services/acpid/rootfs
   ...

使用命令 ``exit`` 可以推出这个shell

进入shell，可以执行 ``. /etc/profile`` 获得环境

:ref:`alpine_linux` 非常精简，没有找到 apk 安装工具，迷惑

方法二：nsenter(推荐)
=======================

.. warning::

   使用nsenter从容器内部进入host主机的名字空间，但是对文件系统是只读

另外一种巧妙的方法是运行一个debian容器，然后在这个debian容器中执行 ``nsenter`` 通过 ``pid=host`` 来实现进入到运行 Docker4Mac 的mini VM的进程空间，这样就相当于进入了macOS的Docker虚拟机::

   docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh

在这个运行的debian容器中通过 ``nsenter`` 进入到host主机，也就是Docker VM名字空间以后，就可以看到虚拟机的提示符::

   / #

我们可以在这个Docker VM中执行网络检查::

   ip addr

可以看到::

   1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
       link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
       inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
          valid_lft forever preferred_lft forever
       inet6 ::1/128 scope host
          valid_lft forever preferred_lft forever
   2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
       link/ether 02:50:00:00:00:01 brd ff:ff:ff:ff:ff:ff
       inet 192.168.65.3/24 brd 192.168.65.255 scope global dynamic noprefixroute eth0
          valid_lft 6320sec preferred_lft 4880sec
       inet6 fe80::50:ff:fe00:1/64 scope link
          valid_lft forever preferred_lft forever
   3: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
       link/ipip 0.0.0.0 brd 0.0.0.0
   4: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN group default qlen 1000
       link/tunnel6 :: brd ::
   5: services1@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
       link/ether 2e:12:69:6d:a4:d2 brd ff:ff:ff:ff:ff:ff link-netns services
       inet 192.168.65.4 peer 192.168.65.5/32 scope global services1
          valid_lft forever preferred_lft forever
       inet6 fe80::2c12:69ff:fe6d:a4d2/64 scope link
          valid_lft forever preferred_lft forever
   7: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
       link/ether 02:42:60:37:48:61 brd ff:ff:ff:ff:ff:ff
       inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
          valid_lft forever preferred_lft forever
       inet6 fe80::42:60ff:fe37:4861/64 scope link
          valid_lft forever preferred_lft forever
   9: vethc2f1823@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
       link/ether e2:a5:ee:12:74:fe brd ff:ff:ff:ff:ff:ff link-netnsid 1
       inet6 fe80::e0a5:eeff:fe12:74fe/64 scope link
          valid_lft forever preferred_lft forever
   11: vethd5f3782@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
       link/ether ae:3f:ef:d6:8a:04 brd ff:ff:ff:ff:ff:ff link-netnsid 2
       inet6 fe80::ac3f:efff:fed6:8a04/64 scope link
          valid_lft forever preferred_lft forever

这里可以看到Docker VM使用的虚拟网卡 ``eth0`` 分配的IP地址是 ``192.168.65.3`` ，这个虚拟机和macOS物理主机上对应的IP地址 ``192.168.65.1`` 对应，也就是说，如果我们使用 NFS 方式挂载物理主机上的NFS卷，访问的NFS服务器端地址就是这样获得的。

这里还可以看到在Docker VM上运行的Docker网络是 ``172.17.xx.xx/16`` ，是一个NAT网络，我们可以看到在Docker VM端分配的IP地址是 ``172.17.0.1`` ，我们登录到 :ref:`docker_studio` 中配置的 ``fedora-ssh`` 容器中，执行 ``ifconfig`` 可以看到对应的Docker 容器的NAT网卡的IP地址 ``172.17.0.2`` 。这也验证了我们的Docker VM上实际上有2个网络::

   192.168.65.x/24 => 和物理主机macOS连接的NAT网络，用于虚拟机
   172.17.x.x/16 => 和Docker0连接的NAT网络，用于容器

在Docker容器中，通过两层NAT，依然可以访问外界Internet。不过，反过来，外部需要访问Docker容器就比较麻烦了，需要做端口映射。

方法三：从一个预制镜像运行nsenter
====================================

这个方法最简单::

   docker run -it --rm --privileged --pid=host justincormack/nsenter1

实践
========

我感觉使用方法二最为理想，通过运行容器进入物理服务器的名字空间，也就实现了访问虚拟机的能力。这对我使用 :ref:`macos_nfs` 挂载macOS物理主机上共享的NFS卷，实现存储持久化非常方便。

参考
======

- `Getting a Shell in the Docker Desktop Mac VM <https://gist.github.com/BretFisher/5e1a0c7bcca4c735e716abf62afad389>`_
