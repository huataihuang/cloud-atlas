.. _ubuntu_26.04_install_amdgpu:

=========================================
Ubuntu 26.04安装AMDGPU驱动
=========================================

我在准备 :ref:`podman_compose_ollama_amd_mi50` 前置工作， :ref:`install_amdgpu` 遇到一个问题:

我原本以为和之前 :ref:`install_amdgpu` 一样，从官方下载 ``amdgpu_install`` 的deb包安装以后，通过执行安装会自动通过dkms完成内核模块安装。但是没有想到，根据 ``ollama/ollama:rocm`` 镜像中 :ref:`rocm` 7.2 版本选择安装 amdgpu 实际上是针对 Ubuntu 24.04 系列旧版本内核开发的，此时编译内核模块会报错。

gemini提示Ubuntu 26.04发行版已经提供了amdgpu驱动，可以用开源社区的版本来替代

- 检查物理机是否正确识别到双卡硬件

.. literalinclude:: ubuntu_26.04_install_amdgpu/lspci
   :caption: 检查显卡设备

可以看到

.. literalinclude:: ubuntu_26.04_install_amdgpu/lspci_output
   :caption: 检查显卡识别，并且也显示驱动是 ``amdgpu``

但是，为何 ``lsmod | grep -i amd`` 输出却是空白，显示系统并没有正确加载显卡驱动

gemini提示: 由于 AMD Instinct MI50 属于相对早期的 CDNA/Vega 架构，部分现代 Linux 发行版内核默认可能没有对旧版 Vega 算力加速节点（kfd）做完全开箱即用的自动激活

- 手工尝试激活 ``amdgpu`` 内核模块:

.. literalinclude:: ubuntu_26.04_install_amdgpu/modprobe
   :caption: modprobe

果然手工加载是有效的，现在 ``lsmod | grep -i amd`` 输出如下:

.. literalinclude:: ubuntu_26.04_install_amdgpu/lsmod_output
   :caption: 可以看到系统加载了amdgpu模块

检查 ``sudo dmesg | grep -i amdgpu`` 日志如下:

  - ``BAR 0 ... can't assign; no space`` / ``Not enough PCI address space for a large BAR`` :两张 MI50 默认尝试申请超大 BAR（Base Address Register，即 32GB 完整显存映射空间），而主板 BIOS 的 PCI 寻址空间不足
  - ``[drm] Detected VRAM RAM=32752M, BAR=256M`` 并且 ``32752M of VRAM memory ready`` 驱动会自动降级使用 256MB 的标准 BAR 窗口，通过 GART 机制正常调度全部 32GB 显存，两张卡都已经 100% 成功点亮
  - ``Cannot find any crtc or sizes`` : MI50 是纯计算卡（Instinct 系列），没有物理显示输出接口（无 HDMI/DP 接口），所以驱动找不到显示器（CRTC） **不过好像还是有minidisplay输出的，存疑**

- (可选)设置开机自动加载 ``amdgpu`` :

.. literalinclude:: ubuntu_26.04_install_amdgpu/modules
   :caption: 配置加载 ``admgpu``

.. note:: 

   我发现没有自动加载 ``amdgpu`` 是因为最初执行了闭源驱动安装，自动在 ``/etc/modprobe.d/blacklist.conf`` 添加了黑名单:

   .. literalinclude:: ubuntu_26.04_install_amdgpu/blacklist.conf
      :caption: 由于安装了闭源驱动导致 ``amdgpu`` 被屏蔽

   我卸载了AMD官方的闭源驱动以后，这个配置文件残留没有清理，导致了后续配置一直没有生效，虽然 ``modprobe amdgpu`` 能手工加载，但是操作系统启动， :ref:`systemd` 读取 ``/etc/modules-load.d/mi50.conf`` 就没有效果了。真是一个乌龙...
