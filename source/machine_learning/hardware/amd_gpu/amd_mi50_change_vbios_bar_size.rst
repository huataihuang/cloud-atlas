.. _amd_mi50_change_vbios_bar_size:

===================================
修订AMD MI50 VBIOS的BAR size
===================================

为了能够在 :ref:`dell_t5820` 上使用 :ref:`amd_mi50` ，我尝试 :ref:`amd_mi50_flash_vbios` 来模拟Workstation Graphics，但是没有成功。进一步怀疑是T5820不支持resize BAR，也就是不能够支持大规格BAR，所以考虑将 :ref:`amd_mi50_flash_vbios` 之后的 V420的VBIOS ，修改BAR size，强制使用 small bar并配合注入的 GOP 来实现一个Workstation Graphics。


