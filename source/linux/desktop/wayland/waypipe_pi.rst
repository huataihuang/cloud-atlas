.. _waypipe_pi:

=========================
树莓派运行waypipe
=========================

在 :ref:`alpine_sway_mba11_late_2010` 最大的痛点是 :ref:`mba11_late_2010` 硬件性能太弱，导致浏览器很难访问现代网站。我想到我在 :ref:`mobile_work` 曾经考虑过采用 :ref:`pi_5` ，那么作为较为现代的处理器架构，其性能已经是孱弱的 ``Core 2 Due`` 数倍，结合waypipe，那么就能补充 :ref:`mba11_late_2010` 无法运行现代JS的缺陷:

- 算力对比( :ref:`pi_5` vs :ref:`mba11_late_2010` ):

  - **CPU 性能** ：树莓派 5 搭载的 Broadcom BCM2712（四核 Cortex-A76 @ 2.4GHz）的单核性能大幅超越 2010 款的 Core 2 Duo SL9400/SL9600，多核性能更是数倍碾压。
  - **内存与现代特性** ：树莓派 5 拥有 4GB/8GB LPDDR4X 内存，且天然支持现代浏览器复杂的 JavaScript 引擎（如 V8/Gemini 网页端）和现代 Web API。

- Waypipe 的传输优势:

  - 传统的 VNC/RDP 是“全屏图像编码压缩传输”，极其消耗 CPU 资源且延迟高。
  - Waypipe 作用于 Wayland 协议层，它只拦截 Wayland client(树莓派上的 Chromium)和 Compositor(MacBook Air 上的 Sway/Wayland)之间的 ``Shared Memory Buffers`` (共享内存缓冲区)。
  - 对于网页这种"局部重绘"居多的场景，Waypipe 的网络带宽占用和传输延迟远低于 VNC，操作跟手度极高。

.. literalinclude:: waypipe_pi/waypipe_infra
   :caption: waypipe 架构链路

安装
=======

在两端安装 ``waypipe`` 和 ``openssh`` :

- MacBook Air (Sway 终端):

.. literalinclude:: waypipe_pi/alpine_install
   :caption: MacBook Air安装

- 树莓派 5 (Raspberry Pi 5):

.. literalinclude:: waypipe_pi/pi_install
   :caption: 树莓派5安装

运行
=========

- 在 MacBook Air 的 Sway 终端中，直接运行以下 ``waypipe`` 结合 :ref:`ssh` 的命令:

.. literalinclude:: waypipe_pi/waypipe_ssh
   :caption: 结合waypipe和ssh

参数说明:

  - ``--compress lz4`` : 启用极为轻量、极低延迟的 LZ4 压缩算法
  - ``--ozone-platform=wayland`` : 强制树莓派上的 Chromium 以原生 Wayland 模式渲染，这是 Waypipe 能正常工作的关键

运行要点
---------

- 硬件加速(GPU)

  - **Waypipe 传输的是软件 Buffer 或经过导出/导入的 DMA-BUF** 如果遇到 Chromium 页面黑屏或卡顿，就需要在启动 Chromium 的命令行中加上禁用 GPU 硬件合成的选项(完全依靠 :ref:`pi_5` 的4核A76软解): ``--disable-gpu``

- 字体与 DPI 统一

  - 运行在树莓派 5 上的 Chromium 窗口会直接呈现为 Sway 里的一个普通原生窗口，可以像对待本地软件一样使用
  - 如果网页文字偏小，可以调节 Chromium 的默认缩放: ``--force-device-scale-factor=1.2``

- USB 单线通(USB Cable Connection) - **理论上，但实际有限制条件**

  - 配置 :ref:`pi_5` ``/boot/firmware/config.txt`` 开启 ``dtoverlay=dwc2`` 将树莓派的 USB Type-C 端口同时作为 **供电和虚拟 USB 网卡**
  - 只需要用一根 USB 线把树莓派 5 插在 MacBook Air 的 USB 口上，既完成了供电，又建立了千兆级的虚拟直连局域网

但是这个方案的限制是 :ref:`pi_5` 极其苛刻变态的电源要求，功率要求是 ``5V5A`` 25W，这是普通电脑的USB接口很难稳定提供的，至少目前我还没有成功在电脑USB接口上稳定为 :ref:`pi_5` 成功供电。

