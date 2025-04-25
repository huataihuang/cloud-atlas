.. _intel_ept_infra:

==================================================
Intel EPT(extended page tables,扩展页表)技术架构
==================================================

.. _slat:

Second Level Address Translation(SLAT)
========================================

二级地址转换(Second Level Address Translation, SLAT)，也称为嵌套分页(nested paging)，是一种硬件辅助虚拟化技术，可以避免与软件管理的影子页表(shadow page tables)相关的开销:

- Intel的SLAT实现称为扩展页表(Extended Page Table, EPT)，在Nehalem微架构引入(2008年)
- AMD的SLAT实现是通过快速虚拟化索引(Rapid Virtualization Indexing, RVI)技术支持(第三代Opteron处理器)
- ARM的虚拟化扩展也支持SLAT，即通过 ``Stage-2`` MMU提供 ``Stage-2`` 页表，guest使用 ``Stage-1`` MMU，SLAT支持是从ARMv7ve架构开始可选配置，并且在ARMv8(32位和64位)架构中支持SLAT 

参考
==========

- `MMU Virtualization Via Intel EPT: Technical Details <https://revers.engineering/mmu-ept-technical-details/>`_
- `5-Level Paging and 5-Level EPT White Paper <https://www.intel.com/content/www/us/en/content-details/671442/5-level-paging-and-5-level-ept-white-paper.html>`_
- `Wikipedia: Second Level Address Translation <https://en.wikipedia.org/wiki/Second_Level_Address_Translation>`_
- `Do Intel® Processors Support Second Level Address Translation (SLAT)? <https://www.intel.com/content/www/us/en/support/articles/000034303/processors.html>`_
- `VMware: Performance Evaluation of Intel EPT Hardware Assist <https://www.vmware.com/pdf/Perf_ESX_Intel-EPT-eval.pdf>`_
