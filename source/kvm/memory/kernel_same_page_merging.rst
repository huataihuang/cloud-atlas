.. _kernel_same_page_merging:

==============================================
内存相同页合并(Kernel Same-page Merging, KSM)
==============================================

KVM hypervisor使用内核相同内存页合并(Kernel Same-page Merging, KSM)功能，再不同的KVM guest虚拟机中共享相同内存页。这些共享页面通常是 **公共库** (common libraries) 或者其他相同的高使用率数据。KSM通过避免内存重复来实现更高的虚拟机密度。

共享内存的概念在现代操作系统中非常常见。例如，的那个一个程序第一次启动时，它就和父程序共享它的所有内存。当子程序或父程序试图修改内存时，内核会分配一个新的内存区域，复制原始内容并允许程序修改此新区域。这种技术称为写时复制(copy on write)。

KSM是一个Linux功能，它反向使用了这个概念。KSM使用内核检查两个或者更多的已经运行的程序，并比校它们的内存。如果任何内存区域或者页面相同，则KSM会将多个相同的内存页面减少为一个页面，随后该页面会标记为写时复制。如果内存页面的内容被guest虚拟机修改，则会为该guest创建一个新的页面。

这个功能对于KVM虚拟化非常有用。当guest虚拟机启动时，它只从主机 ``qemu-kvm`` 进程继承内存。guest运行以后，如果guest操作系统相同或者相同的应用程序，则共享guest操作系统影像的内容。KSM允许KVM请求共享这些相同的guest内存区域。

KSM提供增强的内存速度和利用率。使用KSM时，通过将过程数据存储在高速缓存或主内存中，可以减少KVM guest的缓存未命中，从而提高某些应用程序和操作系统的性能。其次，共享内存减少了guest的整体内存使用，从而允许更高的密度和更高的资源利用率。

KSM使用要点
===============

- 在使用KSM时候应避免跨节点内存合并(避免 :ref:`numa` 影响):

设置 ``/sys/kernel/mm/ksm/merge_across_nodes`` 为 ``0`` 可避免跨NUMA节点合并页面

页可以通过 ``virsh node-memory-tune --shm-merge-across-nodes 0`` 完成上述设置

- Red Hat Enterprise Linux 7上，KSM时NUMA aware的，这样它在合并内存页面时会考虑NUMA的局限性，从而防止页面移动到远程节点导致性能下降

- 在大量跨节点合并之后，内核内存记账统计信息可能会互相矛盾，因此在KSM daemon合并大量内存后，numad可能会变混乱

- 如果系统有大量可用内存，则建议不要使用KVM: 关闭和禁用KSM守护进程能够获得更高的性能

- 即使不考虑KSM，也要确保有足够交换大小以用于提交的RAM

KSM配置
=========

Red Hat Enterprise Linux使用两种不同的方式来控制KSM:

- ``ksm`` 服务启动和停止来控制KSM内核线程

- ``ksmtuned`` 服务控制和调整 ``ksm`` 服务，动态管理同一页面合并。 ``ksmtuned`` 启动 ``ksm`` 服务，然后当不再需要内存共享时， ``ksmtuned`` 会停止 ``ksm`` 服务。当新的guest虚拟机创建或销毁， ``ksmtuned`` 必须使用 ``retune`` 来来运行 ``ksmtuned`` 。

KSM服务
------------

Red Hat在 ``qemu-kvm`` 软件包中包含了 ``ksm`` 服务。当 ``ksm`` 没有启动时，KSM(Kernel same-page merging)只共享2000个内存页。这个默认设置只能提供悠闲地内存节约。

当启动 ``ksm`` 服务时，KSM将共享主机系统内存的一半，也就是说启动 ``ksm`` 服务，能够让KSM共享更多内存

