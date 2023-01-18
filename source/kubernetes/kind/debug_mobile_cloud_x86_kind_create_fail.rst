.. _debug_mobile_cloud_x86_kind_create_fail:

====================================
排查X86移动云Kind创建失败
====================================

在 :ref:`mobile_cloud_x86_kind` 创建步骤和 :ref:`kind_multi_node` 方法相同，但是执行:

.. literalinclude:: kind_multi_node/kind_create_cluster
   :language: bash
   :caption: kind构建3个管控节点，5个工作节点集群配置

出现如下报错:

.. literalinclude:: debug_mobile_cloud_x86_kind_create_fail/kind_create_cluster_fail_output
   :caption: kind集群启动管控节点超时报错
   :emphasize-lines: 7-9

此外，物理主机的系统日志有大量的 audit 记录，应该和容器内部运行 ``systemd`` 相关(大量重复出现应该是异常):

.. literalinclude:: debug_mobile_cloud_x86_kind_create_fail/dmesg_audit
   :caption: 物理主机dmesg中有大量audit信息和runc相关

排查
========

- 参考 `RROR: failed to create cluster: failed to init node with kubeadm #1437 <https://github.com/kubernetes-sigs/kind/issues/1437>`_ ，在创建kind集群时添加参数 ``--retain`` 获得更详细信息:

.. literalinclude:: kind_multi_node/kind_create_cluster_retain
   :language: bash
   :caption: kind create 参数添加 --retain -v 1 可以获得详细信息

提示信息::

   Exporting logs for cluster "dev" to:
   /tmp/3866643061

在 ``/tmp/3866643061`` 目录下会找到kind集群各个节点的日志文件

- 在 ``/tmp/3866643061/dev-control-plane/kubelet.log`` 日志中看到有CNI初始化失败的信息:

.. literalinclude:: kind_multi_node/kind_control_plane_kubelet.log
   :language: bash
   :caption: kind节点control-plane的kubelet.log日志显示证书签名请求失败

- 实际物理主机上docker容器已经启动::

   docker ps

显示::

   CONTAINER ID   IMAGE                                COMMAND                  CREATED         STATUS         PORTS                       NAMES
   19537801aa08   kindest/node:v1.25.3                 "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes   127.0.0.1:46635->6443/tcp   dev-control-plane2
   75f9a2d8dc9e   kindest/node:v1.25.3                 "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes                               dev-worker3
   bf960a2f24f5   kindest/node:v1.25.3                 "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes   127.0.0.1:37711->6443/tcp   dev-control-plane
   c81440eb69b3   kindest/node:v1.25.3                 "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes                               dev-worker4
   f2f81e25705f   kindest/node:v1.25.3                 "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes                               dev-worker5
   5d52f70acb69   kindest/node:v1.25.3                 "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes                               dev-worker
   acd0de1e4f4d   kindest/node:v1.25.3                 "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes   127.0.0.1:41761->6443/tcp   dev-control-plane3
   8369e5a5e853   kindest/node:v1.25.3                 "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes                               dev-worker2
   f9ac6e6b606a   kindest/haproxy:v20220607-9a4d8d2a   "haproxy -sf 7 -W -d…"   4 minutes ago   Up 4 minutes   127.0.0.1:35931->6443/tcp   dev-external-load-balancer


