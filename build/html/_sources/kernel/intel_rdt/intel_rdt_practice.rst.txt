.. _intel_rdt_practice:

====================
Intel RDT实践
====================

我们在 :ref:`intel_rdt_arch` 对Intel RDT架构有了初步了解，本文会通过一些实际案例分析和实践来帮助理解理论知识。

在Linux上激活Intel RDT资源管理
===============================

Linux 4.10以上版本内核支持Intel RDT技术，基础架构是基于 ``resctrl`` 文件系统来实现的，提供了一个用户接口。通常系统管理员就是通过这个 ``resctrl`` 用户接口来分配资源，也就是调用内核来配置QoS MSRs以及tasks或CPUs的CLOSIDs。当一个CPU调度任务运行时，这个任务的CLOSID就被加载到PQR MSR作为上下文切换。当任务运行时，通过CLOSID索引当CBM就会指定这个任务能够分配的缓存以及通过一个CLOSID索引的指定延迟值来分配内存带宽。

resctrl文件系统
====================

内核参数 ``CONFIG_INTEL_RDT_A`` 激活RDT支持，并且需要有处理器的 ``/proc/cpuinfo`` 中flag： ``rdt`` , ``cat_l3`` 和 ``cdp_l3``

- 请先 ``cat /proc/cpuinfo`` 查看处理器是否支持上述开关参数::

   cat /proc/cpuinfo | grep flags

例如，在 ``Intel Xeon Platinum 8163 CPU`` 处理器可以看到支持参数 ``rdt_a`` 和 ``cdp_l3``

- 使用以下命令挂载文件系统和支持功能::

   mount -t resctrl resctrl [-o cdp] /sys/fs/resctrl

这里 ``-o cdp`` 挂载选贤是激活 L3 缓存分配的 编码/数据 优先级 (code/data prioritization)

- 挂载了 ``resctrl`` 文件系统后，我们可以观察以下目录结构::

   cd /sys/fs/resctrl
   tree

我们可以看到结构如下::

   .
   ├── cpus
   ├── cpus_list
   ├── info
   │   ├── L3
   │   │   ├── cbm_mask
   │   │   ├── min_cbm_bits
   │   │   ├── num_closids
   │   │   └── shareable_bits
   │   ├── L3_MON
   │   │   ├── max_threshold_occupancy
   │   │   ├── mon_features
   │   │   └── num_rmids
   │   └── MB
   │       ├── bandwidth_gran
   │       ├── delay_linear
   │       ├── min_bandwidth
   │       └── num_closids
   ├── mon_data
   │   ├── mon_L3_00
   │   │   ├── llc_occupancy
   │   │   ├── mbm_local_bytes
   │   │   └── mbm_total_bytes
   │   └── mon_L3_01
   │       ├── llc_occupancy
   │       ├── mbm_local_bytes
   │       └── mbm_total_bytes
   ├── mon_groups
   ├── schemata
   ...
   ├── system-stream
   │   ├── cpus
   │   ├── cpus_list
   │   ├── mon_data
   │   │   ├── mon_L3_00
   │   │   │   ├── llc_occupancy
   │   │   │   ├── mbm_local_bytes
   │   │   │   └── mbm_total_bytes
   │   │   └── mon_L3_01
   │   │       ├── llc_occupancy
   │   │       ├── mbm_local_bytes
   │   │       └── mbm_total_bytes
   │   ├── mon_groups
   │   ├── schemata
   │   └── tasks
   ├── system-agent
   │   ├── cpus
   │   ├── cpus_list
   │   ├── mon_data
   │   │   ├── mon_L3_00
   │   │   │   ├── llc_occupancy
   │   │   │   ├── mbm_local_bytes
   │   │   │   └── mbm_total_bytes
   │   │   └── mon_L3_01
   │   │       ├── llc_occupancy
   │   │       ├── mbm_local_bytes
   │   │       └── mbm_total_bytes
   │   ├── mon_groups
   │   ├── schemata
   │   └── tasks
   ├── system-critical
   │   ├── cpus
   │   ├── cpus_list
   │   ├── mon_data
   │   │   ├── mon_L3_00
   │   │   │   ├── llc_occupancy
   │   │   │   ├── mbm_local_bytes
   │   │   │   └── mbm_total_bytes
   │   │   └── mon_L3_01
   │   │       ├── llc_occupancy
   │   │       ├── mbm_local_bytes
   │   │       └── mbm_total_bytes
   │   ├── mon_groups
   │   ├── schemata
   │   └── tasks
   └── tasks