.. note::

   我的实践是在 :ref:`apple_silicon_m1_pro` Macbook Pro 2022笔记本上，也就是 :ref:`arch_linux` ARM操作系统上，通过 :ref:`archlinux_aur` 安装::

      yay -S ksmtuned-git

   安装后，系统就增加了 ``ksm`` 和 ``ksmtuned`` 这两个服务，即可进行下一步配置

- 启动 ``ksm`` 服务::

   systemctl start ksm

- 激活 ``ksm`` 服务::

   systemctl enable ksm

KSM Tuning服务
----------------

``ksmtuned`` 服务通过循环和调整 ``ksm`` 来微调内核同页合并(KSM)配置。当创建或销毁guest虚拟机时， ``ksmtuned`` 服务会收到 ``libvirt`` 的通知。 ``ksmtuned`` 服务没有选项。

- 启动 ``ksmtuned`` 和激活::

   systemctl start ksmtuned
   systemctl enable ksmtuned

``ksmtned`` 服务可以使用 ``retune`` 参数来调整，该参数指示 ``ksmtuned`` 手动运行调整功能。


``/etc/ksmtuned.conf`` 文件是 ``ksmtuned`` 服务的配置文集阿，以下时默认的 ``ksmtuned.conf`` :

.. literalinclude:: kernel_same_page_merging/ksmtuned.conf
   :language: bash
   :caption: /etc/ksmtuned.conf 调整 ``ksmtuned`` 服务

在 ``/etc/ksmtuned.conf`` 文件中， ``npages`` 设置 ``ksmd`` 守护进程编程非活动状态之前， ``ksm`` 将扫描多少页。这个值也将在 ``/sys/kernel/mm/ksm/pages_to_scan`` 文件中设置。

``KSM_THRES_CONST`` 值表示用作激活 ``ksm`` 的阀值的可用内存量，如果发生以下任一情况，则 ``ksmd`` 将被激活:

- 可用内存量低于 ``KSM_THRES_CONST`` 中设置的阀值
- 提交的内存量加上阀值 ``KSM_THRES_CONST`` 超过内存总量

在 ``/etc/ksmtuned.conf`` 文件中设置的值对应于系统内核 ``/sys/kernel/mm/ksm/`` 目录下配置文件::

   full_scans
   max_page_sharing
   pages_shared
   pages_sharing
   pages_to_scan
   pages_unshared
   pages_volatile
   run
   sleep_millisecs
   stable_node_chains
   stable_node_chains_prune_millisecs
   stable_node_dups
   use_zero_pages

上述这些值可以使用 ``virsh node-memory-tune`` 命令来调整，例如::

   virsh node-memory-tune --shm-pages-to-scan number

如果 ``/etc/ksmtuned.conf`` 配置了 ``DEBUG=1`` ，则上述调整命令会记录到 ``/var/log/ksmtuned`` 日志文件

关闭KSM
===========

内核同页合并(KSM)的性能开销可能对于某些环境或者主机系统太大了，而且KSM还可能引入侧通道，这些侧通道可能被用来在guest之间泄露信息。所以如果有安全要求，可以针对每个guest禁用KSM。

可以通过停止 ``ksmtuned`` 和 ``ksm`` 服务来停用KSM::

   systemctl stop ksmtuned
   systemctl stop ksm
   systemctl disable ksm
   systemctl disable ksmtuned

当 KSM 被禁用时，在停用 KSM 之前共享的任何内存页面仍然共享。 要删除系统中的所有 PageKSM，请使用以下命令::

   echo 2 >/sys/kernel/mm/ksm/run

此时， ``khugepaged`` 守护进程可以在KVM guest虚拟机的物理内存上重建透明大页。使用::

   echo 0 >/sys/kernel/mm/ksm/run

会停止KSM，但是不会取消共享所有先前创建的 KSM 页面（这与 #systemctl stop ksmtuned 命令相同）。

参考
=======

- `Red Hat Enterprise Linux7 >> Virtualization Tuning and Optimization Guide >> 8.3. Kernel Same-page Merging (KSM) <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_tuning_and_optimization_guide/chap-ksm>`_
