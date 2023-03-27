.. _intro_nvidia_gpudirect_storage:

=================================
NVIDIA GPUDirect Storage技术简介
=================================

GPUDirect Storage支持(GDS)，需要同时安装CUDA软件包和 MLNX_OFED软件包 (需要使用NVMe硬件) ，这样可以在直接内存访问(DMA)方式在GPU内存和存储之间传输数据，不需要经过CPU缓存。这种直接访问路径可以增加系统带宽和降低延迟以及降低CPU负载: 看起来这项技术在大量数据交换时可以提高数据交换性 ，我感觉可以在后续 :ref:`vgpu` 结合 :ref:`gpu_passthrough_with_kvm` ( :ref:`ovmf`  )来尝试这项技术

参考
=====

- `NVIDIA GPUDirect Storage Documentation <https://docs.nvidia.com/gpudirect-storage/index.html>`_
