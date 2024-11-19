.. _fake_numa:

========================
Fake NUMA (伪造NUMA)
========================

在Intel X86系统的服务器领域，我们会使用NUMA来优化程序性能，并且 Kubernetes v1.22 开始默认启用了 :ref:`k8s_numa_arch` 。我最初是通过购买二手 :ref:`hpe_dl360_gen9` 来获得NUMA运行硬件，但是，实际上完全可以通过软件的方式来实现NUMA模拟，并且可以在 :ref:`pi_fake_numa` 环境构建模拟( :ref:`pi_5` 性能会有所提升)。

参考
========

- `Fake NUMA For CPUSets <https://www.kernel.org/doc/html/v5.8/x86/x86_64/fake-numa-for-cpusets.html>`_
