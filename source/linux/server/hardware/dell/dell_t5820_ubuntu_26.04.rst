.. _dell_t5820_ubuntu_26.04:

=============================
Dell T5820安装Ubuntu 26.04
=============================

我在之前 :ref:`dell_t5820_gpu` 采用了第二代 :ref:`dell_t5820_mainboard` 以及 :ref:`amd_mi50_flash_vbios` ，当时采用的是 :ref:`ubuntu_linux` 24.04 版本。本以为一切都已经解决，所以这次重装系统，特意选择了最新的 Ubuntu 26.04，想要获得更好的性能。

然而，我没有想到的是，这次安装非常不顺利，连续出现Installer的crash现象。这里我犯了一个错误: 太依赖AI!!!

crash的时候产生了一个日志 ``/var/crash/1791108399.112869024.install_fail.crash`` ，这个日志文件有8.4M。光看到这么大一个日志，我就没有打开看直接扔给了gemini。没想到gemini给了我一个很肯定的解释 "大容量内存配置导致MTRR 溢出"，建议我设置内核 ``disable_mtrr_cleanup=1`` :

.. literalinclude:: dell_t5820_ubuntu_26.04/crash_log
   :caption: crash日志中包含mtrr_cleanup错误

这个报错确实是一个MTRR错误，表明内核在初始化内存类型范围寄存器(MTRR)时发生了严重错误，导致无法找到最优的内存映射方案(can not find optimal value)

gemini建议我使用 ``disable_mtrr_cleanup=1`` 内核参数来绕过这个问题，但是实际上这是一个引向错误的方法的解决方案。

这个报错实际上是系统启动时日志，实际上被内核忽略并继续进行installer，但是gemini并不知道时间轴，直接匹配了这个错误。这说明其实在故障判断时，如果没有全面的信息输入，极有可能导致概率偏向于很多无关的问题，AI会开始各种假设导致你疲于排查。这个问题确实非常考验使用者的经验，也就是你必须限定和全面把真正相关的信息输入给AI，否则AI会把所有无关的内容引入并越推导越偏离核心原因。

实际上，我自己看了一下日志，非常明显的错误在于Installer会使用地理接近的镜像网站，也就是国内的清华镜像站。但是，镜像站对客户端的IP网段进行防攻击屏蔽，导致了Installer安装时出现报错并crash:

.. literalinclude:: dell_t5820_ubuntu_26.04/downaload_forbit
   :caption: 下载被拒绝

MTRR和PAT
===========

MTRR(Memory Type Range Register,内存类型范围寄存器)和PAT(Page Attribute Table,页属性表)在功能上有相似之处，但是在处理内存的方式上存在差异。PAT目的是取代旧有的MTRR机制，但是由于需要CPU硬件层面的支持，它仅适合较新的硬件平台。

MTRR以有序的方式记录可用内存区域，供应用程序和驱动程序访问，它允许将特定的内存范围额配置为不同属性(如缓存、回写、直写等)，从而提高了计算机执行特定任务的性能。

PAT虽然也利用了类似MTRR的寄存器机制，但是它会构建一张表，在MTRR划定的内存区域内进行更细致的内存分配。因此，MTRR与PAT往往协同工作。

参考
======

- `gentoo linux wiki: MTRR(Memory Type Range Register) and PAT (Page Attribute Table) <https://wiki.gentoo.org/wiki/MTRR_and_PAT>`_
