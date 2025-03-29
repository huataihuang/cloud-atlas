.. _intro_likwid:

=========================
LIKWID性能工具简介
=========================

`LIKWID Performance Tools(官网) <https://hpc.fau.de/research/tools/likwid/>`_ 是 ``Like I Knew What I’m Doing`` 的意思，是由 ``埃尔朗根国家高性能计算机中心`` (Erlangen National High Performance Computing Center) 开发的GNU/Linux操作系统命令行性能工具。

LIKWID Performance Tools 使用了现代CPU的 `Hardware performance counter <https://en.wikipedia.org/wiki/Hardware_performance_counter>`_ 来实现性能观测以及benchmark，支持 :ref:`intel_cpu` / :ref:`amd_cpu` 以及 :ref:`arm` CPU的性能观测。

.. note::

   ``埃尔朗根国家高性能计算机中心`` (Erlangen National High Performance Computing Center) 是德国 `埃尔朗根-纽伦堡 弗里德里希·亚历山大大学（简称FAU） <https://www.fau.eu/china/%E4%B8%BA%E4%BD%95%E9%80%89%E6%8B%A9-fau%EF%BC%9F/>`_ 建立的HPC研究机构。在官网 `NHR@FAU <https://hpc.fau.de/>`_ 提供了很多资料和开源工具，例如 `ClusterCockpit <https://www.clustercockpit.org/>`_ 针对HPC的性能监控平台(使用 :ref:`golang` 和 `Svelte <https://svelte.dev/>`_ JS web框架 开发)

.. note::

   在 `YouTube LIKWID Performance Tools (playlist) <https://www.youtube.com/playlist?list=PLxVedhmuwLq2CqJpAABDMbZG8Whi7pKsk>`_ 有一些学习和参考视频，可以用于快速入门

   我准备学习和实践，用于观察不同处理器的性能对比以及性能优化

参考
======

- `LIKWID Performance Tools(官网) <https://hpc.fau.de/research/tools/likwid/>`_
- `Hardware performance counters the easy way: quickstart likwid-perfctr <https://johnnysswlab.com/hardware-performance-counters-the-easy-way-quickstart-likwid-perfctr/>`_
