.. _intel_core_i5_2410m:

============================
Intel Core i5-2410M处理器
============================

在我的模拟云计算环境中，主要使用 :ref:`intel_core_i7_4850hq` 的 :ref:`ubuntu_on_mbp` 来模拟大规模的云计算环境。同时，采用 :ref:`ubuntu_on_thinkpad_x220` 作为辅助环境，运行 Docker 和 Kubernetes 分担一部分计算负载。

ThinkPad X220的处理器是 `Intel® Core™ i5-2410M Processor <https://ark.intel.com/content/www/us/en/ark/products/52224/intel-core-i5-2410m-processor-3m-cache-up-to-2-90-ghz.html>`_ ，主要特性有:

- 支持基本的Intel虚拟化技术VT-x(包括EPT)，但是不支持直接I/O的虚拟化技术(VT-d)
- 属于 `Sandy Bridge <https://ark.intel.com/content/www/us/en/ark/products/codename/29900/sandy-bridge.html>`_ 体系架构

由于Sandy Bridge体系架构支持的硬件虚拟化特性有限，所以这台笔记本将较少使用KVM技术，主要考虑采用容器/Kubernetes技术来运行应用。
