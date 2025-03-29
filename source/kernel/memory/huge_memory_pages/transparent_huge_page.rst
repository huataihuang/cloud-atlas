.. _transparent_huge_page:

=====================================
透明大页(transparent huge pages,THP)
=====================================

对于需要处理大量内存的关键性能计算应用程序，可以在 ``libhugetlbfs`` 或 ``hugetlbfs`` 上运行。透明大页(Transparent Hugepage)支持是一种替代方法，能够自动提升和降级页面大小(尽可能分配为大页)来实现大页虚拟内存，同时没有 ``hugetlbfs`` 的缺点。

透明大页目前只适合 **匿名内存映射**  和 ``tmpfs/shmem`` ，但未来会扩展到其他文件系统。

应用程序运行更快的因素有两个:

- 采用2M虚拟内存页的单页错误比采用4KB内存页的单页错误概率低512倍(未命中错误)
- TLB未命中将运行更快(特别是使用嵌套页表进行虚拟化，以及在裸金属物理主机上没有虚拟化的情况)，单个TLB会映射大量的虚拟内存，从而减少TLB未命中次数

只有KVM和Linux guest可以通过虚拟化和嵌套页表来映射更大的TLB，这是因为TLB miss会运行更快。

透明大页设计
==============

- ``优雅地回退`` : 没有透明大页的 ``mm`` 组件感知到需要回退，就会将大型 ``pmd`` 映射分解为 ``ptes`` 表，并且如有必要，拆分成一个透明大页。这些组件可以持续处理常规页面或者常规 ``pte`` 映射
- 如果由于内存碎片导致内存大页分配失败，则常规页面( ``4KiB`` )可以优雅地分配并混入相同的 ``mva`` 而不会有任何故障或重大延迟，也不需要userland通知
- 如果一些任务推出并且有更多的大页可以使用(要么通过伙伴buddy要么通过VM立即完成)，则guest物理内存由常规内存页面重新定位到大页上(使用 ``khugepaged`` )
- 透明大页不需要内存预留(不像静态大页)，只要有可能就使用大页(这里唯一可能保留的是 ``kernelcore=`` 来避免不可移动的页面碎片化，不过这种调整不是针对透明大页的支持，而是通用的适合所有动态高阶内存分配的核心特性)

透明大页可以最大限度利用空闲内存，如果通过允许所有未使用的内存用作缓存。透明大页不需要保留，以避免大页从用户空间看到分配失败。

在某些情况下，使用系统范围的大页会导致应用程序分配更多内存资源: 应用程序会映射一个大区域但是只使用了1个字节内存，此时采用2MB大页分配而不是4K页面是没有收益的。这就是为何在系统范围内禁止使用内存大页，而只是在关键映射区域上使用 ``madvise`` (MADV_HUGEPAGE)

sysfs
========

开启/关闭 透明大页( 默认系统配置 ``madvise`` )
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

可以完全禁用对匿名内存(anonymous memory)启用透明大页支持(主要是调试目的)，或者仅在 ``DADV_HUGEPAGE`` 内部启用区域(以避免消耗更多内存资源的风险)，或者在系统范围启用。具体是通过以下方式 **之一** 实现::

   echo always >/sys/kernel/mm/transparent_hugepage/enabled
   echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
   echo never >/sys/kernel/mm/transparent_hugepage/enabled

.. note::

   ``madvise`` 不是一个常用词汇，在计算机领域中作为专业术语，表示 "内存建议" (ChatGPT)

优化内存碎片整理策略确保生成 ``匿名大页``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在虚拟机中，可以限制碎片整理的影响以便能够生成匿名大页(anonymous hugepages)，这样可以防止内存不立即释放给 ``madvise`` 区域，或者防止系统一直不做内存碎片整理而直接回退到普通页面(除非内存大页立即提供)。

显然，如果花费CPU时间来完成内存碎片整理，我们希望获得更多的内存大页而不是常规内存页。不过这并不总是保证获得内存大页，但在内存分配给一个 ``madvise`` 区域情况下，则很有可能获得大页。

::

   echo always >/sys/kernel/mm/transparent_hugepage/defrag
   echo defer >/sys/kernel/mm/transparent_hugepage/defrag
   echo defer+madvise >/sys/kernel/mm/transparent_hugepage/defrag
   echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
   echo never >/sys/kernel/mm/transparent_hugepage/defrag

.. csv-table:: 针对透明大页的内存碎片整理优化策略
   :file: transparent_huge_page/transparent_hugepage_defrag.csv
   :widths: 30, 70
   :header-rows: 1

大型零页面( ``huge zero page`` )
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

默认情况下，内核会在读取内存页失败是使用大型零页面(huge zero page)来实现匿名映射。通过 ``0`` 禁用 ``huge zero page`` 或者 ``1`` 启用它(默认是 ``1`` )::

   echo 0 >/sys/kernel/mm/transparent_hugepage/use_zero_page
   echo 1 >/sys/kernel/mm/transparent_hugepage/use_zero_page

透明大页大小( ``hpage_pmd_size`` )
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

一些用户空间程序(例如测试程序，或者优化内存分配库)需要知道透明大页的大小(以字节为单位)，则可以通过 ``hpage_pmd_size`` 入口获取::

   cat /sys/kernel/mm/transparent_hugepage/hpage_pmd_size

显示数据默认是 ``2MiB`` ::

   2097152

``khugepaged`` 内核进程
~~~~~~~~~~~~~~~~~~~~~~~~~

- ``transparent_hugepage/enabled`` 激活透明大页的关键开关，通常只需要设置这个值(其他值保持默认):

