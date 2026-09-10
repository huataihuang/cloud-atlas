.. _alpine_sway_mba11_late_2010:

=====================================================
MacBook Air 11" Late 2010安装Alpine Linux的sway桌面
=====================================================

.. note::

   本文在 :ref:`alpine_sway` 基础上重新实践和总结

安装显卡驱动
===============

:ref:`mba11_late_2010` 使用的是 NVIDIA 显卡硬件，在Alpine Linux平台只能使用 ``Nouveau`` 开源驱动，原因是NVIDIA GPU的私有驱动不提供Alpine Linux的 ``musl`` C库驱动。

.. note::

   我以前在 :ref:`alpine_sway` 执行安装 ``xf86-video-nouveau`` :

   .. literalinclude:: alpine_sway/install_nouveau
      :caption: 安装 ``Nouveau`` 驱动

   但是这个包现在已经移除了。询问了gemini，现代Linux发行版 ``xf86-video-nouveau`` (X11 DDX驱动)已经弃用。对于使用 :ref:`sway` (Wayland合成器)，它完全运行在 Kernel Mode Setting(KMS)和Generic Buffer Management(GBM)上， **根本不需要xf86-video-*这类传统X11驱动** 。

.. note::

   ``apk search nouveau`` 会看到有一个 ``mesa-vulkan-nouveau-26.1.6-r0`` ，这是Mesa 项目为 NVIDIA 显卡提供的 开源 Vulkan 驱动（也称为 NVK）:

   - **功能**: 让 NVIDIA 显卡能够支持 Vulkan API 渲染，类似于 Mesa 中的 radv（针对 AMD）和 anv（针对 Intel）。
   - NVK 是近年 Mesa 社区使用 Rust 和 C 语言重构的全新 Vulkan 驱动，旨在为开源 NVIDIA 驱动提供现代图形 API 支持。

   但是:

   - Vulkan API 最低需要 NVIDIA Kepler 架构（GTX 600 系列及以上） 才能支持; GeForce 320M 属于 Tesla 架构（NV50 家族），所以不能使用
   - ``mesa-vulkan-nouveau`` (NVK) 在 Mesa 项目中主要面向 Turing (GTX 16/RTX 20) 及更新架构 的显卡进行重点开发，对于老旧显卡完全无法向下兼容

- 对于 :ref:`wayland` 桌面，只需要安装以下软件包:

  - ``mesa-dri-gallium`` : Mesa驱动所需
  - ``mesa-gbm`` : **GBM (Generic Buffer Management)** 是 Wayland 合成器（如 基于 wlroots 的 Sway）在 Linux 显卡驱动上分配图像缓冲区的标准接口。如果不安装 ``mesa-gbm`` ，Sway启动会报错

    - sway 依赖 wlroots => wlroots 依赖 libgbm / mesa-gbm ，所以即使不单独安装 ``mesa-gbm`` ，在安装sway时候也会自动依赖安装 ``mesa-gbm``

可选安装:

  - ``mesa-va-gallium`` : VA-API驱动，用于硬件加速的视频编码和解码

    - ``mesa-va-gallium`` 是专门用于调用显卡视频硬件加速（VA-API）的驱动组件，在 Nouveau 开源驱动架构下，它充当视频播放软件（如 mpv、Firefox）与 NVIDIA 硬件视频解码引擎之间的 bridge 桥梁。
    - 属于 **可选的视频硬解增强包** ，并不是启动图形界面（Sway 桌面）的必须依赖。
    - GeForce 320M (NV50) 的 VDPAU/VA-API 开源硬解在 Nouveau 下支持非常有限且稳定性一般，即便不装也不影响 Sway 桌面的正常显示与渲染。

