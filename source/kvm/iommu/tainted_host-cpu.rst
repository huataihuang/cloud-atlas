.. _tainted_host-cpu:

===============================================
libvirt日志"Domain id=X is tainted: host-cpu"
===============================================

我在部署 :ref:`ovmf` 的IOMMU pass-through PCIe设备的虚拟机之后，发现libvirt日志中有一个比较奇怪的提示::

   2021-11-21 13:30:00.083+0000: Domain id=9 is tainted: host-cpu

但是虚拟机似乎依然能够正常运行，并没有出现 ``terminating`` 现象...

这个 issue 先记录，待排查
