.. _pi_gpu_memory_split:

==========================
树莓派GPU内存分配
==========================

树莓派是一个单板计算机系统(SBC)，着意味着可用内存是在CPU和GPU之间共享的。并且，由于树莓派没有内存插槽，所以也不能扩展内存。这就使得树莓派内存资源非常宝贵，你需要根据实际应用情况合理分配内存: CPU内存分配过少会导致使用swap进而系统性能下降，而GPU内存分配过少会导致桌面环境运行不稳定。

对于树莓派的GPU内存分配(剩余系统内存则分配给CPU)可以从16MB逐级向上调整:

- GPU配置16MB - 对于不运行桌面环境的树莓派操作系统是一个较好的设置，不需要图形功能，只运行终端控制台，这样可以将尽可能多的内存分配给运行程序
- GPU配置64MB - 对于 :ref:`xfce` 这样的轻量级桌面并且只使用一些简单网页浏览(不包括视频)，则可以使用64MB的GPU内存配置
- GPU配置128MB - 对于轻量级桌面并且只处理轻量级文档的办公应用，可以配置128MB的GPU内存，这种配置也可以观看视频
- GPU配置256MB - 对于大多数功能复杂的桌面环境可以配置256MB内存给GPU

配置GPU内存
===============

使用 :ref:`raspi_config` 可以较为方便设置GPU的内存配置量: ``Performance Options >> P2 GPU Memory`` 然后输入内存配置量(单位MB)

:ref:`raspi_config` 会生成 ``/boot/config.txt`` 配置，例如::

   gpu_mem=16

- 修改 ``/boot/usercfg.txt`` (该配置会自动包含到 ``config.txt`` 中生效)添加一行::

   gpu_mem=16

然后重启系统再次观察 ``cat /proc/meminfo`` 

.. note::

   我在 :ref:`pi_1` 上运行 :ref:`alpine_linux` for armhf ，该设置没有生效，让我很疑惑。待后续尝试 :ref:`raspberry_pi_os` 配置

参考
========

- `Manage Raspberry PI GPU Memory Split <https://peppe8o.com/manage-raspberry-pi-gpu-memory-split/>`_
