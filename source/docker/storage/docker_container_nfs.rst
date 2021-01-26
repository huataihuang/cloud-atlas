.. _docker_container_nfs:

==================
Docker容器使用NFS
==================

.. note::

   :ref:`kubernetes` 在Docker基础上采用了 :ref:`k8s_persistent_volumes` 实现更为抽象化的持久化存储。


简单来说，Docker使用NFS存储有两种形式：

- 方法一：在容器内部安装 ``nfs-utils`` ，就如同常规到NFS客户端一样，在容器内部直接通过rpcbind方式挂载NFS共享输出，这种方式需要每个容器独立运行rpcbind服务，并且要使用 :ref:`docker_systemd` ，复杂且消耗较多资源。不过，优点是完全在容器内部控制，符合传统SA运维方式。
- 方法二：Host主机上创建NFS类型的Docker Volume，然后将docker volume映射到容器内部，这样容器就可以直接使用Docker共享卷，这种方式最为简洁优雅。
- 方法三：使用Docker volume plugin，例如 `ContainX/docker-volume-netshare <https://github.com/ContainX/docker-volume-netshare>`_ 可以直接将NFS共享卷作为容器卷挂载(就不需要在host主机上去执行挂载NFS命令了)

方法一：在容器内部使用NFS
==========================

要知道，容器并不是完整的虚拟机，天然就是瘦客户端并且有意削减了部分操作系统功能。

为了能够在容器中挂载NFS，我们需要同时运行多个服务，这样我们就需要有一个容器内部运行的 :ref:`docker_init` 以便启动多个服务来支持NFS挂载。例如，我们可以选择 :ref:`docker_systemd` 。

这里的案例假设我们已经构建了一个使用 :ref:`docker_systemd` 的容器 ``centos8-ssh`` ，然后我们来实践NFS挂载部署。

.. note::

   如果使用 NFSv4 ，就不需要安装 ``nfs-utils`` ，也不需要设置 ``systemd``

NFS服务器
-------------

我的测试NFS服务部署在运行Docker服务的物理主机上，该物理服务器是 :ref:`ubuntu_linux` ，已完成 :ref:`ubunut_nfs` ，共享目录设置如下:

- `/etc/exportfs` ::

   /data   *(rw,sync,no_root_squash,no_subtree_check)

详细部署方法和解释见 :ref:`ubunut_nfs`

NFS客户端
-------------

- 在容器内部安装 ``nfs-utils`` ::

   dnf install nfs-utils

- 在容器内部配置 ``/etc/fstab`` 如下::

   172.17.0.1:/data  /data  nfs  rw,soft,intr,vers=3,proto=tcp,rsize=32768,wsize=32768 0 0

- 在容器内部执行挂载::

   mkdir /data
   mount /data

报错::

   mount.nfs: Operation not permitted

这个问题和 :ref:`docker_systemd` 相同，需要赋予运行容器 ``CAP_SYS_ADMIN`` 能力，所以需要重新创建运行容器，并传递参数 ``--cap-add sys_admin``

mount.nfs: access denied
---------------------------

- 重新增加了 ``CAP_SYS_ADMIN`` 能力创建容器后，再次挂载NFS卷，提示错误::

   mount.nfs: access denied by server while mounting 172.17.0.1:/data

但是，服务器端命名已经设置了 ``/data            <world>`` 输出给所有客户端，为何会拒绝？

使用 ``-v`` 参数挂载::

   mount -v /data

显示输出::

   mount.nfs: timeout set for Fri Jan 22 08:16:08 2021
   mount.nfs: trying text-based options 'rw,soft,intr,vers=3,proto=tcp,rsize=32768,wsize=32768,addr=172.17.0.1'
   mount.nfs: prog 100003, trying vers=3, prot=6
   mount.nfs: trying 172.17.0.1 prog 100003 vers 3 prot TCP port 2049
   mount.nfs: prog 100005, trying vers=3, prot=6
   mount.nfs: trying 172.17.0.1 prog 100005 vers 3 prot TCP port 43999
   mount.nfs: mount(2): Permission denied
   mount.nfs: access denied by server while mounting 172.17.0.1:/data

- 检查服务器的rpc输出::

   rpcinfo -p 172.17.0.1

显示输出::

   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp  43059  mountd
    100005    1   tcp  46359  mountd
    100005    2   udp  37724  mountd
    100005    2   tcp  39809  mountd
    100005    3   udp  41232  mountd
    100005    3   tcp  43999  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100003    3   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
    100021    1   udp  34464  nlockmgr
    100021    3   udp  34464  nlockmgr
    100021    4   udp  34464  nlockmgr
    100021    1   tcp  35037  nlockmgr
    100021    3   tcp  35037  nlockmgr
    100021    4   tcp  35037  nlockmgr

- 在容器内部检查服务器端输出的NFS共享::

   showmount -e 172.17.0.1

显示输出::

   Export list for 172.17.0.1:
   /data *

- 通过tcpdump抓包::

   tcpdump -s0 -i eth0 host 172.17.0.1 -w /tmp/client.pcap

