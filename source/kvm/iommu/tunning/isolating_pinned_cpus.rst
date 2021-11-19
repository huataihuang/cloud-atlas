.. _isolating_pinned_cpus:

========================
隔离pinned处理器性能优化
========================

采用 :ref:`iommu_cpu_pinning` 可以提升 :ref:`ovmf` 虚拟机访问PCIe直通设备的性能，但是pinned CPU依然会被Linux调度器调度其它非关键进程，从而影响关键应用性能稳定性。Linux操作系统提供了 ``isolating pinned CPUs`` 能力来解决这个问题。

参考
=====

- `arch linux: PCI passthrough via OVMF >> Isolating pinned CPUs <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Isolating_pinned_CPUs>`_
