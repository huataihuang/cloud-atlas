.. _amd_mi50_flash_vbios:

======================================================
AMD Radeon Instinct MI50 刷VBIOS 改成 Radeon Pro VII
======================================================

准备
==========

:ref:`rocm_quickstart` 安装好 ROCm 和 amdgpu驱动，然后检查 ``rcom-smi`` 输出显示:

.. literalinclude:: amd_mi50_flash_vbios/rocm-smi_output_before
   :caption: 在没有刷VBIOS之前的rocm-smi输出

.. note::

   `TechPowerUp <https://www.techpowerup.com/>`_ 是目前全球最权威的显卡固件和工具库

- 下载 ``amdvbflash`` (原名 Atiflash)，下载页面见 `TechPowerUp - AMDVBFlash / ATI Flash <https://www.techpowerup.com/download/ati-atiflash/>`_

.. literalinclude:: amd_mi50_flash_vbios/get_amdvbflash 
   :caption: 下载 ``amdvblash``

- 下载AMD Radeon Pro VII 16GB 原厂 ROM: 访问 `TechPowerUp VGA BIOS Database <https://www.techpowerup.com/vgabios/>`_ 依次选择:

  - GPU Brand: AMD
  - Card Model: Radeon Pro VII
  - Card Vendor: AMD (Pro 系列通常只有公版)
  - Memory Size: 16384 MB (16GB)

TechPowerUp提供的Radeon Pro VII 16 GB Video BIOS版本是2020-08-18发布的 ``016.004.000.064.015319``

.. literalinclude:: amd_mi50_flash_vbios/get_vbios
   :caption: 下载 Pro VII 的VBIOS

.. note::

   由于AMD官方网站不对外提供"裸“ROM文件，以及刷机工具，所以通常需要通过第三方TechPowerUp托管的工具和固件来完成。TechPowerUp网站提供的ROM通常经过大量用户的评论和验证，选择带有"Verified"标签的固件，代表通过了社区的测试。

   在刷入任何非官方固件之前，先使用 ``amdvbflash -s`` 命令提取当前卡的原厂VBIOS，那么即使以后想要回退原厂VBIOS也是可行的。这点非常重要，因为AMD官方可能不提供MI50原始VBIOS下载。

初次尝试 ``失败``
=====================

- 检查VBIOS版本(从显卡的 EEPROM 芯片读取信息，不依赖操作系统驱动的映射):

.. literalinclude:: amd_mi50_flash_vbios/amdvbflash_i
   :caption: 检查当前VBIOS版本

输出的固件版本、Device ID 和 Subsystem ID信息如下:

.. literalinclude:: amd_mi50_flash_vbios/amdvbflash_i_output
   :caption: 当前VBIOS版本信息

说明:

  - adapter: 显卡索引（如 0, 1）。
  - device id: 核心标识（MI50 应该是 66A2，刷完 Pro VII 后应变为 66AF）。
  - product: 固件版本号（VBIOS Version）。
  - checksum: 固件校验码。

- 备份当前 :ref:`amd_mi50` 的原厂VBIOS:

.. literalinclude:: amd_mi50_flash_vbios/backup_vbios
   :caption: 备份当前MI50的原厂VBIOS

- 刷入下载的Pro VII VBIOS:

.. literalinclude:: amd_mi50_flash_vbios/flash_vbios
   :caption: 刷入Pro VII VBIOS

刷新信息如下:

.. literalinclude:: amd_mi50_flash_vbios/flash_vbios_output
   :caption: 刷入Pro VII VBIOS时的输出信息

这里的输出信息有点让人不安:

  - ``RSA Signature Verify: PASS`` 硬件安全检查通过了，说明这个 ROM 的签名是合法的，显卡不会因为固件签名错误而变成“砖头”
  - ``DeviceID: 66A1 (未变)`` MI50 原本报告的是 66A1，刷完 Pro VII 还是 66A1。这意味着 MI50 和 Radeon Pro VII 在核心层面的硬件 ID 是完全一致的
  - ``SSID (Subsystem ID) 的变化 (0834 -> 081E)`` 许多 OEM 厂商（如 Dell）的 BIOS 并不是封锁 DeviceID（因为那太笼统），而是封锁 SSID。这个变化表明有可以能绕过 Dell T5820 封锁
  - ``Product Name`` 从 ``SERVER XL`` 变为了 ``GLXT WS`` （Workstation）
  - 注意显存频率：原来的固件是 ``600m`` ，新固件是 ``1000m`` 。这意味着 HBM2 显存将被超频运行。注意散热。
  - **最大的潜在问题** : 刷入的是 16GB 版 Radeon Pro VII 的 ROM ，后续验证了 **不同显存规格的VBIOS是不通用的，会导致无法加载驱动**

