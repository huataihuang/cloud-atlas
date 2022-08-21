.. _k8s_volumes:

================
Kubernetes卷
================

在容器环境中，容器内部的数据层( 见 :ref:`docker_storage_driver` )存在以下限制(缺点):

- 通过存储驱动写入的数据(层)读写性能低下
- 容器删除或者奔溃时会导致数据丢失

特别是对于Kubernetes，将为了实现容器调度，更是将上述特性发挥到极致。当Kubernetes调度Pod到不同工作节点，会完全重建Pod，以完全干净的状态重启(重建)。为了使得数据的生命周期超越容器生命周期(容器销毁以后数据依然存在)，Kubernetes也类似 :ref:`docker_volume` 一样引入了卷，并且做了很多增强:

- Kubernetes 支持很多类型的卷
- Kubernetes卷有一个明确的lifetime概念
- Kubernetes卷是在Pod中所有容器所共享的，并且容器重启不影响卷上的数据
- 卷的存在时间会超出 Pod 中运行的所有容器，并且在容器重新启动时数据也会得到保留
- **当Pod停止存在，则卷也停止存在** (卷和持久卷的差异点:卷和Pod共存亡，持久化卷则与"天地同寿"(玩笑))
- 临时卷类型的生命周期与 Pod 相同，但持久卷可以比 Pod 的存活期长
- Pod 可以同时使用任意数目的卷类型

**卷的核心是包含一些数据的一个目录，Pod 中的容器可以访问该目录。**

为了使用一个卷，Pod必须指定哪个卷提供给Pod（通过 ``.spec.volumes`` 字段)以及卷如何挂载到容器中(通过 ``.spec.containers[*].volumeMounts`` 字段)

Docker镜像是文件系统根，而卷则在镜像中挂载到指定目录：

- 卷不能挂载到另一个卷里面
- 卷中不能有硬连接到其他卷
- 每个Pod中容器必须和挂载的任何一个卷都没有依赖关系

Kubernetes卷类型
=================

.. note::

   我只摘录和实践我在学习和生产中所使用的Kubernetes卷，所以本文不会包含所有Kubernetes支持的卷类型。详细信息请参考官方原文 `Kubernetes Types of Volumes <https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes>`_

cephfs
-----------

``cephfs`` 卷是现有的CephFS卷挂载到Pod中。和 ``emptyDir`` 不同， ``emptyDir`` 在Pod销毁的时候消失，而 ``cephfs`` 卷则始终存在，只是卸载了卷。这意味着CephFS可以预先填充数据，并且这些数据可以在不同的Pods之间共享。CephFS可以挂载成被多个写入器并发写入。

.. note::

   这里cephfs可以并发写入我还不理解原理，有待实践...

   官方有一个 `CephFS example <https://github.com/kubernetes/examples/tree/master/volumes/cephfs/>`_

cinder
----------

.. note::

   cinder 是 :ref:`openstack` 的对象存储，对于Kubernetes需要基于 OpenStack Cloud Provider配置，请参考 :ref:`cloud_providers` 中OpenStack部分。

configMap卷
-------------

``configMap`` 资源提供了一种将配置数据插入Pod的方法。存储在一个 ``ConfigMap`` 对象中的数据可以被引用为类型 ``configMap`` 的卷，然后被容器化应用在Pod中使用。

当引用一个 ``configMap`` 对象，你可以简单提供在卷中的它的名字来引用。可以可以定制自定义路径来用于ConfigMap中特定入口。例如，要挂载 ``log-config`` ConfigMap 到名为 ``configmap-pod`` 的Pod，可以配置YAML如下::

   apiVersion: v1
   kind: Pod
   metadata:
     name: configmap-pod
   spec:
     containers:
       - name: test
         image: busybox
         volumeMounts:
           - name: config-vol
             mountPath: /etc/config
     volumes:
       - name: config-vol
         configMap:
           name: log-config
           items:
             - key: log_level
               path: log_level

