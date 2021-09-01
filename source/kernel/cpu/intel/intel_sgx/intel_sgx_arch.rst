.. _intel_sgx_arch:

==================================================
Intel Software Guard Extensions(SGX) 技术架构
==================================================

Intel SGX 概览
=================

Intel Software Guard Extensions(Intel SGX)是一种面向应用开发者的Intel技术，适用于寻求保护选定代码和数据免遭泄露或修改。Intel SGX的原理就是在内存中保留强制保护的 ``飞地`` (enclaves)，应用程序代码通过特殊的指令放入一个enclave，并且软件需要使用Intel SGX SDK来进行开发。

.. note::

   历史上 `著名的飞地 <https://zh.wikipedia.org/wiki/%E8%A5%BF%E6%9F%8F%E6%9E%97>`_

Intel SGX SDK是一系列API，库和文档，样例代码和工具的组合，帮助软件开发者创建和调试基于Intel SGX的应用程序，使用C/C++开发。

在一个Intel SGX enclave中运行的应用程序代码：

- 可以获得自第6代Intel Core处理器或更新的平台引入的SGX指令优势(即要使用Intel SGX特性需要Intel第6代Core处理器)
- 通过一个Intel提供的驱动 ``以及/或`` 操作系统来访问Intel SGX指令和资源管理
- 在父级应用程序中执行的上下文，能够得到Intel处理器的全部能力带来的优势
- 降低了可信计算依赖父级应用程序，带来更小的占用空间
- 在BIOS, VMM, OS和驱动受到危害时候依然提供保护，这意味着可以阻止对平台具有完全控制的攻击者
- 通过内存保护阻止内存总线嗅探，内存篡改以及在镜像上"冷启动"攻击残留在内存中
- 通过继承的验证使用基于硬件机制来响应远程攻击挑战
- 可以和其他encalve或者通过父级应用程序一起协作
- 可以使用标准开发工具开发，这样可以降低影响应用开发者

Linux Intel SGX软件堆栈是组合了Intel SGX驱动，Intel SGX SDK和Intel SGX Platform Software。其中Intel SGX SDK和Intel SGX PSW都通过 `Intel linux-sgx项目 <https://github.com/01org/linux-sgx>`_ 提供。

- `SGXDataCenterAttestationPrimitives <https://github.com/intel/SGXDataCenterAttestationPrimitives/>`_  项目维护Linux SGX软件堆栈
- `linux-sgx-driver <https://github.com/01org/linux-sgx-driver>`_ 维护Linux SGX软件堆栈所用的驱动
- `intel-device-plugins-for-kubernetes <https://github.com/intel/intel-device-plugins-for-kubernetes>`_ 项目可以在Kubernetes集群中运行Intel SGX enclaves

Intel SGX安全保护机制
========================

Intel设计的Intel SGX实现了硬件和软件攻击保护(设计蓝图):

硬件保护:

- 

参考
============

- `GitHub linux-sgx <https://github.com/intel/linux-sgx>`_
- `Intel SGX for Linux OS项目 <https://01.org/intel-softwareguard-extensions>`_
- `Intel SGX Software Installation Guide For Linux OS <https://download.01.org/intel-sgx/sgx-linux/2.14/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf>`_