- 刷新完成后再次执行 ``sudo ./amdvbflash -i`` 看到信息

.. literalinclude:: amd_mi50_flash_vbios/amdvbflash_i_output_after
   :caption: 刷新了0号设备的VBIOS版本信息
   :emphasize-lines: 6

执行 ``sudo ./amdvbflash -ai`` 可以看到详细信息:

.. literalinclude:: amd_mi50_flash_vbios/amdvbflash_ai_output_after
   :caption: 刷新了0号设备的VBIOS详细信息
   :emphasize-lines: 6

可以看到刷新后的产品信息已经修改成 ``Vega20 A1 GLXT WS D16406 60CU/16GB 4HI 1000m``

但是我发现问题，现在 ``rocm-smi`` 输出中，预期的 ``Pro VII`` 没有出现，现在只有一行作为对比的 MI50 记录了，这表明刷新VBIOS的MI50不工作了:

.. literalinclude:: amd_mi50_flash_vbios/rocm-smi_output_1
   :caption: 刷新VBIOS之后只有一行MI50记录

观察 ``dmesg`` 信息，果然发现驱动加载失败:

.. literalinclude:: amd_mi50_flash_vbios/dmesg_error
   :caption: 启动时dmesg报错显示刷了VBIOS后初始化失败
   :emphasize-lines: 2

``error -22`` (Invalid Argument)通常意味着内核驱动 amdgpu 在尝试初始化时遇到了参数不匹配或验证失败的情况。当驱动尝试初始化内存控制器（Memory Controller）并验证 HBM2 的堆栈数量和容量时，由于固件描述（4HI/16GB）与实际物理探测（8HI/32GB）严重不符，驱动会直接抛出 Invalid Argument 并退出。

我忽然想起来，在查询MI50的官方网站驱动时，AMD实际上将MI50的16GB规格和32GB规格用了两个不同的安装软件包，另外我想起来NVIDIA显卡魔改，并不是直接将显存芯片改焊其他大规格显存芯片就能解决，是需要破解BIOS和驱动的，这说明厂商在显存上做了很多限制，直接刷不通规格VBIOS很可能是行不通的。

再次尝试
===========

`evilJazz/MI50_32GB_VBIOS.md <https://gist.github.com/evilJazz/14a4c82a67f2c52a6bb5f9cea02f5e13>`_ 给出了详尽的针对32GB规格 :ref:`amd_mi50` 的实践建议:

- `AMD Radeon Pro V420 <https://www.techpowerup.com/gpu-specs/radeon-pro-v420.c3955>`_ 才是推荐采用的刷MI50的对应VBIOS:

  - ``Pro V420`` 是真正匹配的32GB规格的 ``Vega 20`` GPU，和 :ref:`amd_mi50` 32GB规格完全匹配
  - 支持 ``UEFI in ROM`` ，这改变了MI50的 ``Legacy only``
  - 支持显示输出
  - 支持 ``ReBAR`` ，而MI50则不支持ReBAR
  - BAR size扩大到32GB，MI50似乎因为Vulkan问题导致BAR size 16GB
  - 支持PCIe link power saving，甚至支持在idle时候降低到Gen 1
  - 功耗降低到178W，但是性能只下降1%(使用vkpeak测试)，原因是多GPU以轮询方式推理，核心/热点有足够时间冷却，使得功率上限和散热得到优化
  - SCLK时钟频率略微提高(我看到比原生MI50的930 MHz提高一点点，达到938 MHz)

- 刷入 ``V420.rom`` (113-D1640200-043):

.. literalinclude:: amd_mi50_flash_vbios/flash_v420_rom
   :caption: 刷入Pro V420的VBIOS

输出显示

.. literalinclude:: amd_mi50_flash_vbios/flash_v420_rom_output
   :caption: 刷入Pro V420的VBIOS显示信息
   :emphasize-lines: 11

- 成功刷入V420的VBIOS之后，重启系统，再次使用 ``rocm-smi`` 可以看到正常加载的驱动显示出了这块 **Pro V420** 显卡，请注意其参数和没有刷VBIOS的 **MI50** 差异:

.. literalinclude:: amd_mi50_flash_vbios/rocm-smi_v420
   :caption: 刷入Pro V420的VBIOS之后参数
   :emphasize-lines: 6

这里最大的变化是TDP下降到 **178W** ，这对于安装在 :ref:`dell_t5820` 工作站有很大帮助，另外提供了mini HDMI输出，🈶️可以省却一块P400占用的PCIe插槽，

对比 ``amdvbflash -i`` 输出:

