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

Xwayland 与 Chromium 的 X11 依赖
==================================

Waypipe 的 Rust 依赖项在当前 Alpine/Sway 环境下依然强行硬编码检查 Vulkan，在处理 Chromium 这类重度 Web 渲染时，SSH X11 转发配合树莓派 5 强悍的 A76 CPU 软解，体验甚至可能比死磕 Waypipe 的 DMABUF Bug 更顺畅。

- 在树莓派 5 上安装 Xwayland 与 Chromium 的 X11 依赖:

.. literalinclude:: waypipe_pi/install_xwayland
   :caption: 在服务器安装 Xwayland 与 Chromium 的 X11 依赖

- 在 MacBook Air 上直接通过 ``ssh -X`` 启动

.. literalinclude:: waypipe_pi/ssh_x
   :caption: 通过Xwayland兼容模式运行

出现报错

.. literalinclude:: waypipe_pi/ssh_x_error
   :caption: 通过Xwayland兼容模式运行报错

这个报错需要检查服务器，确保 ``/etc/ssh/sshd_config`` 允许X11 转发:

.. literalinclude:: waypipe_pi/sshd_config
   :caption: 服务器端sshd必须允许X11转发

并且需要检查在客户端( :ref:`mba11_late_2010` )上的 :ref:`sway` 配置 ``~/.config/sway/config`` 确保允许 ``xwayland enable`` ，这样进入sway桌面，执行:

.. literalinclude:: waypipe_pi/display
   :caption: 检查DISPLAY

输出显式:

.. literalinclude:: waypipe_pi/display_output
   :caption: 检查DISPLAY输出信息

这个输出信息并没有显式出X DISPLAY，这说明在客户端( :ref:`mba11_late_2010` )没有安装Xwayland相关的软件包，需要补充安装:

.. literalinclude:: waypipe_pi/install_xwayland_client
   :caption: 在客户端也需要安装Xwayland

然后重新启动一次sway,再次检查

.. literalinclude:: waypipe_pi/display
   :caption: 检查DISPLAY

正确的输出信息应该是

.. literalinclude:: waypipe_pi/display_output_ok
   :caption: 检查DISPLAY输出信息,正确的输出信息有两行
   :emphasize-lines: 2

果然，现在执行就正常了:

.. literalinclude:: waypipe_pi/ssh_x
   :caption: 通过Xwayland兼容模式运行

终于看到chrome的窗口了!!!

X11 / Xwayland 键盘映射表
---------------------------

遇到一个奇怪的事情似乎客户端和服务器的键盘规格不一致导致的: 我输入url以后打回车，但是显示的却是字幕 j ，回车没有用处

在 Linux 下，按键按下时硬件输出的是 **Scancode（扫描码）** ，然后通过 **XKB（X Keyboard Extension）映射表** 将其转换为具体的 **Keycode / Keysym（字符）** 。

在 MacBook Air 上通过 ssh -X 将远程树莓派的 X11 窗口（Chromium）拉回到本地的 Xwayland 渲染时:

- 本地 Sway 运行在现代 Wayland 协议下，使用 Linux Input 规范
- 树莓派的 Chromium 运行在 X11 协议下: ``ssh -X`` 在建立隧道时，把树莓派端的 X11 默认键盘映射（通常是标准的 104 键 PC 布局或默认规则）直接挂到了 MacBook Air 的 Xwayland 客户端上，导致按键码对不齐。

解决方法: 启动 Chromium 前，强制将远程 X11 会话的键盘映射同步重置为标准的 104 键（或 Mac 键盘）布局，或者强制 Chromium 走原生的 Wayland / XKB 传递。

- 在树莓派上安装 ``x11-xserver-utils`` (包含 ``setxkbmap`` )

.. literalinclude:: waypipe_pi/install_setxkbmap
   :caption: 在树莓派上安装 ``setxkbmap``

- 启动时先重置键盘映射，再启动 Chromium:

.. literalinclude:: waypipe_pi/ssh_x_setxkbmap
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射

这里又有一个报错:

