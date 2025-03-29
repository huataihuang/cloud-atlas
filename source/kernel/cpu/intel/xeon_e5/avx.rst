.. _avx:

==================================
AVX(Advanced Vector Extensions)
==================================

AVX(Advanced Vector Extensions) 是x86架构处理器(Intel/AMD)提供的SIMD(Single instruction,multiple data，单指令多数据)扩展。

最早是Intel于2008年3月发布的Sandby Bridge架构，随后AMD于2011年Q4在Bulldozer微架构提供。AVX提供了一个新的功能、新的指令集和新的编码方案。

``AVX2`` 也称为Haswell New Instructions将大多数整数命令扩展为256位并引入了新的指令。AVX2最早是2013年随着Haswell微架构提供支持。

2013年7月Intel又发布了 ``AVX-512`` ，使用了一个新的EVEX prefix编码将AVX扩展为512位，

性能估算
============

FLOPS: 即每秒浮点运算次数, 是每秒所执行的浮点运算次数(Floating-point operations per second)

``FLOAS=核数*单核主频*CPU单个周期浮点计算值``

浮点数有不同的规格:

- FP16（半精度）占用2个字节，共16bit
- FP32（单精度）占用4个字节，共32bit
- FP64（双精度）占用8个字节，共64bit

FP16（半精度）
---------------

- 支持AVX2的处理器在1个核心1个时钟周期可以执行16次浮点运算，也称为16FLOPs::

   CPU的算力=核心的个数 x 核心的频率 x 16FLOPs

- 支持AVX512的处理器在1个核心1个时钟周期可以执行32次浮点运算，也称为32FLOPs::

   CPU的算力=核心的个数 x 核心的频率 x 32FLOPs

CPU的单双精度计算机能力
---------------------------

常用双精度浮点运算能力衡量CPU的科学计算的能力，就是处理64bit小数点浮动数据的能力

支持AVX512指令集，且FMA系数=2，所以CPU每周期算力值::

   CPU单周期双精度浮点计算能力=2（FMA数量）*2(同时加法和乘法)*512/64=32

   CPU单周期单精度浮点计算能力=2（FMA数量）*2(同时加法和乘法)*512/32=64

举例: Intel Xeon Gold 6348 ，28c，2.60 GHz，42MB，235w::

   双精算力=28x2.3（10^9）x（32）/（10^12）=2.3Tflops

   单精算力=28x2.3（10^9）x（64）/（10^12）=4.6Tflops


参考
=====

- `Wikipedia: Advanced Vector Extensions <https://en.wikipedia.org/wiki/Advanced_Vector_Extensions>`_
- `CPU的计算机能力和AVX512指令集 <https://zhuanlan.zhihu.com/p/605920873>`_
- `AVX512 <https://www.cnblogs.com/pam-sh/p/16210114.html>`_ 这篇非常详尽
