.. _my_intel_cpu:

======================
我所使用的Intel CPU
======================

经过多年折腾，目前我还在使用的Intel处理器(主力)如下:

- :ref:`mbp15_late_2013` 的 :ref:`intel_core_i7_4850hq`
- :ref:`hpe_dl380_gen9` 的 :ref:`xeon_e5-2670_v3`
- :ref:`nasse_c246` 组装机的 :ref:`xeon_e-2274g`
- :ref:`dell_t5820` 的 :ref:`xeon_w-2225`

我忽然有些好奇，这些不同时代(Haswell-EP、Coffee Lake-S、Cascade Lake-W)、面向不同工作负载(移动笔记本、双路企业级服务器、工作站/入门服务器、单路高频工作站)的处理器之间有多大差异，以下是一个"无聊"的对比:

.. csv-table:: 我所使用的Intel CPU对比
   :file: my_intel_cpu/cpu_compare.csv
   :widths: 20,20,20,20,20
   :header-rows: 1

上述CPU性能对比的大致概述如下:

- 单核性能（Single-Core）: :ref:`xeon_w-2225` > :ref:`xeon_e-2274g` >>> :ref:`intel_core_i7_4850hq` > :ref:`xeon_e5-2670_v3`

2014年的 :ref:`xeon_e5-2670_v3` 因为Haswell架构极古老，单核性能只有2019年Cascade Lake架构的 :ref:`xeon_w-2225` 1/2多一点，所以在 **编译单个复杂文件、运行 Python/Node.js 单线程脚本、以及进行数据库单连接查询时** 采用 :ref:`xeon_w-2225` 和 :ref:`xeon_e-2274g` 要明显快于 :ref:`hpe_dl380_gen9` 的 :ref:`xeon_e5-2670_v3`

- 多核并发（Multi-Core）: :ref:`xeon_e5-2670_v3` >>> :ref:`xeon_w-2225` > :ref:`xeon_e-2274g` > :ref:`xeon_e5-2670_v3`

当切换到多核并发场景时，面向数据中心服务器的多核 :ref:`xeon_e5-2670_v3` 发挥出了碾压工作站CPU的性能，即使Haswell架构单核性能差，但是合并几十个CPU核心的并发性能，在 **运行数十个 Docker 容器、进行高并发 Gitlab CI/CD 构建、或者开启多台 KVM 虚拟机时** 具有压倒性优势

也就是说，高达 48 线程与夸张的内存/PCIe 扩展能力、支持海量 DDR4 ECC 内存、双路 PCIe 通道数极多 的 :ref:`xeon_e5-2670_v3` :ref:`hpe_dl380_gen9` 最适合模拟云计算的虚拟化、容器化宿主机角色，缺点是功耗极大、噪音巨大，适合极端性能场景。我计划通过 :ref:`ipmi` 带外管理按需运行，来构建裸金属服务器自动部署和运行云计算: 反复演练IDC数据中心摧毁和重建，一键自动部署完整数据中心实现容灾演练。

低功率和静音的 :ref:`nasse_c246` 组装机 ( :ref:`xeon_e-2274g` ) / :ref:`dell_t5820` ( :ref:`xeon_w-2225` )则采用 7x24小时 持续运行，为日常提供 :ref:`llm` 推理, :ref:`ceph` / :ref:`zfs` 存储, :ref:`pgsql` 数据库, :ref:`gitlab` CI/CD服务，并通过 :ref:`kubernetes` / :ref:`openshift` 来实现基础设施服务。 
