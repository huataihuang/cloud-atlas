.. _think_alpine:

=====================
Alpine Liunx思考
=====================

在初次尝试了Alpine Linux之后，我发现这个发行版比较有特色:

- 面向服务器，采用 ``Small, Simple, Secure`` 策略，尽可能减少不必要的软件堆栈和复杂配置，这一方面使得系统更稳定和安全，另一方面也降低了系统开销
- 具有Debian相似的系统包管理 :ref:`alpine_apk` ，方便运维升级

在对比使用了 ``Stand`` 和 ``Extended`` 版本之后，我觉得更应使用 ``Extended`` 版本，主要依据：

- ``Extended`` 版本只使用U盘，启动后整个系统运行在RAM中，所以除了启动稍慢(受限于U盘读写)，启动后在内存中读写文件系统非常快速
- 可以以 ``data`` 模式挂载物理主机的本地磁盘，这样持久化数据不会丢失
- 个人测试 :ref:`studio` 采用 ``Extended`` 版本Alpine Linux，可以快速恢复系统(所有配置和数据采用自己构建的 :ref:`ceph` 和 :ref:`gluster` 保存，本地挂载到映射目录)

- 适合中小型数据中心使用

  - 只需要使用小容量的U盘就可以快速复制大量的alpine系统，即插即用
  - 服务器故障，只需要将U盘换到替换服务器上就可以快速恢复(适合本地无重要数据环境)
  - 重要业务数据采用 :ref:`ceph` 和 :ref:`gluster` 保存( :ref:`real_private_cloud_think` )

优势
=======

Alpine Linux非常轻量级并且得到了Docker很好的支持，所以在构建 :ref:`kubernetes` 上具有巨大的优势: kubernetes是构建在裸机上的采用cgruop/namespace实现的容器调度，没有复杂的虚拟化和paas化，相对较容易实现。在 `How to create a Kubernetes cluster on Alpine Linux <https://dev.to/xphoniex/how-to-create-a-kubernetes-cluster-on-alpine-linux-kcg>`_ 已经有人尝试过，也许采用 `kubernetes-the-hard-way
<https://github.com/kelseyhightower/kubernetes-the-hard-way>`_ 的方式，手工构建一个Kubernetes集群，是可以在alipine上实现的一个途径。

此外，考虑到完全轻量级Kubernetes+Alpine，可以参考 `Install Kubernetes on Alpine Linux with k3s <https://techviewleo.com/install-kubernetes-on-alpine-linux-with-k3s/>`_ 实现一个简化版Kubernetes - 我准备用我古老的 :ref:`pi_3` 来构建一个k3s，实现一个超级小型的 :ref:`gluster` 集群，提供持久化存储。

不足
========

Alpine Linux依然是一个非常小众的发行版，对于大型软件来说，例如 :ref:`openstack` 对于发行版有极大的依赖(多种组合)，所以极难在这样精简的系统上完成。不过，也许是一个技术挑战，可以让你更为理解系统，并且能够彻底掌握系统。

构思
========

我最初准备采用Alpine Linux来构建一个 ``Extended`` 模式，在我的两台笔记本电脑上结合树莓派集群 :ref:`ceph` 和 :ref:`gluster` 来构建 :ref:`openstack` 集群。不过，考虑到OpenStack的复杂性，暂时没有时间精力研究。

所以，我退而求其次，在U盘运行Alpine Linux，构建一个 :ref:`kvm` 虚拟化环境，来运行一个超级小型的测试环境，可以运行 Windows 虚拟机和 Linux虚拟机，随时插入主机进行学习。

至于两台笔记本电脑，还是采用Ubuntu环境来构建OpenStack，学习虚拟化技术。
