.. _gluster_k8s:

=============================
在Kubernetes中部署GlusterFS
=============================

我在 :ref:`arm_k8s_deploy` 后，需要为Kubernetes提供基于GlusterFS的持久化存储。

有两种方式在Kubernetes中提供GlusterFS存储卷服务：

- 方法一：物理主机构建GlusterFS集群以及对应的卷，然后仅在Kubernetes作为客户端挂载已经构建好的GlusterFS卷。这种方式比较接近于传统的GlusterFS集群维护

- 方法二：完全采用Kubernetes结合Heketi实现完整的动态创建GlusterFS以及块分配，同时实现支持多个GlusterFS集群管理。这种方式符合Kubernetes原生管理

.. note::

   在Kubernetes中实现原生管理的另外一个著名开源分布式存储是 :ref:`ceph` ，使用 :ref:`rook` 实现云原生管理ceph。

本文采用手工部署GlusterFS服务，并配置 PV/PVC 提供给Kubernetes使用存储卷。后续在 :ref:`heketi` 实践中介绍如何云原生管理GlusterFS分布式存储。

安装GlusterFS服务器软件
========================

.. note::

   本文实践是在树莓派上运行的Ubuntu操作系统上部署GlusterFS集群。Ubuntu Server for Raspberry Pi已经在软件仓库提供了GlusterFS，所以可以跳过添加GlusterFS仓库配置部分。也可以直接添加GlusterFS官方仓库安装最新版本。

Debian:添加GlusterFS仓库配置
----------------------------

- 添加apt GPG key::

   wget -O - https://download.gluster.org/pub/gluster/glusterfs/LATEST/rsa.pub | apt-key add -