.. literalinclude:: waypipe_pi/ssh_x_setxkbmap_error
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，报错

因为 ``ssh -X`` （受限的 X11 转发模式）出于安全考虑，默认屏蔽了 X11 的 XKB 扩展功能。当 ``setxkbmap`` 尝试向这个受限的 X11 伪 Display 写入键盘映射时，X Server 拒绝了该请求，因此触发报错。

只要改用 -Y（Trusted X11 forwarding，信任模式），SSH 就会完整放开 XKB 扩展在内的所有 X11 协议支持:

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y``

现在验证就看到了输入完整，回车键也能正常工作

- 适配Mac键盘: 由于我现在使用的 :ref:`mba11_late_2010` 采用的是Mac键盘，所以上述命令还可以再改进 ``setxbmap`` 键盘映射

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 键盘设置为Mac

中文显示和输入
---------------

- 在树莓派服务器端需要安装中文字体才能确保chrome中正常 :ref:`linux_chinese_view` :

.. literalinclude:: ../chinese/linux_chinese_view/apt_install_fonts-wqy
   :caption: 安装中文字体

- 客户端 :ref:`mba11_late_2010` 上需要正确配置 :ref:`alpine_sway_mba11_late_2010` :

.. literalinclude:: ../chinese/fcitx/environment
   :language: bash
   :caption: 启用fcitx5环境变量配置 /etc/environment
   :emphasize-lines: 1-3

- 在 MacBook Air 终端上运行 SSH 命令时，显式将 ``XMODIFIERS`` 传递给树莓派端的 Chromium（或者使用 ``-E`` 选项保留环境变量）

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac_fcitx
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 键盘设置为Mac，并传递 ``XMODIFIERS``

.. note::

   有一点点遗憾，现在确实能够输入中文，但是输入速度不能太快，太快的话部分输入字母会  没有被本地fcitx捕获而直接将英文字母传输给了远程的chromium应用，导致中文中夹杂着英文字母(拼音字母)

.. warning::

   上述遗憾一直存在，我尝试了gemini提供的几个建议都解决不了快速输入导致的部分拼音字母直接传递给远程应用，导致中文和英文混杂。

   **最终还是只能忍受中文输入慢一些**

   本文后面的一些尝试记录不用再看了

- ( ``验证无效`` )gemini建议将老旧且低效的 X11 同步协议( ``GTK_IM_MODULE=xim`` )改为 ``dbus / fcitx`` 可以让 Fcitx5 走异步事件通道: 由于 ``ssh -Y`` 会默认转发 DBus 信号（或者共享 Session DBus），直接使用 fcitx 作为模块驱动可以极大地降低网络确认延迟

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac_fcitx_dbus
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 键盘设置为Mac，并 **使用dbus** 直接用 fcitx 作为模块驱动

但是这个方法实际验证反而导致无法呼出输入法，所以失败了

- ( ``验证无效`` )gemini建议 "降级 X11 输入层为异步 xim 延迟修复" : 如果不得不使用 xim，可通过在启动命令中为 Chromium 增加 X11 异步标志，禁止 X11 在等待 XIM 响应时丢弃包

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac_fcitx_xim
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 键盘设置为Mac，并传递 ``XMODIFIERS`` + chromium增加X11异步标志


- ( ``验证无效`` )gemini还有一个建议是 **优化 Fcitx5 的按键转发行为，防止它在处理 X11 事件时向远端透传未处理完的按键** :

  - Fcitx5 配置界面（或修改 ``~/.config/fcitx5/config`` ）
  - 在 全球配置 (Global Options) -> 高级 (Advanced) 中:

    - 将 Forward Unhandled Key (转发未处理按键) 设为禁用或延时处理
    - 开启 Share Input State (共享输入状态)

按照gemini提供的配置，尝试修订 ``~/.config/fcitx/config`` :

.. literalinclude:: waypipe_pi/fcitx_config
   :caption: 修改fcitx配置，优化Fcitx5 本地“前向提交 / 异步处理”

但是很不幸，这个方案也没有效果
