.. _linux_jail_nvidia_cuda:

==========================================
在FreeBSD Linux Jail中运行NVIDIA Cuda
==========================================

我一直在想如何能够实现一个 :ref:`freebsd_machine_learning` 环境，结合FreeBSD强大的 :ref:`zfs` 以及坚如磐石的基础，实现通常在Linux环境下的Machine Learning。

我最初想到的是 :ref:`bhyve_pci_passthru` ，毕竟这是非常直觉的想法，通过PCIe Passthrough实现GPU直通给Linux虚拟机，这样就避免了 :ref:`nvidia_gpu` 无法很好在FreeBSD支持的问题(我相像中厂商对FreeBSD硬件驱动支持都比较弱)。不过，现实总是比较残酷，在反复折腾 :ref:`bhyve_nvidia_gpu_passthru` 遇到各种问题，让人非常沮丧: 花费了大量的时间精力，这些时间本应该投入到现今火热一日千里的 :ref:`llm` 实践中。

linux jail思路
===============

`Davinci Resolve installed in Freebsd Jail <https://www.youtube.com/watch?v=zM0gqoseO7k>`_ 提供了一个新的思路:

- 在FreeBSD上安装 ``nvidia-driver linux-nvidia-libs libc6-shim libvdpau-va-gl libva-nvidia-driver`` (实际上和下文 ``linuxulator思路`` 是一致的)
- 配置 :ref:`linux_jail` 在Jail中运行 :ref:`ubuntu_linux`
- 在Ubuntu Linux Jail中运行安装 ``nvidia-driver`` (这里思路有点乱,我不太确定Linux Jail中是否还要安装driver，因为FreeBSD Host上已经安装过driver了) 和 ``nvidia-cuda-toolkit``
- 接下来就可以安装任意依赖NVIDIA CUDA的应用

.. note::

   其实方案的核心都是使用 :ref:`linuxulator` 来实现Linux CUDA运行在FreeBSD ``nvidia-driver`` 上，性能和稳定性会受到一定影响，但是终究还是能够实 :ref:`freebsd_machine_learning` 环境。使用 :ref:`linux_jail` 比直接使用 :ref:`linuxulator` 的环境更干净隔离一些，其他差别不大。

   两种方案各有优势:

   - 采用 :ref:`linuxulator` 对于使用者来说还是直面FreeBSD，使用感受较好，也可以少安装一些环境依赖降低系统复杂度
   - 采用 :ref:`linux_jail` 则提供了隔离且模拟的Linux运行环境，相当于使用了Linux容器(比喻不当)，而且可以在Linux Jail中构建 :ref:`docker` (推测待实践)来部署 :ref:`nvidia_container_toolkit` ，实现一个 :ref:`kubernetes` 计算节点

   我准备两者都实践一下，挑战一下

linuxulator思路
==================

`PyTorch and Stable Diffusion on FreeBSD <https://github.com/verm/freebsd-stable-diffusion>`_ 思路相同，通过结合FreeBSD ``nvidia-driver`` 和 :ref:`linuxulator` 运行Linux版本CUDA来实现一个机器学习环境:

- FreeBSD Host主机安装 ``nvidia-driver`` (NVIDIA公司为FreeBSD提供了原生的驱动，但是没有提供CUDA)
- 安装 `libc6-shim <https://github.com/shkhln/libc6-shim>`_ (会同时依赖安装 ``nvidia-driver`` 和 ``linux-nvidia-libs`` )来获取 ``nvidia-sglrun`` (能够提供CUDA)
- 接下来就可以安装 ``miniconda`` 以及运行 :ref:`pytorch` 和 :ref:`stable_diffusion`

参考
=======

- `Davinci Resolve installed in Freebsd Jail <https://www.youtube.com/watch?v=zM0gqoseO7k>`_ 油管上NapoleonWils0n围绕FreeBSD有不少视频编码解码的解析，其中关于FreeBSD Jail运行Ubuntu来实现NVIDIA CUDA
- `PyTorch and Stable Diffusion on FreeBSD <https://github.com/verm/freebsd-stable-diffusion>`_ 思路相同，通过结合FreeBSD ``nvidia-driver`` 和 :ref:`linuxulator` 运行Linux版本CUDA来实现一个机器学习环境
