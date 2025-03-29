.. _dynamips:

===============
Dynamips模拟器
===============

Dynamips模拟器程序是用于模拟Cisco路由器的软件，运行在FreeBSD, Linux, Mac OS X或Windows上来模拟Cisco系列路由器。它可以直接把真实的Cisco IOS软件镜像加载到模拟器中运行。Dynamips可以模拟Cisco 1700, 2600, 2691, 3600, 3725, 3745, 和 7200。

Dynamips使用大量的内存和CPU拉模拟MIPS处理器，这是因为它需要缓存JIT翻译器，以及用于路由器虚拟内存的内存映射文件(如果内存足够，则关闭虚拟内存 ``mmap = false`` )。此外，由于需要模拟路由器的CPU指令，并且无法知道虚拟机CPU是否idle，所以会消耗大量指令。不过，一旦通过给定IOS镜像的 ``Idle-PC`` 进程，则CPU消耗会急剧减少。

参考
=====

- `Wikipedia: Dynamips <https://en.wikipedia.org/wiki/Dynamips>`_
