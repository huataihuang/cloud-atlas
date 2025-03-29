.. _perfmance_arm_x86:

=========================
ARM和X86架构性能对比构想
=========================

随着ARM逐步进入服务器领域，性能优化始终是一个需要重点研究的方向。我的想法是:

- 通过通用的bench工具，例如sysbench来对比两者的性能

  - ARM和Intel的服务器版本对比

- 在性能对比过程中采用perf/bpf等工具进行分析

- 编写一些功能单一的压测程序进行单项性能测试，借此了解如何通过代码优化来扬长避短

参考
======

- `Performance Analysis for Arm vs x86 CPUs in the Cloud <https://www.infoq.com/articles/arm-vs-x86-cloud-performance/>`_
