.. _kubeadm_upgrade_k8s_1.25:

===================================
使用kubeadm升级Kubernetes集群1.25
===================================

准备工作
=========

操作系统升级(可选)
-------------------

.. note::

   操作系统升级其实和Kubernetes升级无关，但是作为 :ref:`priv_cloud_infra` 基础运行环境，我希望能够保持最新的 :ref:`ubuntu_linux` LTS 以充分发挥软硬件性能。类似 :ref:`ceph_os_upgrade_ubuntu_22.04`

- 采用 :ref:`upgrade_ubuntu_20.04_to_22.04` 相同方法升级操作系统:

.. literalinclude:: ../../../../ceph/deploy/install_ceph_manual/ceph_os_upgrade_ubuntu_22.04/ubuntu_release_upgrade
   :language: bash
   :caption: 执行ubuntu release upgrad 

.. note::

   这里一定要确保已经采用了 :ref:`apt_hold` 锁定了主机的Kubernetes相关软件版本，否则升级会导致Kubernetes集群不可预测的异常

这里会遇到一个冲突， ``do-release-upgrade`` 会检查系统所有软件包版本，由于 ``kubeadm kubectl kubelet`` 被锁定不升级，则会提示::

   Checking for a new Ubuntu release
   Please install all available updates for your release before upgrading.

所以暂时将仓库配置移除，完成OS升级后再恢复继续进行Kubernetes升级::

   mv /etc/apt/sources.list.d/kubernetes.list ~/

.. note::

   Kubernetes官方提供的Debian系列软件仓库始终是定位在 ``xenial`` ，也就是对应 :ref:`ubuntu_linux` 16.04 LTS 。这应该是为了确保最大可能的兼容性

升级命令 ``do-release-upgrade`` 会检查根文件系统磁盘空间，如果空间不足会自动终止，所以类似 :ref:`libvirt_lvm_grow_vm_disk` ，也需要扩容虚拟机的根目录系统磁盘。不过，需要注意，Kubernetes集群采用的是 :ref:`clone_vm_rbd` 所以方法改成

参考
======

- `升级 kubeadm 集群 <https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/>`_
- `How to Upgrade Kubernetes Cluster Using Kubeadm? <https://devopscube.com/upgrade-kubernetes-cluster-kubeadm/>`_