resctrl目录介绍
===================

info目录
----------

``info`` 目录包含了激活资源的信息，每个资源都有自己的子目录::

   ├── info
   │   ├── L3
   │   │   ├── cbm_mask
   │   │   ├── min_cbm_bits
   │   │   ├── num_closids
   │   │   └── shareable_bits
   │   ├── L3_MON
   │   │   ├── max_threshold_occupancy
   │   │   ├── mon_features
   │   │   └── num_rmids
   │   └── MB
   │       ├── bandwidth_gran
   │       ├── delay_linear
   │       ├── min_bandwidth
   │       └── num_closids

子目录名字反映了资源名字，每个子目录包含了以下文件：

- ``num_closids`` 这个资源的CLOSIDs的数量，内核使用所有激活资源的CLOSIDs的最小数量作为限制::

   #cat num_closids
   16

- ``cbm_mask`` 位掩码(bitmask)校验这个资源，掩码等同100%::

   #cat cbm_mask
   7ff

这里 ``7ff`` 是16进制，转换成二进制就是 ``11111111111``

- ``min_cbm_bits`` 当写入一个掩码时候必须设置的连续位(consecutive bits)的最小值::

   #cat min_cbm_bits 
   1

资源组
--------------

资源组就是对应 ``resctrl`` 文件系统的子目录。默认资源组就是 ``resctrl`` root目录。系统管理员通过 ``mkdir`` 和 ``rmdir`` 命令在这个文件系统中创建子目录来管理资源组。

在每个资源组中有4个文件:

- ``tasks`` : 属于这个资源组的所有任务(进程和线程)，通过将task ID写到这个文件或删除，可以控制任务是否属于这个资源组。当一个任务加入一个资源组，则会自动从之前的资源组中移除。一个通过 ``fork`` 和 ``clone`` 命令创建的任务自动添加到父任务所属资源组。如果一个PID不属于任何资源组(subpartition)，则自动属于root资源组(默认partition)
- ``cpus`` : 使用位掩码(bitmask)来表示属于这个资源组的逻辑CPU，添加到资源组的CPU会自动从之前的资源组中移除。被移除的CPU会添加到默认(root)资源组。你不能从默认资源组移除CPU。注意，这个配置文件中使用16进制bitmask
- ``cpus_list`` : 和 ``cpus`` 是相同作用，用来表示分配到CPU，不过这个文件使用的是十进制
- ``schemata`` : 配置资源组所有资源，每个资源有一行配置和格式

现在我们先来看看默认的根资源组配置::

   #cat cpus
   0000,ffffffff,ffffffff,ffffffff
   
   #cat cpus_list
   0-95
   
   #cat schemata 
       L3:0=7ff;1=7ff
       MB:0=100;1=100

这里可以看到 ``cpus`` 配置中16进制转换成二进制就是 ``96个1`` ，也就是对应服务器的 ``Intel(R) Xeon(R) Platinum 8163 CPU @ 2.50GHz`` 处理器的96个逻辑CPU，实际上和 ``cpus_list`` 配置内容 ``0-95`` 是一样的。

这里 ``schemata`` 配置是默认的配置 ``7ff`` (16进制) 转换成二进制是 ``1111111`` 

对于运行任务的资源分配规则如下：

- 如果任务属于非默认资源组，则使用该组的schemata
- 如果一个任务属于默认资源组，但是它运行在被指定给特定资源组的CPU是，则使用这个CPU的资源组配置的schemata(也就是限制该任务的可用资源)
- 其他情况则使用默认资源组的schemata

schemata文件通用概念
=====================

在 ``schemata`` 文件中每一行描述一个资源。配置行以资源的名字开始，对应的指定值就是作用在这个系统资源的每个会话。