- 添加apt仓库配置::

   DEBID=$(grep 'VERSION_ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
   DEBVER=$(grep 'VERSION=' /etc/os-release | grep -Eo '[a-z]+')
   DEBARCH=$(dpkg --print-architecture)
   echo deb https://download.gluster.org/pub/gluster/glusterfs/LATEST/Debian/${DEBID}/${DEBARCH}/apt ${DEBVER} main > /etc/apt/sources.list.d/gluster.list

- 更新软件列表::

   apt update

Ubuntu添加软件仓库
-------------------

对于Ubuntu系统，请参考 `launchpad.net "Gluster" team <https://launchpad.net/~gluster>`_ ，提供了最新的GlusterFS 8 / 9 系列。我这里为了简化部署，直接使用了Ubuntu for Raspberry Pi内建提供的GlusterFS 7。

你可以通过上述仓库安装最新版本，例如::

   apt install software-properties-common
   sudo add-apt-repository ppa:gluster/glusterfs-9
   sudo apt-get update

安装GlusterFS软件
------------------

- 安装软件::

   apt install glusterfs-server

配置GlusterFS服务器
======================

.. note::

   这里仅做演示，本文暂时采用简单的双节点部署双副本复制卷，提供简单数据冗余。不过双节点服务器容易出现脑裂，实际生产环境建议采用3个节点或跟多节点部署复制卷，或者分布式复制卷。
   
   (取消:这里仅做演示，本文暂时采用简单的双节点部署分布式卷，没有任何数据冗余，不能保证数据安全，请勿直接照搬。)

演示环境仅有2台节点::

   192.168.6.15 pi-worker1
   192.168.6.16 pi-worker2

- 启动glusterd服务并配置激活::

   systemctl start glusterd
   systemctl enable glusterd

- 检查服务::

   systemctl status glusterd
   glusterfsd --version

这里安装的版本是 glusterfs 7.2

- 在第一台服务器上执行以下命令建立信任存储池::

   gluster peer probe 192.168.6.16

然后检查对端状态::

   gluster peer status

显示如下::

   Number of Peers: 1

   Hostname: 192.168.6.16
   Uuid: c4d1d2e0-460c-46b6-b9c2-e908dc140c1a
   State: Peer in Cluster (Connected)

检查资源池::

   gluster pool list

显示如下::

   UUID                                    Hostname        State
   c4d1d2e0-460c-46b6-b9c2-e908dc140c1a    192.168.6.16    Connected
   61a731af-19af-4ed3-8700-4adc508f5771    localhost       Connected

- 在上述2台服务器上同时创建本地目录::

   mkdir -p /data/brick1/gv0

- 选择 **任意一台服务器** 创建双副本卷::

   gluster volume create gv0 replica 2 \
     192.168.6.15:/data/brick1/gv0 \
     192.168.6.16:/data/brick1/gv0

注意，双节点双副本模式，会提示警告::

   Replica 2 volumes are prone to split-brain. Use Arbiter or Replica 3 to avoid this. See: http://docs.gluster.org/en/latest/Administrator%20Guide/Split%20brain%20and%20ways%20to%20deal%20with%20it/.
   Do you still want to continue?
    (y/n)

此外，直接在根目录下建立glusterfs卷会提示不推荐，需要使用 ``force`` 参数强制::

   volume create: gv0: failed: The brick 192.168.6.16:/data/brick1/gv0 is being created in the root partition. It is recommended that you don't use the system's root partition for storage backend. Or use 'force' at the end of the command if you want to override this behavior.

所以实际需要执行以下命令::

   gluster volume create gv0 replica 2 192.168.6.15:/data/brick1/gv0 192.168.6.16:/data/brick1/gv0 force

- 启动卷::

   gluster volume start gv0

- 现在检查卷状态::

   gluster volume info

输出显示::

   Volume Name: gv0
   Type: Replicate
   Volume ID: 73f3cb83-7a31-41b1-a49c-aafd6fc92fd8
   Status: Started
   Snapshot Count: 0
   Number of Bricks: 1 x 2 = 2
   Transport-type: tcp
   Bricks:
   Brick1: 192.168.6.15:/data/brick1/gv0
   Brick2: 192.168.6.16:/data/brick1/gv0
   Options Reconfigured:
   transport.address-family: inet
   storage.fips-mode-rchecksum: on
   nfs.disable: on
   performance.client-io-threads: off

Kubernetes使用GlusterFS卷
==========================

gluserfs-client
-----------------

为了能够在Kubernetes集群使用GlusterFS卷，首先需要在Kubernetes的管控节点上安装 ``gluster-client`` 软件包，因为Kubernetes scheduler需要用来创建gluster卷。

- 在 ``pi-master1`` 服务器(管控)上执行以下命令安装::

   sudo apt install glusterfs-client

持久化卷
--------------

- 创建Service和Endpoints

.. literalinclude:: gluster_k8s/gluster-endpoints.yaml
   :language: yaml
   :linenos:
   :caption:

参数解析:

  - 注意 ``name`` 必须在各个配置中完全匹配
  - ``ip`` 必须是Gluster存储服务器的实际IP地址，而不是主机名
  - ``port`` 号是忽略的

执行创建::

   kubectl create -f gluster-endpoints.yaml

检查service::

   kubectl get service

显示输出::

   NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
   glusterfs-cluster   ClusterIP   10.106.210.154   <none>        1/TCP     36s
   kubernetes          ClusterIP   10.96.0.1        <none>        443/TCP   169d

检查endpoints::

   kubectl get endpoints

显示输出::

   NAME                ENDPOINTS                       AGE
   glusterfs-cluster   192.168.6.15:1,192.168.6.16:1   2m3s
   kubernetes          192.168.6.11:6443               169d

.. note::

   需要注意每个项目都需要唯一的endpoints，每个项目访问GlusterFS卷都需要自己的Endpoints。

- 创建一个持久化卷(presistence volume, pv)

.. literalinclude:: gluster_k8s/gluster-pv.yaml
   :language: yaml
   :linenos:
   :caption:

解析参数:

  - ``name`` 是在pod定义中使用的卷名字
  - ``spec.capacity.storage`` 配置卷容量大小
  - ``accessMode`` 是用于PV和PVC的标签，定义需要相同，不过当前没有定义任何访问控制
  - ``endpoints`` 是前面创建的Endppints
  - ``path`` 定义就是GlusterFS的卷

- 执行创建PV::

   kubectl create -f gluster-pv.yaml

- 创建持久化卷声明(persistent volume claim, PVC): 所谓PVC就是指定访问模式和存储容量，这里PVC绑定到前面创建的PV。一旦PV被绑定到一个PVC，这个PV就被绑定到了这个PVC所属项目，也就不能被绑到其他PVC上。这就是 ``一对一`` 映射PVs和PVCs，不过，在相同项目中的多个Pods可以使用相同PVC。

.. literalinclude:: gluster_k8s/gluster-pvc.yaml
   :language: yaml
   :linenos:
   :caption:

解析参数:

  - ``name`` 是在pod定义的 ``volume`` 段落引用
  - ``accessModes`` 必须和PV的对应一致
  - PVC中 ``spec.resources.requests.storage`` 请求PV提供1G或其他容量

创建PVC::

   kubectl create -f gluster-pvc.yaml

创建完成后检查::

   kubectl get pvc

可以看到PVC已经和PV绑定起来了::

   NAME            STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   gluster-claim   Bound    gluster-pv   1Gi        RWX                           18m

检查PV::

   kubectl get pv

显示状态绑定PVC::

   NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
   gluster-pv   1Gi        RWX            Retain           Bound    default/gluster-claim                           16h

使用Gluster存储
================

我在 :ref:`arm_k8s_deploy` 中部署了3个测试容器 ``kube-verify`` ::

   kubectl -n kube-verify get pods -o wide

显示输出::

   NAME                           READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
   kube-verify-7d4878dfdc-9rv6m   1/1     Running   0          25h   10.244.2.13   pi-worker2   <none>           <none>
   kube-verify-7d4878dfdc-fgc4m   1/1     Running   0          25h   10.244.1.26   pi-worker1   <none>           <none>
   kube-verify-7d4878dfdc-k7sv5   1/1     Running   0          25h   10.244.2.14   pi-worker2   <none>           <none>

对应的 ``kube-verify`` 的deployment:

.. literalinclude:: ../../kubernetes/arm/arm_k8s_deploy/kube_verify_deployment.yaml
   :language: yaml
   :linenos:
   :caption:

修订上述deployment，添加卷挂载:

.. literalinclude:: gluster_k8s/kube_verify_gluster_deployment.yaml
   :language: yaml
   :emphasize-lines: 23-30
   :linenos:
   :caption:

执行deployments修订::

   kubectl apply -f kube_verify_gluster_deployment.yaml

问题排查
===========

找不到PVC
-----------

- 检查使用glusterfs的pod::

   kubectl -n kube-verify get pods

显示新创建的pod容器一致 ``pending`` ::

   NAME                           READY   STATUS    RESTARTS   AGE
   kube-verify-69bddb4868-jfb5p   0/1     Pending   0          22m
   kube-verify-7d4878dfdc-9rv6m   1/1     Running   0          26h
   kube-verify-7d4878dfdc-fgc4m   1/1     Running   0          26h
   kube-verify-7d4878dfdc-k7sv5   1/1     Running   0          26h

- 检查pending容器::

   kubectl -n kube-verify describe pods kube-verify-69bddb4868-jfb5p

显示事件是因为没有找到 ``persistentvolumeclaim "gluster-claim"`` ::

   Events:
     Type     Reason            Age   From               Message
     ----     ------            ----  ----               -------
     Warning  FailedScheduling  23m   default-scheduler  persistentvolumeclaim "gluster-claim" not found 

奇怪，检查PVC明明存在::

   kubectl get pvc

显示::

   NAME            STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   gluster-claim   Bound    gluster-pv   1Gi        RWX                           103m

仔细检查了 ``kubectl -n kube-verify describe pod kube-verify-69bddb4868-jfb5p`` 的输出信息，我注意到有如下内容::

   ...
   Volumes:
     dbdata:
       Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
       ClaimName:  gluster-claim
       ReadOnly:   false
   ...

原来，默认pod是使用自己相同的namespace的PVC，难怪，我创建 ``gluster-claim`` 时候没有指定 namespace ，创建在默认namespace，就和pod不在同一个namespace中。

重新修订 service, endpoint, PV 和 PVC (原先在 default namespace 的 service,endpoint,pv,pvc 需要删除) ，添加上 ``namespace: kube-verify`` 

.. literalinclude:: gluster_k8s/gluster-endpoints_kube-verify.yaml
   :language: yaml
   :linenos:
   :caption:

.. literalinclude:: gluster_k8s/gluster-pv_kube-verify.yaml
   :language: yaml
   :linenos:
   :caption:

.. literalinclude:: gluster_k8s/gluster-pvc_kube-verify.yaml
   :language: yaml
   :linenos:
   :caption:

重建了对应Pod所在namespace的PVC(以及相应的PV,endpoint等)之后，终于能够挂载GlusterFS卷启动Pod了::

   NAME                           READY   STATUS    RESTARTS   AGE
   kube-verify-69bddb4868-7lfw4   1/1     Running   0          17m
   kube-verify-69bddb4868-8pzk7   1/1     Running   0          12m
   kube-verify-69bddb4868-nf5l7   1/1     Running   0          13m

GlusterFS卷权限
------------------

通过以下命令登陆到容器内部::

   kubectl -n kube-verify exec -it kube-verify-69bddb4868-7lfw4 -- /bin/bash

检查挂载::

   df -h

可以看到GlusterFS卷已经挂载成功::

   Filesystem         Size  Used Avail Use% Mounted on
   overlay            953G   25G  890G   3% /
   tmpfs               64M     0   64M   0% /dev
   tmpfs              3.9G     0  3.9G   0% /sys/fs/cgroup
   192.168.6.16:/gv0   32G  6.2G   24G  21% /var/dbdata
   /dev/sda2          953G   25G  890G   3% /etc/hosts
   shm                 64M     0   64M   0% /dev/shm
   tmpfs              3.9G   12K  3.9G   1% /run/secrets/kubernetes.io/serviceaccount
   tmpfs              3.9G     0  3.9G   0% /proc/scsi
   tmpfs              3.9G     0  3.9G   0% /sys/firmware

但是，当你进入到 ``/var/dbdata`` 挂载目录下尝试写入文件::

   bash-5.0$ cd /var/dbdata/
   bash-5.0$ touch test
   touch: cannot touch 'test': Permission denied

无法写入是因为容器默认的用户id没有写入权限::

   bash-5.0$ id
   uid=1001 gid=0(root) groups=0(root)

我们需要根据挂载GlusterFS卷的容器的运行uid/gid修订我们的GlusterFS的PVC



参考
=======

- `High-Availability Storage with GlusterFS on Ubuntu 18.04 LTS <https://www.howtoforge.com/tutorial/high-availability-storage-with-glusterfs-on-ubuntu-1804>`_
- `Gluster Docs: Installing Gluster <https://gluster.readthedocs.io/en/latest/Install-Guide/Install/>`_
- `Kubernetes and GlusterFS <https://ralph.blog.imixs.com/2020/03/03/kubernetes-and-glusterfs/>`_
- `k8s配置GlusterFS存储 <https://my.oschina.net/yx571304/blog/3043065>`_
- `Persistent Storage Using GlusterFS <https://docs.okd.io/1.2/install_config/persistent_storage/persistent_storage_glusterfs.html>`_
