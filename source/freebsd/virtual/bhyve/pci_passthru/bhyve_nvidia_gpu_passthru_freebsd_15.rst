.. _bhyve_nvidia_gpu_passthru_freebsd_15:

==================================================
FreeBSD 15环境bhyve中实现NVIDIA GPU passthrough
==================================================

我的两次实践 :ref:`bhyve_nvidia_gpu_passthru` :ref:`bhyve_nvidia_gpu_passthru_intpin_patch` 都不太成功，考虑到当前开发的 `bhyve: assign a valid INTPIN to NVIDIA GPUs <https://reviews.freebsd.org/D51892>`_ 补丁是面向FreeBSD 15，并且FreeBSD 15还有2个多月(2025年12月2日)就要发布，我决定再尝试安装FreeBSD 15来验证是否可以支持我的两个 :ref:`tesla_p4` 和 :ref:`tesla_p10` ，如果还存在问题，也方便向社区提交bug。


