.. _kvm_memory_overcommit:

======================================
KVM虚拟化内存超卖(Memory Overcommit)
======================================

我在实践 :ref:`mobile_cloud_infra` 时，遇到一个困难:

- 笔记本，即使是硬件配置极高的 :ref:`apple_silicon_m1_pro` Macbook Pro 2022笔记本，依然只有32G内存: 当部署运行了基于 :ref:`ceph` 分布式存储的虚拟机集群，运行超过8个虚拟机，同时大负载运行(例如VM操作系统并发升级)，就会不断出现OOM kill现象
- 我最初初步估算为虚拟机分配了如下内存:

  - 底层虚拟机3台，每个内存6G，理论占用18G内存
  - 上层虚拟机5台，每个内存3G，理论占用15G内存

- 虽然不一定会出现同时消耗内存，但是实践发现运行了图形界面情况下(开启浏览器特别消耗内存)，则根本不够支持同时运行上述8个虚拟机(理论内存分配 33G)

我参考 :ref:`kvm_memory_tunning` ，想要在有限的硬件资源下依然能够运行 :ref:`mobile_cloud_infra` 多虚拟机模拟集群，则需要做一定的内存调整

内存优化方案
================

首先，根据实践，底层虚拟机3台中的 ``a-b-data-1`` 运行了最多的ceph服务，已经出现过内存完全占满导致oom kill掉 :ref:`qemu` 进程。也就是说，需要对内存进行一些调整。我尝试将6G内存缩减为5G，这样3个底层虚拟机将最多只消耗15G内存。加上雷诺国外5个上层虚拟机也是15G，共计理论分配30G内存，勉强能够塞在 :ref:`apple_silicon_m1_pro` Macbook Pro 2022笔记本 32G内存中。

其次，结合采用 :ref:`kvm_memory_tunning` 方案构建内存超卖配置

Kernel Same-page Merging(KSM)
-------------------------------

:ref:`redhat_linux` 企业版6/7提供了内存超卖技术支持 Kernel same-page Merging(KSM)，这项技术需要配置服务。我在 :ref:`kernel_same_page_merging` 中提供实践参考。

Swap on ZRAM
---------------

Fedora 33开始默认提供了 :ref:`swap_on_zram` 配置，并且在后续版本中做了细微优化调整，我的 :ref:`mobile_cloud_infra` 参考Fedora官方资料进行优化，即在 :ref:`swap_on_zram` 提供实践参考。

Memory Ballooning
--------------------

:ref:`memory_ballooning` 技术可以实现Guest和hypervisor之间协作来节约内存，具体实践请见 :ref:`memory_ballooning` 笔记。

参考
========

- `Overcommitting with KVM <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/chap-overcommitting_with_kvm>`_
- `Configuring Swap on ZRAM <https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-configure-swaponzram/>`_

