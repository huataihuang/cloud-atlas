.. _intro_mig:

========================================
NVIDIA Multi-Instance GPU(MIG) 技术简介
========================================

从 NVIDIA Ampere架构开始，NVIDIA终于开始采用 :ref:`sr-iov` 来实现类似 :ref:`vgpu` 的GPU虚拟化，可以将一块物理GPU划分为 **最多7个** 用于CUDA应用程序的独立GPU示例。这样在云计算环境，能够优化GPU利用率: 对于未完全饱和的GPU计算的工作负载特别有用，可以并行运行不同的工作负载以便最大限度提高利用率。此外，对于多租户的云计算，MIG不仅提供了增强的隔离，还确保一个用户的负载不会影响其他客户。

通过MIG，每个示例的处理器:

- 在整个内存系统中具有独立和隔离的路径: 无干扰的通道和延迟，使用相同的L2缓存分配以及DRAM带宽；即使其他用户的任务破坏了它自己的缓存或导致DRAM接口饱和，也不会影响到你的GPU使用
- MIG可以对可用的GPU计算资源(包括流式多处理器或 SM，以及 GPU 引擎，例如复制引擎或解码器)进行分区，以提供定义的服务质量 (QoS)
- 为不同的客户端(例如VM,容器或进程)提供故障隔离

.. note::

   我发现NVIDIA的MIG技术中缓存隔离和Intel主推的 :ref:`intel_rdt` 有相似之处

NVIDIA的 MIG 适用于Linux操作系统，支持使用 :ref:`docker` 引擎的容器，以及支持Red Hat Virtualization (也就是 :ref:`kvm` )和 VMware vSphere 等管理程序的Kubernetes和虚拟机。

MIG支持以下部署配置:

- 裸机(Bare-metal)，包括容器
- 在支持的 hypervisor上管理GPU Pass-Through 到Linux guest操作系统
- 在支持的 hypervisor上实现 :ref:`vgpu`

.. note::

   这里提到的 ``裸机(Bare-metal)，包括容器`` 让我心里一动:

   - 有没有可能不使用 :ref:`kvm` 虚拟化，而直接在物理主机上运行容器来使用 MIG 虚拟出来的 VF (仔细想了一下，完全没有问题)
   - 其实 :ref:`sr-iov` 在Host物理主机上看到的已经是切分好的VF设备了，也就是说完全不用虚拟化，对物理主机来说也是 7块 GPU 卡，这几乎是和Linux发行版无关的功能，完全可以使用 :ref:`gentoo_linux` 来作为Host操作系统
   - 突然又想到，既然 :ref:`kvm_nested_virtual` 能够在第二层实现虚拟化，那么是不是可以将一块物理网卡 Pass-Through 进第一层KVM虚拟化(第一层虚拟机运行 :ref:`ubuntu_linux` )，然后再在第二层KVM虚拟化(第二层虚拟机也运行 :ref:`ubuntu_linux` )采用 :ref:`vgpu` 。这种方式物理主机上使用什么发行版操作系统(即使是 :ref:`gentoo_linux` )都没有关系

总之，NVIDIA MIG实现了无需 :ref:`vgpu` 这样复杂的虚拟化(还需要 :ref:`install_vgpu_license_server` )，使用Intel主推的业界标准 :ref:`sr-iov` ，方案既简单又高效，也省略了复杂的授权。总之，只要购买了足够高端的GPU卡(目前只有Ampere以上架构的A30, A100, H100)就能获得媲美 :ref:`vgpu` 的GPU虚拟化。除了 **贵和买不到** 以外，几乎没有缺点。

.. figure:: ../../../_static/kvm/iommu/mig/gpu-mig-overview.jpg
   :scale: 50

   NVIDIA Multi-Instance GPU(MIG)

参考
=======

- `NVIDIA Multi-Instance GPU官网 <https://www.nvidia.com/en-us/technologies/multi-instance-gpu/>`_
