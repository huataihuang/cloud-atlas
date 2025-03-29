.. _memballoon:

===================
虚拟机内存balloon
===================

.. warning::

   虚拟机内存balloon需要严格的测试和验证，特别是生产环境：

   - libvirt默认开启了memballoon设备，目前我的经验：在Linux guest虚拟机开启memballoon未发现异常，但是Windows虚拟机(32位和64位)发现虚拟机CPU长时间100%并且导致物理服务器Load极高(即使只分配1~2个vcpu也会导致物理主机所有CPU资源耗尽)。
   - memballoon设备不能直接通过 ``virsh edit <dom>`` 删除，但是可以配制成 ``model=none`` 来关闭，关闭后Windows虚拟机伏在恢复正常。

- 异常时 ``dmesg -T`` 显示::

   [Thu Oct 10 09:31:52 2019] perf: interrupt took too long (5038 > 5011), lowering kernel.perf_event_max_sample_rate to 39600
   [Thu Oct 10 09:35:07 2019] perf: interrupt took too long (6877 > 6297), lowering kernel.perf_event_max_sample_rate to 28800
   [Thu Oct 10 09:35:48 2019] perf: interrupt took too long (8949 > 8596), lowering kernel.perf_event_max_sample_rate to 22200
   [Thu Oct 10 09:36:06 2019] mce: CPU3: Package temperature above threshold, cpu clock throttled (total events = 252658)
   [Thu Oct 10 09:36:06 2019] mce: CPU2: Package temperature above threshold, cpu clock throttled (total events = 252658)
   [Thu Oct 10 09:36:06 2019] mce: CPU0: Core temperature above threshold, cpu clock throttled (total events = 171029)
   [Thu Oct 10 09:36:06 2019] mce: CPU1: Core temperature above threshold, cpu clock throttled (total events = 171029)
   [Thu Oct 10 09:36:06 2019] mce: CPU0: Package temperature above threshold, cpu clock throttled (total events = 252658)
   [Thu Oct 10 09:36:06 2019] mce: CPU1: Package temperature above threshold, cpu clock throttled (total events = 252658)

内存ballooning
================

KVM和Xen提供了一个机制能够在Guest运行时修改其使用的内存。这个方式称为内存ballooning，并且这个功能需要Guest操作系统支持才能工作。

virtio balloon设备允许KVM虚拟机降低内存大小(通过放弃内存给host主机)以及增加内存大小(从host主机获取内存)。

这个balloon功能主要是为了支持KVM主机内存的超卖(over-committing memory)。也就是host可以运行所有VM总内存可以大于物理主机实际内存。例如，2G的host主机哦可以运行2个2G内存的VM。

balloon设备对于内存超卖(memory over-commitment)非常重要，因为它可以在需要时降低guest的内存。如果guest需要运行一个消耗更多内存的应用程序，它有可以增加内存。


在 libvirt 中，虚拟机内存分配(以及ballooning能力)是可以通过 ``memory`` , ``currentMemory`` 和 ``memballoon`` 标签来配制的::

   <domain type='kvm'>
     [...]
     <memory unit='KiB'>16777216</memory>
     <currentMemory unit='KiB'>1048576</currentMemory>
     [...]
     <devices>
       <memballoon model='virtio'/>
     </devices>
   </domain>

Guest使用的内存不能超过 ``memory`` 指定值，而且这个值是guest启动时使用的内存量。配制的 ``currentMemory`` 如果设置，则通常小于或等于(默认) ``memory`` 。这样Guest在启动过程中加载了balloon驱动，就会自己修改成 ``currentMemry`` 指定值。而 ``memballoon`` tag是自动加上的，不需要指定它。

使用 ``virsh`` 命令可以检查每个guest使用的内存配制::

   virsh dominfo guest

例如输出::

   Id:             -
   Name:           guest
   UUID:           4f610a1f-7539-47cf-8299-9534500b340d
   OS Type:        hvm
   State:          shut off
   CPU(s):         1
   Max memory:     16777216 kB
   Used memory:    1048576 kB
   Persistent:     yes
   Autostart:      disable
   Managed save:   no

注意，这里 ``memory`` 的值高于使用内存，所以我们能够动态修改Linux guest的分配内存。

注意，当Linux作为guest时候，即使它具备了balloon驱动，并且 ``memory`` 设置值比 ``currentMemroy`` 高，guest操作系统依然不能看到(或使用)多余的那部分内存。这里libvirt报告的 ``Used memory`` 就是guest能够看到和访问的内存。

.. note::

   不过，我在实践中发现Windows虚拟机能够看到所有的 ``memory`` 设置内存。

在Guest虚拟机运行时，可以动态调整具备 ``memballoon`` 的虚拟机内存。

动态调整虚拟机配置
=====================

.. note::

   以下操作步骤在 ``xcloud`` 物理主机上执行，展示如何在虚拟机运行状态下 ``动态调整`` 虚拟机VCPU数量和内存大小。

- 动态调整虚拟机内存 4G::

   virsh setmem devstack 4G

- 动态调整虚拟机VCPU为2个::

   virsh setvcpus devstack 2

.. note::

   动态设置方法可以参考 `动态调整KVM虚拟机内存和vcpu实战 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/startup/in_action/add_remove_vcpu_memory_to_guest_on_fly.md>`_

自动化ballooning
===================

QEMU在2013年还实验性加入了一个自动化ballooning。

当前balloon设备完全是手工操作的。自动化balloon提供了一种在内存负载压力增大情况下自动增加内存配制，以及自动反向收缩的能力。

通过libvirt guest配制可以开启自动化ballooning::

   <memballoon model='virtio'>

增加一个参数 ``autodeflate`` ，该参数默认是 ``off`` ，设置为 ``on`` 就激活了自动ballooning::

   <memballoon model='virtio' autodeflate='on'>

以上是通过libvirt来启用memballoon设备的自动ballooning。如果你没有使用libvirt，也可以手工调用qemu，即需要增加一个 ``,automatic=true`` 来配制balloon设备。例如， ``-device virtio-balloon,automatic=true`` 。

这个自动ballooning需要qemu/kvm 1.3.或更高版本。

参考
========

- `Libvirt文档 - Memory balloon device <https://libvirt.org/formatdomain.html#elementsMemBalloon>`_
- `qemu-kvm reclamation of memory from low-use guests <https://serverfault.com/questions/899760/qemu-kvm-reclamation-of-memory-from-low-use-guests>`_
- `KVM/Xen and libvirt: currentMemory, memory and ballooning. Where did my memory go? <http://www.espenbraastad.no/posts/memory-ballooning/>`_
- `Virtio balloon <https://rwmj.wordpress.com/2010/07/17/virtio-balloon/>`_
