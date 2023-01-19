.. _debug_mobile_cloud_x86_kind_create_fail:

====================================
排查X86移动云Kind创建失败
====================================

.. note::

   我遇到kind创建失败的原因是 :ref:`mobile_cloud_x86_zfs` ，即底层物理主机采用了 :ref:`docker_zfs_driver` 。这要求 ``kind`` 的基础镜像中必须也安装 ``zfsutils-linux`` ，否则处理容器文件系统会出错。这个bug在2022年11月1日才修复，所以需要采用最新的git版本而不是release版本(我部署时候在2023年1月中旬)

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

- 进入 ``dev-control-plane`` 节点进行检查::

   docker exec -it bf960a2f24f5 /bin/bash

可以看到底层容器内部的磁盘挂载::

   # df -h
   Filesystem                                                                   Size  Used Avail Use% Mounted on
   zpool-data/62fd3b4b5c3acb12b91336c2f358d369a5223f2657025f03a8b6b35a22f4d2ef  859G  504M  858G   1% /
   tmpfs                                                                         64M     0   64M   0% /dev
   shm                                                                           64M     0   64M   0% /dev/shm
   zpool-data                                                                   860G  2.1G  858G   1% /var
   tmpfs                                                                        7.8G  454M  7.4G   6% /run
   tmpfs                                                                        7.8G     0  7.8G   0% /tmp
   /dev/nvme0n1p2                                                                60G   27G   33G  45% /usr/lib/modules
   tmpfs                                                                        5.0M     0  5.0M   0% /run/lock

- 检查 ``dev-control-plane`` 节点的 ``journal.log`` 日志可以看到 ``zfs`` 文件系统错误:

.. literalinclude:: kind_multi_node/kind_control_plane_journal.log
   :language: bash
   :caption: kind节点control-plane的journal.log显示容器内部zfs文件系统相关错误(可以看到containerd已经在尝试zfs插件，但是容器中缺少zfs工具)

- 参考 `[zfs] Failed to create cluster #2163 <https://github.com/kubernetes-sigs/kind/issues/2163>`_ 可以看到 2022年11月1日，在ZFS上构建 ``kind`` 的问题修复掉了，解决的方法是 `add zfsutils-linux to base Dockerfile <https://github.com/jrwren/kind/commit/0aeb57ab3bb2291b4d3e4264a13052a67603f6ff>`_

我检查了正在运行的 ``dev-control-plane`` 节点内部，确实没有安装 ``zfs`` 工具，这说明需要采用最新的 ``kind`` 版本

修复zfs
=========

- 我尝试添加镜像参数，指定最新镜像::

   kind create cluster --name dev --config kind-config.yaml --image kindest/node:latest

但是提示错误::

    ✗ Ensuring node image (kindest/node:latest) 🖼
    ERROR: failed to create cluster: failed to pull image "kindest/node:latest": command "docker pull kindest/node:latest" failed with error: exit status 1
    Command Output: Error response from daemon: manifest for kindest/node:latest not found: manifest unknown: manifest unknown

- 由于kind的github仓库已经修复这个问题，所以下载最新的Dockerfile来构建本地镜像，注意，这个构建需要激活 :ref:`buildkit` ，也就是修订 ``/etc/docker/dameon.json`` :

.. literalinclude:: debug_mobile_cloud_x86_kind_create_fail/daemon.json
   :language: json
   :caption: 修改 /etc/docker/daemon.json 添加 buildkit 配置
   :emphasize-lines: 3-5

重启 ``docker`` 服务后，再执行下面的脚本获得最新的Dockerfile，并构建镜像

.. literalinclude:: debug_mobile_cloud_x86_kind_create_fail/build_node_image_by_lastest_dockerfile.sh
   :language: dockerfile
   :caption: 构建包含zfs工具的node镜像

- 重新执行创建集群:

.. literalinclude:: ../../real/mobile_cloud/mobile_cloud_x86/mobile_cloud_x86_kind/kind_create_cluster
   :language: bash
   :caption: kind构建3个管控节点，5个工作节点集群配置，指定自定义镜像(包括zfs工具)

.. note::

   构建镜像时启动的容器内部需要访问 github 下载containerd，但是会被GFW阻断，需要解决容器内部proxy设置 :ref:`docker_client_proxy` :

   - 在墙外服务器上 :ref:`squid_startup` 部署squid

   - 修订 ``~/.ssh/config`` 添加:

   .. literalinclude:: ../../infra_service/ssh/ssh_tunneling/ssh_config_parent-squid
      :language: bash
      :caption: 在 ~/.ssh/config 添加本地端口(真实网卡借口)转发墙外服务器squid端口(loop接口)

   - 然后执行ssh命令打通端口转发:

   .. literalinclude:: ../../infra_service/ssh/ssh_tunneling/ssh_parent-squid
      :language: bash
      :caption: 执行ssh命令打通端口转发

   - 在Docker客户端，创建或配置 ``~/.docker/config.json`` 设置以下json格式配置:

   .. literalinclude:: ../../docker/network/docker_proxy/config.json
      :language: json
      :caption: 配置Docker客户端 ~/.docker/config.json 可以为容器内部注入代理配置

   接下来创建的新容器，容器内部会自动注入代理配置，也就加速下载

新问题: 创建集群不能找到日志行
===============================

上述自定义包含zfs工具的镜像执行创建 ``dev`` 集群又遇到新问题:

.. literalinclude:: debug_mobile_cloud_x86_kind_create_fail/create_kind_not_find_log_line
   :language: bash
   :caption: 使用自定义zfs工具镜像创建dev集群，出现不能找到匹配的log行

这个问题在 `could not find a line that matches "Reached target .*Multi-User System.*" #2460 <https://github.com/kubernetes-sigs/kind/issues/2460>`_ 有人遇到过