当 ``/sys/kernel/mm/transparent_hugepage/enabled`` 配置为 ``always`` 或 ``madvise`` ，系统会自动启动 ``khugepaged`` 内核进程；并且在该参数设置为 ``never`` 时自动停止 ``khugepaged`` 。

- ``khugepaged/defrag``

``khugepaged`` 通常以低频率运行，默认启用内存碎片整理(配置值为 ``1`` )。不过，有时候可能不希望在内存页面分配错误期间(during the page faults)同步调用碎片整理算法。可以通过写入 ``0`` 来禁用 ``khugepaged`` 中碎片整理功能，写入 ``1`` 则启用::

   echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
   echo 1 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag

- ``khugepaged/pages_to_scan`` :

此外还能控制 ``khugepaged`` 每次扫描多少内存页::

   cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan

这个每次扫描内存页的默认配置数量是 ``4k`` 数量内存页::

   4096

- ``khugepaged/scan_sleep_millisecs`` :

此外，还可以控制如果出现内存大页分配失败，下一次尝试的间隔毫秒数::

   cat /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs

默认内存大页分配的下次尝试间隔时间是10秒钟(1万毫秒)::

   10000

- ``khugepaged/pages_collapsed`` :

``khugepaged`` 的进度可以在 ``pages collapsed`` (折叠的内存页数量)中看到::

   cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed

这里看到值是::

   0

- ``khugepaged/full_scans`` :

对于每次 pass(我没有理解) ::

   cat /sys/kernel/mm/transparent_hugepage/khugepaged/full_scans

- ``khugepaged/max_ptes_none`` :

``max_ptes_none`` 指定有多少额外的小内存页面(即尚未映射)可以在将一组小页面合并成大页面时分配::

   cat /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none

这个值是::

   511

- ``khugepaged/max_ptes_swap`` :

这个 ``max_ptes_none`` 的值如果较高会导致使用额外的内存；而这个值较低则会导致获得较少的THP性能。 ``max_ptes_none`` 的值可能会浪费很少的CPU时间，可以忽略这个浪费。

``max_ptes_swap`` 指定当将一组内存页折叠成透明大页时可以从 ``swap`` 带入多少页面::

   cat /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap

这个值默认是::

   64

注意， ``max_ptes_swap`` 设置过高会导致较多的 swap IO 以及浪费内存；而 ``max_ptes_swap`` 设置过低可以防止THP折叠，导致更少的内存页被折叠成透明大页(THP)，这也会导致较低的内存访问性能

启动参数
~~~~~~~~~~

通过内核启动参数:

- ``transparent_hugepage=always``
- ``transparent_hugepage=madvise``
- ``transparent_hugepage=never``

可以调整透明大页的 ``sysfs`` 在操作系统启动时的默认参数

``tmpfs/shmem`` 的内存大页
===========================

``/sys/kernel/mm/transparent_hugepage/shmem_enabled`` 控制了是否启用 ``tmpfs/shmem`` 的透明大页功能，通过检查这个入口的参数可以看到默认是 ``never`` ::

   cat /sys/kernel/mm/transparent_hugepage/shmem_enabled

显示默认值如下::

   always within_size advise [never] deny force

应用程序需要重启
===================

在修改了 ``transparent_hugepage/enabled`` 和 ``tmpfs`` 挂载选项之后，需要注意配置修改只影响未来的应用行为，所以要对已经运行的程序生效，必须重启对应程序。

透明大页的使用监控
====================

透明大页的使用监控是通过读取 ``/proc`` 中入口实现：

- ``/proc/meminfo`` 中 ``AnonHugePages`` 字段可以获得系统当前使用的匿名透明大页数量(anonymous transparent huge pages)
- 要识别哪些应用程序正在使用 匿名透明大页( ``anonymous transparent huge pages`` )，需要读取 ``/proc/<PID>/smaps`` 并为每个映射计算 ``AnonHugePages`` 字段
- ``/proc/meminfo`` 中 ``ShmemPmdMapped`` 和 ``ShmemHugePages`` 提供了当前映射到用户空间的文件透明大页(file transparent huge pages)的数量
- 要识别哪些应用程序正在将 文件匿名透明大页( ``file transparent huge pages`` )映射到用户空间，需要读取 ``/proc/<PID>/smaps`` 并为每个映射计算 ``FileHugeMapped`` 字段

.. note::

   读取 ``smaps`` 文件是有昂贵的系统开销

``vmstat`` 计数器
=======================

在 ``/proc/vmstat`` 有很多计数器可以用于监控系统提供内存大页的成功程度

.. note::

   ``/proc/vmstat`` 提供了非常多的内存大页监控项目，我无法一一列举。建议在具体项目实践中根据参考文档来进行具体开发。

.. note::
   
   `Transparent Hugepage Support <https://www.kernel.org/doc/Documentation/vm/transhuge.txt>`_ 有很多有关内核开发的指导性提示

参考
=======

- `Transparent Hugepage Support <https://www.kernel.org/doc/Documentation/vm/transhuge.txt>`_ 这篇内核英文文档感觉好生诘屈聱牙(长句太多了)，简直难以卒读
- `Increase the Performance of VM Workloads by Enabling Transparent Huge Page <https://www.intel.com/content/www/us/en/developer/articles/technical/increase-performance-of-vm-workloads-with-thp.html>`_
- `Configuring Transparent Huge Pages <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/sect-red_hat_enterprise_linux-performance_tuning_guide-configuring_transparent_huge_pages>`_
