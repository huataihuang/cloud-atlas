.. _bhyve_nvidia_gpu_passthru:

===============================================
在bhyve中实现NVIDIA GPU passthrough
===============================================

我在尝试 :ref:`bhyve_pci_passthru_startup` 将 :ref:`tesla_p10` passthrough 给 bhyve 虚拟机，但是遇到无法启动虚拟机的问题，不论是直接使用 ``bhyve`` 命令还是通过 :ref:`vm-bhyve` 管理工具。这个问题困挠了我很久...

`GPU passthrough for bhyve on FreeBSD 14 <https://dflund.se/~getz/Notes/2024/freebsd-gpu/>`_ 解释了为何网上说 "bhyve支持PCI设备passthrough，但是不支持GPU passthru" 是一个误解: 真实原因是NVIDIA驱动仅支持KVM信号的hypervisor，对于bhyve则需要补丁才行。


参考
======

- `GPU passthrough for bhyve on FreeBSD 14 <https://dflund.se/~getz/Notes/2024/freebsd-gpu/>`_
- `bhyve Current state of bhyve Nvidia passthrough? <https://forums.freebsd.org/threads/current-state-of-bhyve-nvidia-passthrough.88244/>`_ 也提示采用 `GPU passthrough for bhyve on FreeBSD 14 <https://dflund.se/~getz/Notes/2024/freebsd-gpu/>`_ 介绍的补丁方法，有人验证在 14.3 上也能工作
- `Nvidia gpu passthru in bhyve <https://www.reddit.com/r/freebsd/comments/1i0pdov/nvidia_gpu_passthru_in_bhyve/>`_ reddit上讨论上述补丁方法
- `bhyve Experience from bhyve (FreeBSD 14.1) GPU passthrough with Windows 10 guest <https://forums.freebsd.org/threads/experience-from-bhyve-freebsd-14-1-gpu-passthrough-with-windows-10-guest.94118/>`_ 经验是使用Intel显卡，似乎不需要patch就可以直接passthru，后续我准备验证测试一下
