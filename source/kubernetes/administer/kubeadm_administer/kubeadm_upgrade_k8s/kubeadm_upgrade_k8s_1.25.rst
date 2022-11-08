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

升级命令 ``do-release-upgrade`` 会检查根文件系统磁盘空间，如果空间不足会自动终止，所以类似 :ref:`libvirt_lvm_grow_vm_disk` ，也需要扩容虚拟机的根目录系统磁盘。不过，需要注意，Kubernetes集群采用的是 :ref:`clone_vm_rbd` 所以方法改成 :ref:`ceph_extend_rbd_drive_with_libvirt_xfs` :

- RBD调整磁盘大小到16GB ( 1024x16=16384 )，并且 ``virsh blockresize`` 刷新虚拟机磁盘:

.. literalinclude:: ../../../../ceph/rbd/ceph_extend_rbd_drive_with_libvirt_xfs/rbd_resize_virsh_blockresize
   :language: bash
   :caption: rbd resize调整RBD块设备镜像大小, virsh blockresize调整虚拟机vda大小

- 登录到虚拟机内部执行growpart和xfs_growfs调整分区以及文件系统大小:

.. literalinclude:: ../../../../ceph/deploy/install_ceph_manual/ceph_os_upgrade_ubuntu_22.04/vm_growpart_xfs_growfs
   :language: bash
   :caption: 在虚拟机内部使用growpart和xfs_growfs扩展根目录文件系统

- ``do-release-upgrade`` 会检查系统所有软件包版本，由于 ``kubeadm kubectl kubelet`` 被锁定不升级，则会提示::

   Checking for a new Ubuntu release
   Please install all available updates for your release before upgrading.

所以暂时将仓库配置移除，完成OS升级后再恢复继续进行Kubernetes升级::

   mv /etc/apt/sources.list.d/kubernetes.list ~/

- 采用 :ref:`upgrade_ubuntu_20.04_to_22.04` 相同方法升级操作系统:

.. literalinclude:: ../../../../ceph/deploy/install_ceph_manual/ceph_os_upgrade_ubuntu_22.04/ubuntu_release_upgrade
   :language: bash
   :caption: 执行ubuntu release upgrad 

.. note::

   这里一定要确保已经采用了 :ref:`apt_hold` 锁定了主机的Kubernetes相关软件版本，否则升级会导致Kubernetes集群不可预测的异常

.. note::

   建议采用 ``virsh console`` 登录到虚拟机内部执行操作系统升级。通过 ``ssh`` 登录到虚拟机也能进行升级，但是升级过程会断开ssh并且可能无法连接，虽然升级是在 ``screen`` 中进行，所以ssh断开不影响，但是操作比较麻烦，还是要通过 ``virsh console`` 访问虚拟机。

.. note::

   Kubernetes官方提供的Debian系列软件仓库始终是定位在 ``xenial`` ，也就是对应 :ref:`ubuntu_linux` 16.04 LTS 。这应该是为了确保最大可能的兼容性

- 我先完成管控面3台VM升级，然后再执行node节点升级，最终完成后确保所有虚拟机都完成重启，再使用 ``kubectl get nodes`` 检查节点::

   kubectl get nodes -o wide

可以看到输出信息类似::

   NAME        STATUS   ROLES           AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
   z-k8s-m-1   Ready    control-plane   114d   v1.24.2   192.168.6.101   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6
   z-k8s-m-2   Ready    control-plane   112d   v1.24.2   192.168.6.102   <none>        Ubuntu 22.04.1 LTS   5.4.0-131-generic   containerd://1.6.6
   z-k8s-m-3   Ready    control-plane   112d   v1.24.2   192.168.6.103   <none>        Ubuntu 22.04.1 LTS   5.4.0-131-generic   containerd://1.6.6
   z-k8s-n-1   Ready    <none>          112d   v1.24.2   192.168.6.111   <none>        Ubuntu 22.04.1 LTS   5.4.0-131-generic   containerd://1.6.6
   z-k8s-n-2   Ready    <none>          112d   v1.24.2   192.168.6.112   <none>        Ubuntu 22.04.1 LTS   5.4.0-131-generic   containerd://1.6.6
   z-k8s-n-3   Ready    <none>          112d   v1.24.2   192.168.6.113   <none>        Ubuntu 22.04.1 LTS   5.4.0-131-generic   containerd://1.6.6
   z-k8s-n-4   Ready    <none>          112d   v1.24.2   192.168.6.114   <none>        Ubuntu 22.04.1 LTS   5.4.0-131-generic   containerd://1.6.6
   z-k8s-n-5   Ready    <none>          112d   v1.24.2   192.168.6.115   <none>        Ubuntu 22.04.1 LTS   5.4.0-131-generic   containerd://1.6.6

参考
======

- `升级 kubeadm 集群 <https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/>`_
- `How to Upgrade Kubernetes Cluster Using Kubeadm? <https://devopscube.com/upgrade-kubernetes-cluster-kubeadm/>`_
