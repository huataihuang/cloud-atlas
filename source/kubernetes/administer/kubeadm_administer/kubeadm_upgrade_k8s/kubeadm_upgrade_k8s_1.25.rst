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

升级K8S集群(1.24.2)至最新补丁版本(1.24.7)
==========================================

- 已经按照上文完成操作系统更新升级
- 将kubernetes仓库配置恢复，并刷新仓库索引::

   mv ~/kubernetes.list /etc/apt/sources.list.d/
   apt update

- 获取所有Kubernetes版本来确定需要升级的版本::

   apt-cache madison kubeadm

可以看到我们将要升级的目标版本::

   kubeadm |  1.25.3-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   ...
   kubeadm |  1.24.7-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   ...

升级管控平面节点
-------------------------

- 控制面节点上的升级过程应该每次处理一个节点
- 选择一个要先行升级的控制面节点: 该节点上必须拥有 ``/etc/kubernetes/admin.conf`` 文件

执行 ``kubeadm upgrade``
-------------------------

**对第一个管控面节点** ``z-k8s-m-1``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 升级 ``kubeadm`` :

.. literalinclude:: kubeadm_upgrade_k8s_1.25/apt_update_kubeadm_1.24.7
   :language: bash
   :caption: 升级节点kubeadm到1.24.7(当前主版本最新补丁版本)

.. note::

   虽然只需要一个管控节点升级 ``kubeadm`` 就能完成整个集群升级，不过为了统一，其他管控节点也做 ``kubeadm`` 版本升级

- 验证 ``kubeadm`` 版本::

   kubeadm version

显示输出::

   kubeadm version: &version.Info{Major:"1", Minor:"24", GitVersion:"v1.24.7", GitCommit:"e6f35974b08862a23e7f4aad8e5d7f7f2de26c15", GitTreeState:"clean", BuildDate:"2022-10-12T10:55:41Z", GoVersion:"go1.18.7", Compiler:"gc", Platform:"linux/amd64"}

- 验证升级计划:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubeadm_upgrade_plan
   :language: bash
   :caption: kubeadm验证升级计划

输出信息如下，其中 ``kube-proxy`` 因为我采用 :ref:`cilium_kubeproxy_free` 所以需要单独升级:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubeadm_upgrade_plan_1.24.7_output
   :language: bash
   :caption: kubeadm验证升级1.24.7计划输出
   :emphasize-lines: 13,14

- 升级第一个管控节点，指定升级的目标版本 ``1.24.7`` :    

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubeadm_upgrade_apply_1.24.7
   :language: bash
   :caption: 升级第一个管控平面节点Kubernetes套件到1.24.7(当前主版本最新补丁版本)

升级输出信息:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubeadm_upgrade_apply_1.24.7_output
   :caption: 升级管控平面节点Kubernetes套件到1.24.7输出信息(含交互)
   :emphasize-lines: 10

- 手动升级CNI驱动插件，如 :ref:`cilium` (这步等后续cilium正式发行新版本后再升级，目前保持不变)

**对其他管控面节点** ``z-k8s-m-2`` 和 ``z-k8s-m-3`` 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 其他管控节点只需要执行 ``upgrade node`` 而不是 ``upgrade apply`` :

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubeadm_upgrade_node_1.24.7
   :language: bash
   :caption: 升级节点Kubernetes套件到1.24.7(upgrade node)

升级输出信息:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubeadm_upgrade_node_1.24.7_output
   :language: bash
   :caption: 其他管控平面节点Kubernetes套件到1.24.7(upgrade node)输出信息

其他管控节点不需要执行 ``kubeadm upgrade plan`` 也不需要更新CNI驱动插件的操作。

腾空管控节点
~~~~~~~~~~~~~

在完成了管控节点的kubernetes镜像升级之后，需要注意，这些管控节点的 ``kubelet`` / ``kubectl`` 还没有升级，所以此时执行 ``kubectl get nodes`` 看到的 ``VERSION`` 还是之前的旧版本 ``1.24.2`` 。在完成了管控平面的组件升级之后，现在可以对管控节点进行 ``kubelet`` / ``kubectl`` 升级:

- 将节点标记为不可调度并驱逐所有负载，准备节点的维护(以下案例是 ``z-k8s-m-1`` 其他管控节点类似)

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_drain_control-plane_1
   :language: bash
   :caption: 管控平面节点腾空节点(不包含daemonset)

提示信息输出:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_drain_control-plane_1_output
   :language: bash
   :caption: 管控平面节点腾空节点(不包含daemonset)输出信息

升级管控节点kubelet和kubectl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 升级 kubelet 和 kubectl:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/apt_upgrade_kubelet_kubectl_1.24.7
   :language: bash
   :caption: 升级管控平面节点kubelet和kubectl到1.24.7

- 重启kubelet:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/systemctl_restart_kubelet_1.24.7
   :language: bash
   :caption: 重启管控平面节点kubelet(1.24.7)