可能的方案是采用: 

  - 支持 PD 协议的充电宝（或 PD 快充头）接入带有“PD 供电 + 数据分离”功能的 USB-C 双头拓展线/分线器 (未实践)
  - 使用树莓派 5 专属的 PoE+ HAT / 外部 GPIO 5V 5A 供电模块，这样树莓派 5 的 USB Type-C 接口通过普通的 USB-A 转 C 线插入 MacBook Air 2010 的 USB 口，此时该接口仅走 USB Ethernet (RNDIS/CDC-ECM) 

.. note::

   :ref:`mba11_late_2010` 提供的是 USB 2.0接口，标准USB 2.0规范输出仅 5V/0.5A (2.5W)。即便 Apple 针对某些外设提供了有限的额外电流扩展，最高通常也不过 5V / 1.1A，即 ~5.5W。

   树莓派 5 仅在系统刚启动、未接复杂外设时，待机功耗就在 2.7W ~ 3.5W 左右；一旦启动 Chromium 进行 Web 页面渲染，峰值功耗会迅速飙升至 6W ~ 12W+。

异常排查
==============

vulkan驱动
-------------

我在执行:

.. literalinclude:: waypipe_pi/waypipe_ssh
   :caption: 结合waypipe和ssh

遇到如下报错

.. literalinclude:: waypipe_pi/waypipe_ssh_error
   :caption: Macbook Air运行waypipe报错

注意，这里报错明确指出了 ``waypipe-client`` ，也就是说 :ref:`mba11_late_2010` 客户端不支持 Vulkan 驱动。这也很正常，这个古老的 **NVIDIA GeForce 320M** 显卡仅支持到 OpenGL 3.3/OpenCL **硬件上根本不支持Vulkan** ，所以当Waypipe试图加载Vulkan驱动来做硬件级Buffer转换时，立即抛出fatal error。

- 尝试在客户端加上 ``--video h264`` 并且在服务端加上 ``--diable-gpu`` :

.. literalinclude:: waypipe_pi/waypipe_ssh_disable-gpu
   :caption: 结合waypipe和ssh(disable-gpu)

但是报错依旧。按照gemini的说明 ``waypipe`` 对控制DMABUF和Vulkan的参数极少，所以需要尝试禁用Waypipe的Vulkan隐式调用:

.. literalinclude:: waypipe_pi/waypipe_ssh_disable-gpu_env
   :caption: 结合waypipe和ssh(隐式禁用Vulkan)

但是我发现没有效果，gemini提示: Chromium 即使加了 ``--disable-gpu`` ，有时在 Wayland 模式下依然会尝试向 Wayland Compositor 申请 ``zwp_linux_dmabuf_v1`` 接口，这会诱发 waypipe 去初始化 Vulkan 来处理 DMABUF。

所以尝试通过设置环境变量限制树莓派端的 Wayland 协议，或者在 Chromium 中彻底禁用 DMA-BUF:

.. literalinclude:: waypipe_pi/waypipe_ssh_disable_gpu_dmabuf
   :caption: 结合waypipe和ssh(禁止DMABUF)

在 MacBook Air 启动 waypipe 时，通过 LD_PRELOAD 或禁用 libvulkan 的搜索，强制让 waypipe 找不到系统的 Vulkan 共享库。这样它就会认为当前系统完全不具备 Vulkan 运行环境，从而跳过 Vulkan Instance 的创建，直接降级到纯内存 SHM 模式:

.. literalinclude:: waypipe_pi/waypipe_ssh_disable_gpu_dmabuf_again
   :caption: 结合waypipe和ssh(禁止DMABUF)

还是不行，那么再尝试 "在树莓派 5 上通过环境变量屏蔽 Wayland 的 DMABUF 协议" :

.. literalinclude:: waypipe_pi/waypipe_ssh_disable_gpu_dmabuf_again
   :caption: 结合waypipe和ssh(禁止DMABUF)

**晕倒，黔驴技穷了**

变通解决
==========

由于硬件限制 :ref:`mba11_late_2010` 上运行纯粹的 ``Waypipe`` 没有成功，所以实际上我最终采用了:

- :ref:`xwayland_remote_app` 借助X11兼容的Xwayland来实现远程应用
- :ref:`xwayland_remote_audio` 补充 :ref:`pipewire` 网络音频解决方案