.. literalinclude:: amd_mi50_flash_vbios/amdvbflash_v420_mi50
   :caption: 对比 ``amdvbflash -i`` 输出信息
   :emphasize-lines: 6

对比 ``amdvbflash -ai`` 输出

.. literalinclude:: amd_mi50_flash_vbios/amdvbflash_ai_v420_mi50
   :caption: 对比 ``amdvbflash -ai`` 输出信息
   :emphasize-lines: 6,14

.. note::

   `evilJazz/MI50_32GB_VBIOS.md <https://gist.github.com/evilJazz/14a4c82a67f2c52a6bb5f9cea02f5e13>`_ 提到了混用不同的VBIOS似乎会给ROCm带来问题，他在ollama测试中发现SCALE信号终止等问题。不过，我准备将两块 :ref:`amd_mi50` 都刷了V420的VBIOS。

但是很不幸，虽然这次实践刷入 Pro V420的 VBIOS成功，但是我将 :ref:`amd_mi50` 安装到 :ref:`dell_t5820` 却依然无法启动。Google了一下，AI确实提示 **AMD Radeon Pro V420不在T5820支持列表** ，原因可能是Pro V420是一个特殊的服务器端虚拟化卡。我怀疑Dell T5820只接受workstation graphics (WX/W series)

不过我看到 `Reddit:32GB Mi50, but llama.cpp Vulkan sees only 16GB <https://www.reddit.com/r/LocalLLaMA/comments/1m389gi/comment/n5y7d3d/>`_ 提到有人根据闲鱼上的帖子 `MI50 32G 非卖品 仅限交流 <https://www.goofish.com/item?id=911401293793&ut_sk=1.aEKY6o04+hEDAEU7HhCRBCsM_21407387_1751919723331.copy.detail.911401293793.2207405348468>`_ 提供的2个VBIOS，该贴提到部分主板要关闭CSM

再次尝试
===========

`evilJazz/MI50_32GB_VBIOS.md <https://gist.github.com/evilJazz/14a4c82a67f2c52a6bb5f9cea02f5e13>`_ 上列出了一个从 Apple Radeon Pro VII 32 GB导出的 113-D163A1XT-045 ("vbios3")，虽然有报告说不太稳定，但是这是唯一一个桌面级VBIOS。考虑到 :ref:`dell_t5820` 可能只支持workstation graphics (WX/W series)，所以我还是决定尝试一下:

.. literalinclude:: amd_mi50_flash_vbios/flash_pro_vii_rom
   :caption: 刷入Pro VII的VBIOS

完成后重启系统，检查 ``rocm-smi`` 可以看到新VBIOS下 ``SCLK`` 和 ``MCLK`` 都跃升到 ``1000MHz`` :

.. literalinclude:: amd_mi50_flash_vbios/flash_pro_vii_rom_rocm-smi
   :caption: ``rocm-smi`` 显示刷了Rro VII的VBIOS

但是我采用了 Pro VII 32 GB 依然无法在 :ref:`dell_t5820` 上实现启动。根据 :ref:`dell_t5820_gpu` 排查推测，可能采用 :ref:`amd_mi50_change_vbios_bar_size`

其他
=======

.. note::

   :ref:`amd_firepro_s7150x2` 的GPU核心 ``Tonga`` 和 `AMD FirePro W7100 <https://www.techpowerup.com/gpu-specs/firepro-w7100.c2610>`_ 一致，所以也应该能够刷W7100的BIOS修订后用于 :ref:`dell_t5820` :

   .. literalinclude:: amd_mi50_flash_vbios/flash_s7150x2
      :caption: 通过刷W7100的BIOS将S7150x2改为W7100

参考
======

- `evilJazz/MI50_32GB_VBIOS.md <https://gist.github.com/evilJazz/14a4c82a67f2c52a6bb5f9cea02f5e13>`_ 这篇README写得非常好，我一开始按照gemini指示走了弯路，实际还是需要
- `TechPowerUp: AMD Radeon Pro VII <https://www.techpowerup.com/gpu-specs/radeon-pro-vii.c3575>`_
- `AMD Expands Professional Offerings with AMD Radeon Pro VII Workstation Graphics Card and AMD Radeon Pro Software Updates <https://www.amd.com/en/newsroom/press-releases/2020-5-13-amd-expands-professional-offerings-with-amd-radeon.html>`_
- `AMD Radeon Instinct Mi50 16GB on Linux TESTED | Gaming, Video Editing, Stable Diffusion  <https://www.youtube.com/watch?v=8LnoJBboiT8>`_ 这个油管视频是将MI50 16GB改成Pro VII测试游戏性能，看起来16GB规格是可行的，但是实践发现32GB因为没有Pro VII 32GB规格，强刷16GB规格Pro VII的BIOS会导致无法使用
