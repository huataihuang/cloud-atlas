.. _intel_qat_quickstart:

====================================
Intel QuickAssist技术 快速起步
====================================

Intel QuickAssist Technology (英特尔数据保护与压缩加速技术, Intel QAT) 是面向数据中心、云计算的加速 数据加密、数据校验、数据压缩 的技术，适用于各种同步加密、认证，异步加密，数字签名，RSA，DH和ECC以及无损数据压缩场景。

Intel QAT 硬件最初是作为PCIe卡提供，例如我在淘宝上花了50块买了一块 :ref:`intel_qat-8950` ，以及后续的8960、8970。不过，后来QAT硬件被集成到一些intel凌动和至强D处理器。

从第四代Intel至强可扩展处理器开始，QAT技术已经集成到该系列中。所以，后续QAT技术应该主要通过Xeon至强获得，是高端服务器的必备项。

QAT技术概览
==============

`Intel 开源技术01.org QAT技术文档 <https://01.org/intel-quickassist-technology>`_ 提供了技术解析和实施案例，可以作为技术方案参考。

Intel QAT现在在至强可扩展处理器上集成的工作负载加速功能，是专为计算密集型的性能和效率而打造，面向AI、分析、应用程序和内容交付、高速网络等工作负载。QAT从CPU内核分载这些计算密集型操纵，使得CPU能够更高效地执行其他任务，从而提高整体系统性能、效率和能力。

从第四代至强可扩展处理器集成的QAT技术，由于内置于CPU内，可为更多的加密客户端连接和内容交付提供支持(使用场景主要是大量的加密解密和压缩解压缩):

- 云计算厂商使用场景: CDN、负载均衡、网关和微服务
- 企业级存储、数据库和大数据分析
- 边缘计算中使用的VPN、负载均衡、CDN

实践
=======

实践当然需要硬件支持，最好的硬件平台应该是从第四代至强扩扩展处理器，但是对于个人而言成本太高了。我采用 :ref:`xeon_w-2225` 结合廉价的 :ref:`intel_qat-8950` 来实现模拟。

参考
==========

- `Intel® QuickAssist Technology (Intel® QAT) <https://www.intel.com/content/www/us/en/architecture-and-technology/intel-quick-assist-technology-overview.html>`_
- `英特尔® 数据保护与压缩加速技术 <https://www.intel.cn/content/www/cn/zh/architecture-and-technology/intel-quick-assist-technology-overview.html>`_ intel官网中文介绍，能够了解概况
- `英特尔® 数据保护与压缩加速技术是什么 <https://www.intel.cn/content/www/cn/zh/products/docs/accelerator-engines/what-is-intel-qat.html>`_
