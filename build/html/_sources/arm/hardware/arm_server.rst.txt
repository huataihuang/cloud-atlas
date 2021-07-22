.. _arm_server:

===================
ARM服务器
===================

现状
========

- 目前(2020年前后)，ARM 64位服务器性能(2.6~3.0GHz)已经和相同主频Intel服务器相当，处理器核心数量也已经追平(双路处理器共128核心) - 华为TaiShan ARM服务器
- ARM在服务器领域发力，提出了ARM服务器规范:

  - 芯片设计规范SBSA(Server base system Architecture): 规定了芯片需要支持的特性，包括CPU核的特性，中断，时钟以及PCIe特性等
  - OS和firmware的解耦方案：采用UEFI/ACPI，同时支持Linux和Windows (Windows只支持ACPI) ；ACPI 5.1开始逐渐支持ARM服务器平台
  - SBBR(system boot base requirement)规范： 定义UEFI基础要求，ACPI特性支持的基础要求，SMBIOS基础特性要求

- 当前Linux内核主线能够直接使用各个厂商的ARM64服务器芯片
- SUSE/RedHat/Ubuntu等商用发行版直接支持ARM64服务器芯片
- Windows支持Huawei, cavium, 高通等厂家芯片

性能优化
=========

ARM服务器在SMMU(IOMMU)上需要关注I/O性能，据华为反馈可能需要从以下3点关注性能优化:

- SMMU瓶颈: IOVA页表查询，优化SYNC指令，引入Non-strict模式延迟也表释放
- Cache瓶颈：需要对比尝试类似Intel RDT技术，即ARM的类似技术MPAM(Momory partition and monitor)；以及尝试DDIO(Data Direct I/O)
- CPU瓶颈： 将spinlock保护对象修改为RCU保护提升并行能力，Cache false sharing冲突检测，qspinlock

参考
======

- `ARM64服务器Linux内核生态使能-历史与现状 <http://soft.cs.tsinghua.edu.cn/os2atc2018/ppt/osd2.pdf>`_
