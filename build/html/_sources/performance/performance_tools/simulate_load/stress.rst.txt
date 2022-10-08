.. _stress:

===================
stress压力模拟工具
===================

``stress`` 是非常常用的压力工具，安装和使用都非常简便，发行版一般都提供了这个工具::

   # centos/fedora
   sudo yum install stress
   # debian/ubuntu
   sudo apt install stress

- 最简单的cpu测试(按照cpu数量)::

   stress --cpu 4

- 更为完善的测试::

   stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 10s

以上为常用参数:

  - ``--cpu 8`` 并发8个CPU核心压力,不断 ``sqrt()`` 平方根计算
  - ``--io 4`` 并发4个不断 ``sync()``
  - ``--vm 2`` 并发2个不断 ``malloc()/free()``
  - ``--vm-bytes 128M`` 每个内存分配申请大小
  - ``--timeout 10s`` 运行10秒钟

``stress`` 有一个更新版本 ``stress-ng`` 提供了更多压力测试功能:

- CPU compute
- drive stress
- I/O syncs
- Pipe I/O
- cache thrashing
- VM stress
- socket stressing
- process creation and termination
- context switching properties

安装 ``stress-ng`` ::

   sudo apt install stress-ng

检查参数语法::

   sudo stress-ng option argument

使用案例::

   sudo stress-ng --cpu 8 --timeout 60 --metrics-brief

   sudo stress-ng --cpu 4 --cpu-method fft --timeout 2m

   sudo stress-ng --hdd 5 --hdd-ops 100000

   sudo stress-ng --cpu 4 --io 4 --vm 1 --vm-bytes 1G --timeout 60s --metrics-brief

.. note::

   ``stress-ng`` 有待后续实践，目前仅记录备用

参考
=======

- `How to Impose High CPU Load and Stress Test on Linux Using ‘Stress-ng’ Tool <https://www.tecmint.com/linux-cpu-load-stress-test-with-stress-ng-tool/2/>`_ 
