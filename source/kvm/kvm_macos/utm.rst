.. _utm:

=================================================
UTM:在Apple Silicon上通过QEMU运行不同硬件架构OS
=================================================

UTM采用Apple的Hypervisor虚拟化框架：

- 可以在Apple Silicon上以接近本机的速度运行ARM64操作系统(可以在macOS中运行macOS)
- 可以在Apple Silicon上使用较低型性能的仿真运行 x86/x64 操作系统
- 可以在Intel Mac上，以虚拟化运行 x86/x64 操作系统
- 可以在Intel Mac上，以虚拟化运行 ARM64 操作系统
- 此外还可以运行任意硬件架构(完全模拟性能较差): ARM32、MIPS、PPC 和 RISC-V

UTM的底层核心是 :ref:`kvm_qemu` 

UTM甚至可以在iOS上运行WindowXP虚拟机...脑洞

参考
=======

- `UTM官网 <https://mac.getutm.app/>`_
