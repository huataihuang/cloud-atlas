.. _check_gpu_vram_size:

=======================
检查GPU的VRAM大小
=======================

类似 :ref:`intel_uhd_graphics_630` 这样的CPU集成显卡是可以通过BIOS调整GPU分配的VRAM大小的，这就带来一个问题，如何快速检查当前GPU分配的VRAM大小。

简单来说，就是使用 ``lspci`` 提供的详细信息，并且指定GPU设备，就能够看到VRAM大小:

- 首先查看当前系统的显卡GPU:

.. literalinclude:: check_gpu_vram_size/lspci
   :caption: 检查PCI设备 ``lspci``

输出显示:

.. literalinclude:: check_gpu_vram_size/lspci_output
   :caption: 检查PCI设备 ``lspci`` 显示Intel GPU
   :emphasize-lines: 4

- 然后再次执行 ``lspci`` 但是使用 ``-s`` 参数指定设备，以及 ``-v`` 参数提供详细信息:

.. literalinclude:: check_gpu_vram_size/lspci_gpu
   :caption: 指定设备显示详情

输出显示有256MB:

.. literalinclude:: check_gpu_vram_size/lspci_gpu_output
   :caption: 指定设备显示详情
   :emphasize-lines: 5

参考
=======

- `Linux Find Out Video Card GPU Memory RAM Size Using Command Line <https://www.cyberciti.biz/faq/howto-find-linux-vga-video-card-ram/>`_