- 将完成升级的管控节点恢复调度并上线(以下案例是 ``z-k8s-m-1`` 其他管控节点类似):

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_uncordon_control-plane_1
   :language: bash
   :caption: 恢复管控平面节点调度并上线

- 现在已经完成了第一个管控节点 ``z-k8s-m-1`` 的升级，此时检查 ``kubectl get nodes`` 可以看到第一个管控节点已经顺利升级到 ``1.24.7`` ::

   kubectl get nodes -o wide

显示输出:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_get_nodes_output_control-plane_1
   :language: bash
   :caption: 第一个管控节点升级完成后检查输出
   :emphasize-lines: 2

**在其余管控节点上重复完成上述 "腾空管控节点" 和 "升级管控节点kubelet和kubectl"**

升级工作节点
-------------------------

在完成了管控节点升级到 ``1.24.7`` 之后，开始升级工作节点。工作节点上的升级过程应该一次执行一个节点，或者一次执行几个节点， 以不影响运行工作负载所需的最小容量。

- 升级 ``kubeadm`` :

.. literalinclude:: kubeadm_upgrade_k8s_1.25/apt_update_kubeadm_1.24.7
   :language: bash
   :caption: 升级节点kubeadm到1.24.7(当前主版本最新补丁版本)

- 执行 ``kubeadm upgrade`` :

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubeadm_upgrade_node_1.24.7
   :language: bash
   :caption: 升级节点Kubernetes套件到1.24.7(upgrade node)

- 将节点标记为不可调度并驱逐所有负载，准备节点的维护(以下案例是 ``z-k8s-n-1`` 工作节点)

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_drain_node_1
   :language: bash
   :caption: 腾空工作节点(不包含daemonset)

提示信息输出可以看到不能驱逐本地存储的pod，这里是 :ref:`cilium` 相关的pod:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_drain_node_1_err_local_storage_output
   :language: bash
   :caption: 腾空工作节点(不包含daemonset)输出信息，这里提示使用本地存储的cilium的pod不能驱逐

修订腾空节点的命令，添加 ``--delete-emptydir-data`` 参数:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_drain_node_1_delete-emptydir-data
   :language: bash
   :caption: 使用--delete-emptydir-data参数腾空工作节点(不包含daemonset)

这里的输出信息中有一些 ``evicting`` 错误:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_drain_node_1_delete-emptydir-data_output
   :language: bash
   :caption: 使用--delete-emptydir-data参数腾空工作节点的输出信息(有evicting错误)

- 同样升级 kubelet 和 kubectl:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/apt_upgrade_kubelet_kubectl_1.24.7
   :language: bash
   :caption: 升级工作节点kubelet和kubectl到1.24.7

- 重启kubelet:

.. literalinclude:: kubeadm_upgrade_k8s_1.25/systemctl_restart_kubelet_1.24.7
   :language: bash
   :caption: 重启工作节点kubelet(1.24.7)

- 将完成升级的工作节点恢复调度并上线(以下案例是 ``z-k8s-n-1`` 其他工作节点类似):

.. literalinclude:: kubeadm_upgrade_k8s_1.25/kubectl_uncordon_node_1
   :language: bash
   :caption: 恢复工作节点调度并上线

所有节点升级完成后，使用 ``kubectl get nodes -o wide`` 检查，可以看到所有节点都统一升级到 ``1.24.7`` 版本::

   NAME        STATUS   ROLES           AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
   z-k8s-m-1   Ready    control-plane   115d   v1.24.7   192.168.6.101   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6
   z-k8s-m-2   Ready    control-plane   113d   v1.24.7   192.168.6.102   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6
   z-k8s-m-3   Ready    control-plane   113d   v1.24.7   192.168.6.103   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6
   z-k8s-n-1   Ready    <none>          113d   v1.24.7   192.168.6.111   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6
   z-k8s-n-2   Ready    <none>          113d   v1.24.7   192.168.6.112   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6
   z-k8s-n-3   Ready    <none>          113d   v1.24.7   192.168.6.113   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6
   z-k8s-n-4   Ready    <none>          113d   v1.24.7   192.168.6.114   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6
   z-k8s-n-5   Ready    <none>          113d   v1.24.7   192.168.6.115   <none>        Ubuntu 22.04.1 LTS   5.15.0-52-generic   containerd://1.6.6

升级K8S集群(1.24.7)至最新release版本(1.25.3)
================================================

**在完成了上述 1.24.2 升级到最新补丁版本 1.24.7 之后，就具备了充分条件可以进一步升级大版本到最新release版本 1.25.3**

升级方法步骤完全相同，只不过目标版本调整为 1.25.3 ，以下记录升级过程

参考
======

- `升级 kubeadm 集群 <https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/>`_
- `How to Upgrade Kubernetes Cluster Using Kubeadm? <https://devopscube.com/upgrade-kubernetes-cluster-kubeadm/>`_