Cache IDs (缓存ID)
--------------------

现在通用Intel系统在每个 socket 包含一个 ``L3`` 缓存，并且每个物理核心(core)的超线程(hyperthreads)共享一个 ``L2`` 缓存。在一个socket中我们可以有多个独立的 ``L3`` 缓存，以及多个物理核心共享一个 ``L2`` 缓存。这种CPU架构决定了一组逻辑CPU如何共享资源，所以就使用 ``Cache ID`` 来表示。在一个给定的缓存层，对于整个系统只使用一个唯一标识的数字(但是不保证数字是连续的)。为了找出每个逻辑CPU的ID，请查看 ``/sys/devices/system/cpu/cpu*/cache/index*/id`` 。

Cache Bit Masks(CBM)
----------------------

对于每个缓存资源，我们使用一个bitmask(位掩码)来描述这个缓存的份额(portion)。对于每个CPU型号(不同的缓存层可能不同)定义了mask的最大值。这个值使用CPUID就可以找到，不过也通过 ``resctrl`` 文件系统的 ``info`` 目录下配置文件 ``info/{resource}/cbm_mask`` 可以查看。举例，我们查看 ``L3`` 缓存::

   cat /sys/fs/resctrl/info/L3/cbm_mask

可以看到输出::

   7ff

上述十六进制 ``7ff`` 转换成二进制就是 11111111111 (11个1) ，这是默认配置，也就是所有缓存的所有部分(都是1)都可以访问

在Intel RDT架构中，使用这些位掩码(bit masks)来在一个相邻块设置 ``1`` 数字。这样十六进制 ``0x3`` (11) ``0x6`` (110） 和 ``0xC`` (1100) 就是表示2位集，而 ``0x5`` (101) ``0x9`` (1001) 和 ``0xA`` (1010) 就不是。在一个使用20位掩码的系统，每一位表示缓存的 ``5%`` 。你可以将缓存划分成相等的4部分，使用以下掩码 ``0x1f`` (11111) , ``0x3e0`` (1111100000) , ``0x7c00`` (111110000000000), ``0xf8000`` (11111000000000000000)

L3缓存详情(关闭了code/data优先级)
-------------------------------------

当CDP禁用时，L3的schemata格式如下::

   L3:<cache_id0>=<'cbm>;<cache_id1>=<cbm>;...
   
L3缓存详情(通过resctrl挂载参数启用了CDP)
------------------------------------------

当激活了CDP时候，L3缓存会划分成2个独立部分::

   L3data:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...
   L3code:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...

L2缓存详情
---------------

L2缓存不支持代码和数据优先级，所以schemata始终如下::

   L2:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...

RDT配置案例
==============

案例1
--------

在使用双socket的主机(每个socket一个L3缓存)，使用4位的缓存位掩码::

   mount -t resctrl resctrl /sys/fs/resctrl
   cd /sys/fs/resctrl
   mkdir p0 p1
   echo "L3:0=3;1=c" > /sys/fs/resctrl/p0/schemata
   echo "L3:0=3;1=3" > /sys/fs/resctrl/p1/schemata

进制转换说明 :

============= ==============
16进制        2进制
============= ==============
3             11
c             1100
============= ==============

默认的资源组没有修改，所以我们可以访问所有缓存的所有部分(也就是在 root 根上的 ``schemata`` 配置值是默认的 ``L3:0=f;1=f`` )

上述修改以后，分配到 ``p0`` 资源组的进程，就只能分配到 cache ID 0的低位50% (3) 和 cache ID 1的高位50% (c) ；而分配到 ``p1`` 资源组的进程，就能够使用两个socket中缓存的低位50% (都是3) 。

.. figure:: ../../_static/kernel/intel_rdt/l3_schemata_1.png
   :scale: 80

参考
=======

- `RESOURCE ALLOCATION IN INTEL® RESOURCE DIRECTOR TECHNOLOGY <https://01.org/group/4685/blogs>`_
- 如果你要进行数字进制转换，可以使用 `在线进制转换工具 <https://www.sojson.com/hexconvert.html>`_