.. note::

   针对 GeForce 320M (MCP89 芯片组，属于 NV50/VP4 硬件解码世代) 这块老显卡，开启 VA-API 硬解的优缺点及不安装的影响如下:

   - 优点:

     - **显著降低 CPU 负担** : :ref:`mba11_late_2010` 配备的是低功耗的 Core 2 Duo (SU9400/SL9400) 处理器，性能极其有限。如果不靠 GPU 硬解，单纯靠 CPU 软解 1080p 视频会导致 CPU 占用率瞬间飙升到 90%~100%。
     - **抑制发热与风扇噪音** : 通过 VP4 硬件解码引擎处理视频，能大幅减少 CPU 发热，让老款 MacBook Air 的风扇不至于剧烈狂转。

   - 缺点:

     - **稳定性较差** : Nouveau 社区对旧款 NV50/VP4 硬件解码器的逆向工程并不完美。在播放某些特定码率或格式的 H.264 视频时，可能会遇到画面绿屏、花屏、渲染卡死，甚至直接导致图形会话崩溃。
     - **电源管理限制（无法动态调频）** : Nouveau 在该代显卡上的 Reclocking（重新调频）支持非常原始，显卡经常运行在最低核心频率下，这导致即使硬件支持硬解，处理高码率视频时依然可能出现丢帧现象。
     - **格式支持受限** : VP4 硬件引擎仅支持 H.264 (AVC) 和 VC-1 / MPEG-2。对于现代网页主流的 VP9 或 AV1 编码，320M 硬件根本不支持，装了也只能退回 CPU 软解。

   **不安装 mesa-va-gallium 对于 Sway 桌面本身：毫无影响** : UI 合成、终端操作、窗口拖拽完全依赖 ``mesa-dri-gallium`` 和 ``mesa-gbm`` ，不依赖任何视频解码库。

.. literalinclude:: alpine_sway/install_mesa
   :caption: 安装mesa驱动依赖软件包

- Wayland 依赖内核 Mode Setting (KMS)。确保在 initramfs 阶段就加载 nouveau 模块:

编辑 ``/etc/mkinitfs/mkinitfs.conf`` ，在 features 中确保包含 kms:

.. literalinclude:: alpine_sway_mba11_late_2010/mkinitfs.conf
   :caption: 添加 ``kms`` 

编辑 ``/etc/modules`` ，添加 ``nouveau`` ( :ref:`alpine_install_mba11_late_2010` 中我已经设置了将 ``/etc/modules`` 添加到 ``initramfs`` 所以能够预加载 )

.. literalinclude:: alpine_sway_mba11_late_2010/modules
   :caption: 在 ``/etc/modules`` 添加 ``nouveau``
   :emphasize-lines: 4

然后执行 ``mkinitfs`` 更新 ``/boot/initramfs-lts``

- 重启系统，然后通过 ``lsmod`` 可以看到系统加载了 ``nouveau`` 驱动

安装sway
===========

.. note::

   在 Alpine 中，核心系统软件（如 ``busybox`` 、 ``musl`` ）放在 ``main`` 仓库，而像 ``sway`` 、 ``wlroots`` 、 ``foot`` 这类桌面环境和 Wayland 相关组件都存放在 ``community`` 仓库中。

- 开启 community 仓库: 编辑 ``/etc/apk/repositories`` :

.. literalinclude:: alpine_sway_mba11_late_2010/repositories
   :caption: 将community行注释取消
   :emphasize-lines: 3

- 安装 sway:

.. literalinclude:: alpine_sway_mba11_late_2010/install_sway
   :caption: 安装sway

