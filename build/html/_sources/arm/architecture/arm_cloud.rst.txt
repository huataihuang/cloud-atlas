.. _arm_cloud:

==============
ARM云计算
==============

好些年前，那时候XEN虚拟化还是主流的技术，容器化技术还只有LXC( :ref:`docker` 此时尚未诞生  )，我和基础设施事业部的同事瞎聊，谈到云计算和数据中心。我提到如果我来构建数据中心，我将使用Mac mini(二手)来构建:

- 通用的Intel硬件，可以完美运行KVM虚拟化
- 尺寸高度在1U以内，能够在1U机架上铺设多台服务器构建成一个分布式集群
- 虽然单机性能有限，但是通过海量的服务器分布式计算，单位机架密度上的Mac mini堆积的计算能力、存储能力不会弱于常规的基于志强处理器Dell/HP机架服务器
- 通过更多的服务器来实现硬件冗灾，即使桌面级的硬件，也可以实现超越数据中心服务器的可靠性

.. note::

   在Mac设备上运行Linux实际上也就不得不舍弃了macOS无比优秀的软硬件一体的优势，难以体验精美绝伦的macOS的魅力。不过，对于云计算技术，Linux和Windows是服务器领域的主流，在Mac mini上运行KVM可以完美支持Linux和Windows。

ARM容器技术
============

在ARM上运行的Linux，本身是完美支持容器技术(cgroup,namespace,overlayfs)，所以在ARM架构上，运行Docker/Kubernetes，和Intel架构没有太大差异。

我准备在 :ref:`jetson` 和 :ref:`pi_4` 硬件上构建Kubernetes集群，实现分布式存储、分布式计算以及各种基础架构。

ARM虚拟化
=========

`QEMU的Features/KVM <https://wiki.qemu.org/Features/KVM>`_ 是支持 `AArch64 virtualization <https://developer.arm.com/documentation/100942/0100/AArch64-virtualization?lang=en>`_ 。不过，一直以来生产实践都采用Intel体系架构，我还没有了解过具体的ARM架构的虚拟化，有待进一步学习和研究。
