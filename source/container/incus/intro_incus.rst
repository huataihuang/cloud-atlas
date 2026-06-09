.. _intro_incus:

=================
Incus简介
=================

Incus 是一个系统容器、应用容器和虚拟机管理器，是 :ref:`lxd` 的社区fork版本。由于Incus不是Ubuntu管理的社区版本，所以相对LXD而言，更容易被其他发行版如 :ref:`redhat_linux` 和 :ref:`suse_linux` 接受。

Incus提供了类似公有云相似的用户体验: 可以混合使用容器和虚拟机，共享相同的底层存储和网络。

Incus也提供了大量的Linux发行版景象，方便不同的用户环境中使用，并且支持不同的存储后端和网络类型，实现了从笔记本到云实例的硬件兼容支持。

Incus提供了一个简洁的REST API为本地和远程访问实现管理。

.. csv-table:: LXD vs. Incus
   :file: intro_incus/lxd_vs_incus.csv
   :widths: 20,40,40
   :header-rows: 1

Incus自从2023年从 :ref:`lxd` fork出来以后，社区进行了重构，砍掉了臃肿的历史包袱并加入很多新特性:

- **OCI (Docker) 镜像直接运行（Incus 独有）** : Incus 现在支持直接拉取并运行标准的 Docker 镜像（OCI format），而LXD则不支持Docker镜像。
- **底层技术的精简** : 在最新的 Incus 7.0 LTS 中，社区彻底砍掉了落后的 CGroup v1 支持（全面拥抱 v2）以及老旧的 xtables（全面转向 nftables），甚至移除了对外部 MinIO 的依赖，在内部自研了轻量级原生 S3 存储对象接口。这使得 Incus 的内核要求更高，但运行效率和代码极其干净。
- **老旧大厂特性的移除** : Incus 砍掉了 Canonical 特有的一些商业绑定，例如 MAAS（Canonical 的裸机部署工具）集成，以及老旧的 Ubuntu FAN 网络。

"嵌套模拟 Kubernetes（K8s）"场景
==================================

由于 K8s 节点（如 kubelet）需要接管底层的 Cgroup 层次结构，而 Snap 版的 LXD 自身就受到 snapd 施加的独立 Cgroup 和命名空间限制。这很可能导致 ``kubeadm init`` 时出现 ``Permisssion Denied`` 报错。

Incus 是直接运行在宿主机原始命名空间中的 incusd 进程。它对 /sys/fs/cgroup 的控制更加直接、标准。配合 Incus 的 security.nesting=true，容器内的 containerd 能够以几乎 100% 物理机一致的体验去派生 Pod 容器，非常适合做 K8s 的低消耗集群实验。

参考
======

- `INCUS/introduction <https://linuxcontainers.org/incus/introduction/>`_
