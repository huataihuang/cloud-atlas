.. _intro_bhyve:

======================
bhyve简介
======================

FreeBSD的高性能 :ref:`hypervisor` 名为 ``bhyve`` ，类似于Linux内核的 :ref:`kvm` hypervisor，可以创建和运行虚拟机，性能接近于裸机速度。

最早在2000年后期，NetApp开始在自家基于FreeBSD的存储应用上使用hypervisor运行附加服务。 ``bhyve`` 最初由NetApp的Neel Natu设计和实现，最后由NetApp的一个开发小组完善并发展。到2011年5月，NetApp将代码开源贡献给FreeBSD，至此开始不断发展。

``bhyve`` 是FreeBSD原生的、高性能hypervisor。和 :ref:`kvm` 类似，也是 ``type-1`` hypervisor，能够发挥硬件虚拟化功能以接近原生的性能来运行虚拟机。

``bhyve`` 相比较KVM有如下优势:

- 性能: bhyve 和 kvm 都是高性能hypervisor，不过在特定的负载下有些性能差异: 一些存储高负载测试环境，bhyve模拟的 :ref:`nvme` 控制器显示更强的性能
- 精简: bhyve 的虚拟化堆栈比 :ref:`kvm` / :ref:`qemu` 组合软件栈架构要简洁、资源占用更少

  - KVM虽然和bhyve一样是 ``type-1`` hypervisor，但是KVM只是一个底层内核模块，只能处理核心虚拟化任务(执行硬件加速CPU虚拟化和管理guest内存)，但是不能提供虚拟化硬件设备(网卡、图形卡、磁盘控制器)。这使得KVM不得不依赖QEMU(用户空间应用)来模拟所有的虚拟硬件以满足guest操作系统需求。
  - bhyve则从一开始就聚焦轻量级和紧密集成hypervisor，提供了独特和标准化的高性能virtio驱动，也就是说bhyve是一个完整的hypervisor解决方案，无需结合类似QEMU这样的模拟硬件的软件。

    - 这种集成了virtio规范的Para-virtualized驱动的模式，使得bhyve没有沉重的历史负担(无需像QEMU那样模拟古老的硬件)
    - 最新的virtio规范提供了 ``discarded`` 块功能(类似现代文件系统的TRIM指令用于通知SSD介质某些块不再使用): 这个机制在虚拟环境中，允许guest操作系统通知虚拟机管理程序知晓虚拟磁盘上某些块不再使用，从而使Host主机能够回收底层磁盘的相应空间(底层Host使用UFS和ZFS都可以配置是否以及如何生成TRIM命令)，也提高了SSD支持的虚拟机的性能

``bhybe`` 采用BSD license，从FreeBSD 10.0-RELEASE开始就是base系统的一部分，支持不同的guests系统，包括FreeBSD,OpenBSD, :ref:`linux` 和 :ref:`windows` 。默认是， ``bhyve`` 提供了一个串口控制台但是不会模拟图形控制台。对于新型CPU提供的虚拟化卸载(virtualization offload)可以避免传统的指令转换和人工管理内存映射。

``bhyve`` 硬件要求
===================

- 支持 :ref:`intel_ept` 的 :ref:`intel_cpu`
- 支持 AMD Rapid Virtualization Indexing(RVI)或Nested Page Table(NPT)的 :ref:`amd_cpu`
- 支持 ``Stage-2`` MMU 虚拟化扩展的 ARM ``aarch64`` (例如ARMv8)

注意，FreeBSD的 ``bhyve`` 在ARM上只支持纯ARMv8.0虚拟化，目前尚未使用虚拟化主机扩展(Virtualization Host Extensions)。托管具有多个vCPU的Linux guest或FreeBSD guest需要VMX非限制模式支持(UG)。

最简单判断Intel或AMD处理器是否支持 ``bhyve`` 的简单方法是运行 ``dmesg`` 或在 ``/var/run/dmesg.boot`` 中查找AMD处理器 ``Features2`` 行上的 ``POPCNT`` 处理器功能标志，或者Intel处理器 :ref:`intel_vt` 行上的EPT和UG

.. literalinclude:: intro_bhyve/dmesg_popcnt_ept_ug
   :caption: 检查CPU对POPCNT和EPT和UG支持

例如，我组装了一台 :ref:`xeon_e-2274g` 台式机用来不停机(静音)运行，检查 ``dmesg`` 输出:

.. literalinclude:: intro_bhyve/dmesg_vt
   :caption: 使用 ``dmesg`` 检查CPU是否支持SLAT( :ref:`intel_ept` )
   :emphasize-lines: 12

参考
======

- `FreeBSD handbook: Chapter 24. Virtualization <https://docs.freebsd.org/en/books/handbook/virtualization/>`_
- `bhyve: The FreeBSD Hypervisor <https://klarasystems.com/articles/bhyve-the-freebsd-hypervisor/>`_ 介绍了bhyve诞生的历史渊源，优势以及未来发展