这里 ``log-config`` ConfigMap被挂载成一个卷，所有的存储这个ConfigMap中的 ``log_level`` 入口被挂载到 Pod 的内部路径 ``/etc/config/log_level`` 。注意，这里路径是从volume的 ``mountPath`` 中获得的，并且这个路径的关键字是 ``log_level`` 。

也就是说，先定义了一个 ``/etc/config`` 的外部目录，这个卷目录被命名为 ``config-vol`` 卷 。然后配置这个卷 ``config-vol`` ，设置它的入口，也就是 ``/etc/config`` 目录的子目录 ``log_level`` 被命名为 ``log-config`` （请注意其属于 ``configMap`` ，所以是子目录映射），这个子目录（入口） ``log_level`` 被挂载到容器内部对应的 ``/etc/config/log_level`` 。

.. note::

   似乎 ConfigMap 在容器内外是完全一一对应的？只要指定 ``mountPath`` ，则该目录下子目录如果设定 ``configMap`` 就会从容器外映射到容器内部。

hostPath
----------

``hostPath`` 卷用于将主机节点文件系统上的文件或目录挂载到Pod中。使用 ``hostPath`` 的局限性在于：如果你要保证调度的pod不错乱(例如访问到不同节点的相同命名的hostPath卷)，你需要在 PodTemplate 中设置 ``spec.nodeSelector`` 来指定服务器分配pod，这样通常可以避免错乱::

   apiVersion: apps/v1beta1
   kind: Deployment
   metadata:
     name: helloworldanilhostpath
   spec:
     replicas: 1
     template:
       metadata:
         labels:
           run: helloworldanilhostpath
       spec:
         nodeSelector:
           kubernetes.io/hostname: aks-nodepool1-39499429-1
         volumes:
           - name: task-pv-storage
             hostPath:
               path: /home/openapianil/samplePV
               type: Directory
         containers:
         - name: helloworldv1
           image: ***/helloworldv1:v1
           ports:
           - containerPort: 9123
           volumeMounts:
            - name: task-pv-storage
              mountPath: /mnt/sample

由于 ``hostPath`` 限制较多，所以通常只用于所有node节点都一致都目录映射，并且应用可以自己避免数据错乱的场景。所以，通常使用本地存储会采用 ``local`` 持久化卷。

local
------

``local`` 卷特点:

- ``local`` 卷带包某个被挂载的本地存储设备，例如磁盘、分区或目录。
- ``local`` 卷只能用作静态创建的持久卷，尚不支持动态配置

``local`` 卷适合以下工作场景:

- 缓存数据用来加速数据处理
- 分布式存储系统：在多个节点上分片或复制数据的存储集群。例如分部署数据库 Cassandra 或者分布式文件系统 Gluster 和 Ceph。

.. note::

   ``hostPath`` 卷只支持文件和目录挂载，用于提供pod访问host中的文件和目录。

   ``local`` 卷表示的是本地被挂载的存储 **块** 设备(dev)，即本地磁盘或者分区到Pod内部

   最大的不同是Kubernetes调度器知道 ``local`` 持久化卷属于那个节点；而 ``hostPath`` 卷可能会被调度器移动到另外一个节点而导致数据丢失。

   我的理解：

   - ``hostPath`` 就是pod的一个文件或目录映射，调度器不固定记录它属于那个节点，所以会任意调度到某个节点再挂载 ``hostPath`` ，而每个节点本地目录和文件是不同的，所以数据会不一致
   - ``local`` 卷是跟着node节点的，scheduler会记录 ``local`` 卷属于那个节点，不会任意调度pod，并且确保下次使用这个 ``local`` 卷的pod依然调度到这个节点上。

   通常我们持久化应用要使用 ``local`` 卷，只有所有服务器一致的配置文件(目录)才可以作为 ``hostPath`` 挂载到pod内部。



参考
======

- `Kubernetes文档/概念/存储/卷 <https://kubernetes.io/zh/docs/concepts/storage/volumes/>`_
- `Kubernetes 1.14: Local Persistent Volumes GA <https://kubernetes.io/blog/2019/04/04/kubernetes-1.14-local-persistent-volumes-ga/>`_ 的 "How is it different from a HostPath Volume?"
