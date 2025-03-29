.. _pi_benchmark:

====================
树莓派性能测试
====================

构想
======

我采用树莓派构建 :ref:`edge_cloud_infra` ，通过构建 :ref:`k3s` 来实现一个边缘计算集群。有一个想法是如何测试树莓派集群性能以及如何优化树莓派性能:

- 通过基准测试获取性能数据，并通过一些软硬件结合方式优化性能:

  - :ref:`pi_overclock`
  - :ref:`usb_boot_ubuntu_pi_4`
  - ...

- 优化 :ref:`k3s` 集群调度，使得应用程序运行平滑，高可用

作为性能测试基准，本文将尝试不断优化 待续 ...

测试工具
=========

- sysbench

参考
=====

- `Raspberry Pi 4, 3A+, Zero W - specs, benchmarks & thermal tests <https://magpi.raspberrypi.com/articles/raspberry-pi-specs-benchmarks>`_
- `Benchmarking the Raspberry Pi 4 <https://medium.com/@ghalfacree/benchmarking-the-raspberry-pi-4-73e5afbcd54b>`_
