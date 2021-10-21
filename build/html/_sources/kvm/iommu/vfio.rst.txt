.. _vfio:

==============================
VFIO - Virtual Function I/O
==============================

参考
======

- `SUSE Linux Enterprise Server 15 SP1 Virtualization Guide <https://documentation.suse.com/sles/15-SP1/html/SLES-all/book-virt.html>`_
- `Beginner VFIO Tutorial - Part 0: Demo and Hardware <https://www.youtube.com/watch?v=fFz44XivxWI>`_ YouTube 上一个完整的VFIO教程(在Linux虚拟机中玩Windows游戏，对性能有极高要求)，视频解释做得很清晰，并且提供相关资料；链接资料中提供了benchmark，也是我后续准备做的方案
- `How to use seperate hdd as vfio+kvm+qemu vm disk <https://forum.level1techs.com/t/how-to-use-seperate-hdd-as-vfio-kvm-qemu-vm-disk/149623>`_ vfio讨论
- `Disk Passthrough Explained <https://passthroughpo.st/disk-passthrough-explained/>`_ 这篇文档解释了QEMU不同类型虚拟化磁盘技术的差异，简单明了；并且这个 passthroughpo.st 网站汇集了大量vfio资料信息，主要聚焦于虚拟化和linux游戏，最初是从 discord.gg 和 reddit 的VFIO讨论汇总而来
- `Kernel Documentation: VFIO - "Virtual Function I/O" <https://www.kernel.org/doc/Documentation/vfio.txt>`_
- `reddit: VFIO Discussion and Support <https://www.reddit.com/r/VFIO/>`_
- `Introduction to VFIO <https://insujang.github.io/2017-04-27/introduction-to-vfio/>`_
- `The VFIO and GPU Passthrough Beginner’s Resource <https://forum.level1techs.com/t/the-vfio-and-gpu-passthrough-beginners-resource/129897>`_
- `VT-d, vfio and GPU passthrough, Virtualization in a nutshell (RHEL8) <https://blog.sakuragawa.moe/vt-d-vfio-and-gpu-passthrough-virtualization-in-a-nutshell-rhel8/>`_ 这篇是最新在RHEL8上部署GPU passthrough