.. note::

   ``font-dejavu`` 是 Linux 环境下一个非常经典且基础的 开源标准 Fonts（字体）软件包。它基于 Bitstream Vera 字体族扩展而来，包含了常用的无衬线（Sans-serif）、衬线（Serif）和等宽（Monospace）字体。

   ``font-dejavu`` 提供了像 `DejaVu Sans`` 和 ``DejaVu Sans Mono`` 这类非常干净、高可读性的西文字体，是 Sway 默认配置文件、swaybar 状态栏以及 foot 终端默认依赖的基础字体。

- 安装 ``seatd`` (见 :ref:`gentoo_sway` )以便能够配置用户到对应组:

.. literalinclude:: alpine_sway/install_seated
   :caption: 安装设置seatd

- 确保用户在 video 和 input 组

.. literalinclude:: alpine_sway_mba11_late_2010/addgroup
   :caption: 确保用户组

- (我现在取消了)针对 GeForce 320M 显卡，设置 **使用软件渲染光标（Software Cursor）** :

.. literalinclude:: alpine_sway_mba11_late_2010/profile
   :caption: 设置 ``~/.profile``

.. note::

   **仅供参考，我现在没有采用**

   现代显卡通常包含一个专门的硬件图层（Hardware Overlay Layer），专门用来绘制鼠标指针。这样无论系统主画面怎么渲染、帧率怎么波动，鼠标指针都能由硬件直接合成，实现极低的移动延迟（即“硬件光标”）。

   但是，wlroots（Sway 的底层框架）在通过 Nouveau 开源驱动 调用 GeForce 320M 这类老旧 NVIDIA 显卡的硬件光标接口时，由于开源驱动对老旧 Display Engine 的逆向工程不完整，无法正确分配硬件光标的显存 Buffer。

   设置 ``WLR_NO_HARDWARE_CURSORS=1`` 会显式告知 wlroots：放弃使用显卡的硬件光标图层，改为使用软件渲染光标（Software Cursor）——即把鼠标指针直接当成普通图像，绘制在 Sway 的桌面合成 Buffer 里。

   设置 软件渲染光标（Software Cursor）可以解决 GeForce 320M 在 Nouveau 驱动下启动 Sway的常见异常问题:

   - 界面能出来，但鼠标指针彻底不可见（实际上鼠标在移动，但你看不到）
   - 鼠标移动过的区域出现严重的花屏、画面残影或闪烁
   - 某些情况下 Sway 在尝试分配硬件光标 Buffer 时直接崩溃

- 配置环境变量(之前在 :ref:`alpine_sway` 实践中我记录seated会自动处理，但是我现在实践没有成功，所以还是手工设置)，即在 ``~/.profile`` 中添加:

.. literalinclude:: alpine_sway_mba11_late_2010/profile_sway
   :language: bash
   :caption: 设置 ``$XDG_RUNTIME_DIR`` 环境变量
   :emphasize-lines: 1-6

- 复制配置文件：

.. literalinclude:: alpine_sway/cp_config
   :caption: 复制配置文件

激活touchpad支持(对于Macbook非常有用，参考 :ref:`archlinux_sway` )

.. literalinclude:: ../arch_linux/archlinux_sway/config_touchpad
   :language: bash
   :caption: sway配置touchpad

禁止 Xwayland: 在 ``config`` 开头加上 ``xwayland disable``

- 重新登录终端后，执行命令:

.. literalinclude:: alpine_sway_mba11_late_2010/start_sway
   :caption: 启动sway

sway启动异常排查
---------------------

我执行sway启动时，会提示错误:

.. literalinclude:: alpine_sway_mba11_late_2010/start_sway_error
   :caption: 启动sway失败

实际上这两句报错叠加在一起看不清，所以通过如下debug启动方法来获取启动日志

.. literalinclude:: alpine_sway_mba11_late_2010/start_sway_debug
   :caption: 排查启动sway

检查日志 ``sway_debug.log`` 可以看到报错的原因是没有输入设备:

.. literalinclude:: alpine_sway_mba11_late_2010/sway_debug.log
   :caption: sway_debug.log 显示报错原因是没有输入设备
   :emphasize-lines: 4

另外这里也提示了，可以通过 ``WLR_LIBINPUT_NO_DEVICES=1`` 跳过这个检查(强制在没有输入设备情况下启动sway进行验证)

果然:

.. literalinclude:: alpine_sway_mba11_late_2010/start_sway_no_devices
   :caption: 设置没有设备的环境变量强制启动sway验证

现在能够看到sway桌面了，不过由于设置了 ``WLR_LIBINPUT_NO_DEVICES=1`` 环境变量，所以既没有鼠标也没有键盘输入。

现在问题集中在输入设备上，也就是说为何键盘鼠标输入设备不能使用:

- 检查设备节点权限:

.. literalinclude:: alpine_sway_mba11_late_2010/ls_input
   :caption: 检查输入设备权限

确认所有 ``event*`` 文件对应用户组都是 ``input`` ，并且对组是读写权限( ``crw-rw---- 1 root input ...`` )

- 我忽然想到是不是我的精简安装导致缺少了软件包，果然gemini提示了几种可能性，我感觉最有关联的可能是 ``udev`` 相关，搜索了一下已经安装的软件包，果然没有 ``eudev`` 软件包:

  - ``eudev`` （或 ``udev`` ）：负责动态检测 ``/dev/input/event*`` 设备。Alpine 默认不一定启动 ``udev`` ，导致 ``libinput`` 无法自动发现新接入的键盘鼠标。
  - 在 Alpine Linux 中，由于采用了 OpenRC 架构且默认不使用 :ref:`systemd` ，传统的 ``udev`` 被 ``eudev`` ( :ref:`gentoo_linux` 维护的独立 ``udev`` 分支）所替代

.. literalinclude:: alpine_sway_mba11_late_2010/install_eudev
   :caption: 安装eudev

安装完成后启动服务并设置随操作系统启动 ``eudev`` :

.. literalinclude:: alpine_sway_mba11_late_2010/start_eudev
   :caption: 设置并启动eudev

.. note::

   在 Alpine 中，eudev 提供了两个核心 OpenRC 服务:

   - ``udev`` 守护进程，负责监听 Linux 内核发出的设备变动信号(uevent)
   - ``udev-trigger`` 触发硬件扫描，因为 ``udevd`` 守护进程启动时，键盘、鼠标、显卡早已插在电脑上，内核已经错过了发送初始信号的实际。所以 ``udev-trigger`` 会主动扫描 ``/sys`` 文件系统，把这些硬件重新触发以便，让 ``udevd`` 为设备打上HWDB标签、配置 ``/dev/input/`` 权限。没有这一步，sway就识别不到开机前就插好的键盘鼠标。
   - ``udev-postmount`` 在系统根文件系统( ``/`` )从只读状态切换为读写( ``rw`` )、并完成挂载后完成其他本地文件系统之后执行。

在安装完成 ``eudev`` 并启动服务后， ``eudev`` 会自动扫描系统的输入设备并在 ``/dev/input/`` 目录下生成事件节点( 注意: 比之前多了 ``by-id`` 和 ``by-path`` 目录，并在目录下链接到对应event设备):

.. literalinclude:: alpine_sway_mba11_late_2010/dev_event
   :caption: 事件设备增加了 ``py-id`` 和 ``by-path``

.. note::

   - 为什么没有 ``eudev`` 也会有 ``event*`` 节点？

     - Linux 内核在检测到键盘、鼠标等硬件时，会自动在 ``/dev`` 目录下创建基础的字符设备文件（比如 ``/dev/input/event0`` ）。这是内核自带的功能，不需要任何用户态服务。

   - ``eudev``（以及 ``eudev-openrc`` ）扮演什么角色？

     - **打上 hwdb 硬件标签** : ``libinput`` 和 ``sway`` 依赖 ``udev`` 数据库（ ``hwdb`` ）来识别这个 ``event`` 节点到底是一个“键盘”、“鼠标”还是“触摸板”。如果没有 ``eudev`` ， ``libinput`` 无法获取设备的类别属性，可能会直接忽略这些节点。
     - 维护 ``/dev/input/by-id`` 和 ``/dev/input/by-path`` 软链接。
     - **处理设备权限（udev rules）** ：配合 ``seatd`` 将输入设备动态分配给当前登录的用户会话。

   在 Alpine Linux 中， ``eudev`` 是核心软件包，而 ``eudev-openrc`` 包含的是让 OpenRC 初始化系统在开机时启动 ``udevd`` 守护进程和触发硬件扫描（ ``udev-trigger`` ）的服务脚本。

上述 ``eudev`` 安装完成后，可以看到再次启动 sway 成功。

配置自动登录sway
---------------------

- 终端自动启动，配置 ``~/.profile`` :

.. literalinclude:: alpine_sway_mba11_late_2010/profile_sway
   :language: bash
   :caption: 配置在终端tty1自动启动sway
   :emphasize-lines:  17-19

中文环境
============

中文字体
-----------

- 安装中文字体 ``Noto Sans CJK（思源黑体）``

``Noto Sans CJK（思源黑体）`` 字体是Adobe和Google联合开发的字体家族，其设计目的是支持中文、日文和
韩文（CJK）。思源黑体的设计现代、清晰，并提供多种字重（粗细）选择。比早期Linux发行版使用的 ``文泉
驿正黑（WenQuanYi Zen Hei）`` 包含更多且支持所有CJK自负，并未一些扩展区自负提供支持

alpine linux 提供了2个 ``Noto Sans CJK（思源黑体）`` 字体软件包:  ``font-noto-cjk`` 和 ``font-noto-cjk-extra``

.. literalinclude:: alpine_sway/install_font-cjk
   :caption: 安装 ``Noto Sans CJK（思源黑体）`` 字体

.. note::

   我现在安装 思源黑体 和 思源等宽黑体

gemini推荐组合各种字体来获得更舒适的视觉体验:

- **UI 与网页（无衬线黑体）** : ``Noto Sans CJK SC`` 或 ``wqy-zenhei`` （文泉驿正黑，极致体积）。
- **终端/代码/Rime 输入法（等宽字体）** : ``font-sarasa-gothic`` (撒拉沙黑体 / 更砂黑体) ，不过 更砂黑体（Sarasa Gothic）被打包在 Testing 仓库(安装有点麻烦) ，或者安装 ``font-noto-cjk-extra`` (思源等宽黑体（Noto Sans Mono CJK）)

  - Sarasa Gothic 专为代码和终端优化，中英文等宽（1个汉字=2个英文字符），且完全包含矢量图标，在 Foot / Alacritty / Sway 等宽终端下不会错位。

.. literalinclude:: alpine_sway/install_font-cjk_all
   :caption: 安装 思源黑体 + 撒拉沙等宽黑体 + 文泉驿微米黑

- 针对 思源黑体（Noto Sans CJK SC） 和 思源等宽黑体（Noto Sans Mono CJK SC） 优化 ``~/.config/fontconfig/fonts.conf`` : 配置中包含了完整的 抗锯齿（Antialias）、亚像素渲染（Subpixel RGB）、微调（Hinting） 以及 LCD 滤镜 优化，能有效解决 Alpine Linux 环境下 Wayland 界面和终端中文字体发虚、模糊或边缘锯齿的问题。

.. literalinclude:: alpine_sway_mba11_late_2010/fonts.conf
   :caption: 字体配置优化 ``~/.config/fontconfig/fonts.conf``

- 字体配置完成后，执行缓存更新:

.. literalinclude:: alpine_sway_mba11_late_2010/fc-cache
   :caption: 刷新字体缓存

检查系统默认 monospace（等宽）和 sans-serif 是否成功指向思源字体:

.. literalinclude:: alpine_sway_mba11_late_2010/fc-match
   :caption: 验证

fcitx5中文输入法
-------------------

- 安装fcitx5中文输入法:

.. literalinclude:: alpine_sway/install_fcitx
   :caption: 安装中文输入法

.. note::

   如果要交互配置，可以补充安装 ``fcitx5-configtool`` 工具包，等配置完成后再卸载

   不过更简单的方法是从其他相似环境中复制配置，例如 :ref:`freebsd_chinese` 我采用从 :ref:`arch_linux` 上复制已经通过 ``fcitx5-configtool`` 配置好的配置文件(同样采用 ``fcitx5-rime`` ): :download:`fcitx5.tar.gz <../../_static/freebsd/desktop/fcitx5.tar.gz>`

- 配置 ``~/.profile`` (参考 :ref:`gentoo_kde_fcitx` )

.. literalinclude:: alpine_sway_mba11_late_2010/profile_sway
   :caption: 添加fcitx配置
   :emphasize-lines: 9-11,14

参考
======

- gemini
- `Alpine Linux wiki: NVIDIA <https://wiki.alpinelinux.org/wiki/NVIDIA>`_
- `Alpine Linux wiki: Sway <https://wiki.alpinelinux.org/wiki/Sway>`_
- `Alpine Linux wiki: Seatd <https://wiki.alpinelinux.org/wiki/Seatd>`_
- `arch linux wiki: Rime <https://wiki.archlinuxcn.org/wiki/Rime>`_
