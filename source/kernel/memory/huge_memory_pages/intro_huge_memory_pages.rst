.. _intro_huge_memory_pages:

==================================
内存大页(huge memory pages)简介
==================================

.. note::

   在 :ref:`kvm` 虚拟化技术中，提高虚拟机性能的有效手段之一就是采用内存大页，但是这项技术的使用有很多特定适用场景，使用不当可能产生 ``负优化`` ，所以需要仔细研究规划并实践验证。

在处理需要大量内存的应用程序，内存延迟可能会成文一个问题，因为使用的内存页越多，则应用程序就越可能跨多个内存页面访问信息。解析内存页的实际地址需要花费多个步骤，所以CPU通常会缓存最近使用的内存页来使得后续访问相同内存页更快。对于使用大量内存的应用，有一个问题，例如使用4GB内存的虚拟机需要将内存切分成104万个4KB内存页，这意味着这种缓存没有命中的概率非常高，导致极大增加了内存延迟。(内存)大页面(huge pages)的存在就是为了给这些应用程序提供更大的独立页面(larger individual
pages)，从而增加多个操作连续针对同一个页面的可能性。

:ref:`transparent_huge_page`
=====================================

:ref:`qemu` 自动使用2MB大小的透明大页(transparent huge pages)，而无需在QEMU或者 :ref:`libvirt` 中显式配置。但是需要注意的是，使用 :ref:`vfio` 时，内存页面在启动时锁定，并且在虚拟机首次启动时预先分配好透明大页。但是，如果内核内存高度碎片化，或者虚拟机正在使用大部分剩余空闲内存，则内存可能没有足够的2MB内存页面来完全满足分配。此时，QEMU会混合使用2MB和4KB内存页。 **由于内存页面在 vfio
模式下被锁定** ，内核就无法在虚拟机启动后再将4KB内存页转换成大页(convert 4KB pages to huge pages)。

例如，我在 :ref:`priv_cloud_infra` 中运行了3个作为底层 :ref:`zdata_ceph` 虚拟机::

   $ virsh list
    Id   Name         State
   ----------------------------
    1    z-b-data-3   running
    2    z-b-data-1   running
    3    z-b-data-2   running

此时我们检查当前整个物理主机上THP(透明大页)的数量:

.. literalinclude:: intro_huge_memory_pages/meminfo_anonhugepages
   :language: bash
   :caption: 通过 /proc/meminfo 获取主机的透明大页分配量

此时看到系统透明大页分配了大约50G::

   AnonHugePages:  50331648 kB

我们来看一下上述3个虚拟机的QEMU实例分配的透明大页大小:

.. literalinclude:: intro_huge_memory_pages/check_vm_anonhugepages
   :language: bash
   :caption: 检查QEMU虚拟机分配的透明大页

此时输出3个虚拟机的内存透明大页大小::

   AnonHugePages:  16777216 kB
   AnonHugePages:  16777216 kB
   AnonHugePages:  16777216 kB

可以看到3个虚拟机所分配的透明大页累加起来就是等于物理主机当前分配的总的透明大页大小( ``50331648=16777216+16777216+16777216`` ) ；通过 ``virsh dominfo <domain_name>`` 可以看到上述虚拟机配置的内存都是 ``16777216 KiB`` ，和这里显示的 ``AnonHugePages`` 大小完全一致。这表明服务器具备充足的连续内存可以分配，完全满足 :ref:`qemu` 对大页内存的分配。也是就是说THP分配有效性在很大程度上取决于虚拟机启动时物理主机的内存碎片。 **如果这种权衡是不可接受或者需要严格的保证，则建议使用 静态大页(static huge
pages)**

静态大页(static huge pages)
=============================

虽然透明大页( :ref:`transparent_huge_page` )在大多数情况下都能够工作，但是也可以在引导期间静态分配。不过这种情况是需要在支持静态大页的机器上使用 ``1GiB`` 大页，因为 **透明大页通常最多只能达到 2MiB** 。

.. warning::

   静态大页会锁定分配的内存，这导致未分配使用静态大页的应用程序无法使用。例如，在具备 8GiB 内存的机器上分配 4GiB 的大页面，则主机上就只剩下 4GiB 的可用内存，即使虚拟机没有运行也是这样。

.. note::

   根据 Red Hat 的基准测试 `Benchmarking transparent versus 1GiB static huge page performance in Linux virtual machines <https://developers.redhat.com/blog/2021/04/27/benchmarking-transparent-versus-1gib-static-huge-page-performance-in-linux-virtual-machines>`_ ，和 :ref:`transparent_huge_page` 相比，静态大页获得的性能提升可能不到 2%

静态大页(static huge pages)配置是在内核参数 ``hugepages=x`` 中指定页面数量，每个页面是默认 ``2048KiB`` ( **2MiB** ) ，所以这里的 ``x`` 如果是 ``1024`` 则表明为虚拟机创建 ``2GiB`` 的内存。

在AMD64和Intel 64架构的CPU上，还支持一种静态大页规格是 **1GiB** ，不过，这需要检查 ``grep pdpe1gb /proc/cpuinfo`` 看是否支持Flag，如果支持，则可以配置内核参数::

   default_hugepagesz=1G hugepagesz=1G hugepages=X

由于静态大页只能由专门请求它的应用程序使用，所以必须在 ``libvirt`` 的虚拟机 ``domain`` 配置中添加允许特定VM使用它::

   $ virsh edit vmname
   ...
   <memoryBacking>
       <hugepages/>
   </memoryBacking>
   ...

动态大页(dynamic huge pages)
==============================

内存大页页可以通过 ``sysctl`` 参数 ``vm.nr_overcommit_hugepages`` 配置，不过 `PCI passthrough via OVMF: Huge memory pages <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages>`_ 原文写得不清晰，我页没有实践。

Red Hat官方的手册 `Configuring HugeTLB Huge Pages <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/sect-red_hat_enterprise_linux-performance_tuning_guide-memory-configuring-huge-pages>`_ 提供了为 :ref:`numa` 配置Huge Pages。

参考
========

- `PCI passthrough via OVMF: Huge memory pages <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages>`_
- `Configuring HugeTLB Huge Pages <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/sect-red_hat_enterprise_linux-performance_tuning_guide-memory-configuring-huge-pages>`_