- 然后通过wireshark分析::

   tshark -tad -n -r /tmp/client.pcap -Y 'frame.number == 500' -O rpc | sed '/^Re/,$ !d'

输出显示::

   Running as user "root" and group "root". This could be dangerous.

tcpdump的分析 ``nfs.status!=0`` ::

   tshark -tad -nr /tmp/client.pcap -Y nfs.status!=0

同样显示输出::

   Running as user "root" and group "root". This could be dangerous.

- 在NFS服务器端检查输出::

   cat /var/lib/nfs/etab

显示如下::

   /data	*(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,anonuid=65534,anongid=65534,sec=sys,rw,secure,no_root_squash,no_all_squash) 

.. warning::

   暂时还没有解决容器内部直接mount NFS问题，待进一步排查

方法二：Docker NFS volume(推荐)
==================================

采用Docker NFS volume的方式更为简单明了，实际上也就是先在host主机上挂载NFS卷，然后通过卷映射方式映射到容器内部。这种方式不需要给容器特殊的权限，也不需要运行systemd这样沉重的进程管理器，特别适合轻量级运行容器。当然，你也可以构建 :ref:`docker_tini` 来运行一个轻量级的进程管理器，甚至使用 :ref:`docker_systemd` 来构建复杂的 "富容器" 。

- 在Host主机上挂载NFS卷，即编辑host主机 ``/etc/fstab`` 添加如下配置::

   172.17.0.1:/data  /container-data  nfs  rw,soft,intr,vers=3,proto=tcp,rsize=32768,wsize=32768 0 0   

- 然后在host主机上挂载NFS卷::

   mkdir /container-data
   mount /container-data

- 挂载以后在host主机上检查 ``df -h`` 可以看到NFS已经挂载::

   172.17.0.1:/data  117G   12G  101G  11% /container-data

- 现在我们启动一个容器并且映射这个挂载的NFS卷::

   docker run -itd -p 1222:22 --hostname centos8-nfs --name centos8-nfs \
     -v /container-data:/container-data centos:8

- 使用 ``docker ps | grep centos8-nfs`` 检查可以看到::

   7a9e6663a988        centos:8                     "/bin/bash"              9 seconds ago       Up 7 seconds        0.0.0.0:1222->22/tcp             centos8-nfs

- 然后我们进入这个 ``centos8-nfs`` 容器::

   docker exec -it centos8-nfs /bin/bash

- 在容器内部检查磁盘 ``df -h`` 可以看到::

   Filesystem        Size  Used Avail Use% Mounted on
   ...
   172.17.0.1:/data  117G   12G  101G  11% /container-data

方法三：使用Docker volume plugin
==================================

`ContainX/docker-volume-netshare <https://github.com/ContainX/docker-volume-netshare>`_ 是一个Docker plugin，可以用来挂载NFS v3/4, AWS EFS 或者 CIFS到容器内部。

.. note::

   使用netshare插件部署安装比较麻烦，没有集成到发行版中，并且随着Kubernetes发展，较少采用Docker volume plugin方式。所以我没有具体实践这个方法，仅供参考。后续如果有实践需求，例如需要在简单的Docker环境挂载不同的NFS/CIFS等卷情况，我再实践。

- 安装netshare插件::

   go get github.com/ContainX/docker-volume-netshare
   go build

也可以通过二进制安装，提供Ubuntu/Debian安装包::

   wget https://github.com/ContainX/docker-volume-netshare/releases/download/v0.36/docker-volume-netshare_0.36_amd64.deb
   sudo dpkg -i docker-volume-netshare_0.36_amd64.deb

- 修改 ``/etc/default/docker-volume-netshare`` 启动参数

- 启动服务::

   service docker-volume-netshare start

使用
-----

- 运行插件 - 可以添加到systemd或者在后台运行::

   sudo docker-volume-netshare nfs

- 启动容器::

   docker run -i -t --volume-driver=nfs -v nfshost/path:/mount ubuntu /bin/bash

参考
======

- `TECH::Using NFS with Docker – Where does it fit in? <https://whyistheinternetbroken.wordpress.com/2015/05/12/techusing-nfs-with-docker-where-does-it-fit-in/>`_ - 原作者另外写了两篇有关使用NetApp FlexGroup volumes和加密NFS mount文章，可以进一步参考
- `Mount failed with mount: mount.nfs: access denied by server while mounting error <https://access.redhat.com/solutions/3773891>`_ Red Hat提供了非常好的debug方法，建议参考 
- `“mount.nfs: access denied by server while mounting” – how to resolve <https://www.thegeekdiary.com/mount-nfs-access-denied-by-server-while-mounting-how-to-resolve/>`_
- `Mounting nfs shares inside docker container <https://stackoverflow.com/questions/39922161/mounting-nfs-shares-inside-docker-container>`_ 提供了docker挂载NFS的多种方法概述
- `ContainX/docker-volume-netshare <https://github.com/ContainX/docker-volume-netshare>`_
