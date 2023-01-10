.. _z-k8s_env:

==========================
构建Kubernetes云计算环境
==========================

2021年底，在购买 :ref:`hpe_dl360_gen9` 之后，折腾了2个多月，终于构建了 :ref:`priv_cloud_infra` 基础环境:

- :ref:`priv_kvm` 实现基础KVM虚拟化
- 在 :ref:`zdata_ceph` 上结合 :ref:`zdata_ceph_rbd_libvirt`
- 通过 :ref:`priv_kvm_sr-iov` 为 KVM 虚拟机提供 SR-IOV 虚拟网卡，加速Kubernetes网络性能

上述基础环境构建之后，具备了 :ref:`priv_cloud_infra` 规划中为 ``z-k8s`` 集群准备的虚拟机:

- ``z-k8s-m-1`` ~ ``z-k8s-m-3`` 三台管控服务器
- ``z-k8s-n-1`` ~ ``z-k8s-n-5`` 5台工作节点服务器

  - ``z-k8s-n-1`` / ``z-k8s-n-2`` 注入 :ref:`sr-iov` VF网卡，测试网络性能优化
  - 由于 :ref:`vgpu` 需要license，对个人非常麻烦，所以放弃采用 :ref:`vgpu` 改为采用 :ref: `ovmf_gpu_nvme` : passthrough :ref:`tesla_p10` 到 ``z-k8s-n-1`` 提供GPU运算能力，构建 :ref:`machine_learning` 运行环境
  - ``z-k8s-n-5`` 常规节点

.. csv-table:: z-k8s高可用Kubernetes集群服务器列表
   :file: ../../kubernetes/deploy/bootstrap_kubernetes_ha/prepare_z-k8s/z-k8s_hosts.csv
   :widths: 20, 20, 60
   :header-rows: 1

- 为最大化 :ref:`etcd` 性能，ETCD服务部署在 :ref:`zdata_ceph` 相同的高性能存储虚拟机 ``z-b-data-1`` 到 ``z-b-data-3`` 三台虚拟机中

- 部署 ``z-k8s`` 集群虚拟机如下::

   virsh list

输出列表::

   Id   Name         State
   ----------------------------
   1    z-b-data-1   running
   2    z-b-data-3   running
   3    z-b-data-2   running
   8    z-k8s-m-1    running
   9    z-k8s-m-2    running
   10   z-k8s-m-3    running
   11   z-k8s-n-1    running
   13   z-k8s-n-2    running
   14   z-k8s-n-3    running
   15   z-k8s-n-4    running
   16   z-k8s-n-5    running

:ref:`tesla_p10` passthrough
===============================

- 准备 GPU设备则对应配置 ``tesla_p10.xml`` :

.. literalinclude:: ../../kvm/iommu/ovmf_gpu_nvme/tesla_p10.xml
   :language: xml
   :caption: NVIDIA Tesla P10

- 执行以下命令将NVIDIA Tesla P10 GPU运算卡 添加到虚拟机 ``z-k8s-n-1`` 上:

.. literalinclude:: ../../kvm/iommu/ovmf_gpu_nvme/virsh_attach_gpu
   :language: bash
   :caption: virsh attach-device 添加GPU(vm停机状态)，然后启动虚拟机
