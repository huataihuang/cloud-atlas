.. _falco_drivers:

==================
Falco事件源驱动
==================

Falco通过事件源驱动(event sources drivers)来了解(taps into)主机系统调用流，并将系统调用传递给用户空间内。

默认驱动是一个称为 ``falco`` 的内核模块，不过，可替代使用 :ref:`ebpf` probe方式

Falco支持3种不同的驱动:

内核模块
---------

在安装Falco软件包时候，默认是安装 ``falco`` 内核模块，也就是通过二进制包提供的 ``falco-driver-loader`` 脚本调用运行，或者运行 ``falcosecurity/falco-driver-loader`` docker镜像

Falco默认尝试使用内核模块驱动

eBPF probe
-------------

eBPF侦测是最新内核支持的功能，可以替代默认的内核模块驱动

用户空间测量
-------------

和上述内核模块和ebpf侦测不同，用户空间内测量是完全在用户空间进行。虽然从Falco 0.24.0 开始就支持用户空间侦测，但是Falco项目没有任何官方支持的用户空间侦测实现。这个用户空间侦测功能基于 ``PTRACE`` ，从文档来看似乎比较复杂，需要小心使用


参考
=======

- `The Falco Project/Event Sources/Falco Drivers <https://falco.org/docs/event-sources/drivers/>`_
- `An Overview of Falco, Inspektor Gadget, Hubble, and Cilium <https://blog.container-solutions.com/ebpf-cloud-native-tools-an-overview-of-falco-inspektor-gadget-hubble-and-cilium>`_
- `Sysdig Hands off eBPF Falco Core to the Cloud Native Computing Foundation <https://thenewstack.io/sysdig-hands-off-ebpf-falco-core-to-the-cloud-native-computing-foundation/>`_
- `Sysdig and Falco now powered by eBPF <https://sysdig.com/blog/sysdig-and-falco-now-powered-by-ebpf/>`_
- `Sysdig contributes Falco’s kernel module, eBPF probe, and libraries to the CNCF <https://sysdig.com/blog/sysdig-contributes-falco-kernel-ebpf-cncf/>`_
