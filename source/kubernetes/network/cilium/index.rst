.. _cilium:

======================
Cilium网络
======================

Cilium结合了Envoy实现代理并且使用Kernel的BPF实现数据包过滤和修改，结合实现了网络和安全以及性能分析功能。

.. note::

   性能大师 `Brendan Gregg <http://www.brendangregg.com>`_ 对 `Linux BPF Superpowers <http://www.brendangregg.com/blog/2016-03-05/linux-bpf-superpowers.html>`_ 有详尽指导，并且撰写了 `BPF Performance Tools (book) <http://www.brendangregg.com/bpf-performance-tools-book.html>`_ 。

.. toctree::
   :maxdepth: 1

   intro_cilium.rst
   cilium_startup.rst
   cilium_install_with_external_etcd.rst
