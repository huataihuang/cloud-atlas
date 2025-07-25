.. _bhyve_intel_gpu_passthru:

===============================================
在bhyve中实现Intel GPU passthrough
===============================================

.. note::

   ``bhyve`` 对 Intel GPU passthrough 支持非常好，简单配置就能够实现Intel GPU直通给虚拟机使用，方便构建机器学习环境。远比 :ref:`bhyve_nvidia_gpu_passthru` 方便很多，可见Intel对开源的支持力度。

我在 :ref:`bhyve_nvidia_gpu_passthru` 实践中了解到对于 :ref:`nvidia_gpu` 是需要对 ``bhyve`` 打补丁的，不过根据网上的资料，intel GPU似乎是原生支持，没有这么复杂。

当然，我没有独立的Intel显卡，但是我的组装电脑 :ref:`nasse_c246` 配置的 :ref:`xeon_e-2274g` ，微处理器是 ``Cofee Lake`` （也就是俗称的第八代)，内置了 :ref:`intel_uhd_graphics_630` 。虽然图形性能非常弱，用于 :ref:`machine_learning` 也非常拉胯。但是，只要能验证方案可行也是有价值的。

根据intel `OpenVINO System Requirements <https://docs.openvino.ai/2025/about-openvino/release-notes-openvino/system-requirements.html>`_ 资料，是支持 ``6th - 14th generation Intel® Core™ processors`` 以及 ``Intel® UHD Graphics``

我的构想:

- 通过bhyve passthru将host主机的Intel UHD graphics 630直通给ubuntu虚拟机，看看能否实现正常运行
- 安装Intel OpenVINO，尝试 :ref:`openvino_genai`

  - :ref:`llama` 官网 `llama.cpp for SYCL <https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/SYCL.md>`_ 提到使用Intel oneAPI支持的GPU是Intel Arc GPU，需要11代处理器才支持，所以llama直接使用Intel原生oneAPI这条路走不通
  - `Supported APIs for Intel® Graphics <https://www.intel.com/content/www/us/en/support/articles/000005524/graphics.html>`_ 显示Intel UHD 630支持 vulkan 1.3 ，看起来 `llama build: Vulkan <https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#vulkan>`_ 能够驱动

- 在 :ref:`nasse_c246` 调整Intel GPU的共享内存，尽可能多分配，尝试 :ref:`ollama` 驱动大模型推理

安装 :ref:`vm-bhyve`
======================

.. note::

   使用 :ref:`vm-bhyve` 作为管理器来完成部署

- 安装 ``vm-bhyve``

.. literalinclude:: ../vm-bhyve/install_vm-bhyve
   :caption: 安装 ``vm-bhyve``

- 创建 ``vm-bhyve`` 使用的存储:

.. literalinclude:: ../vm-bhyve/zfs
   :caption: 创建虚拟机存储数据集

- 在 ``/etc/rc.conf`` 中设置虚拟化支持:

.. literalinclude:: ../vm-bhyve/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 支持虚拟化

- 在 ``/boot/loader.conf`` 添加:

.. literalinclude:: ../vm-bhyve/loader.conf
   :caption: ``/boot/loader.conf``

- 初始化:

.. literalinclude:: ../vm-bhyve/init
   :caption: 初始化

PCI passthru
===============

- 检查 PCI 设备:

.. literalinclude:: ../vm-bhyve/vm_passthru
   :caption: 检查可以passthrough的设备

- 输出显示:

.. literalinclude:: bhyve_intel_gpu_passthru/vm_passthru_output
   :caption: 输出显示 Intel UHD Graphics P630

- 配置 ``/boot/loader.conf`` 屏蔽掉需要passthru的Intel UHD Graphics P630 ``0/2/0`` :

.. literalinclude:: bhyve_intel_gpu_passthru/loader.conf
   :caption: 屏蔽掉 Intel UHD Graphics P630 ``0/2/0`` （另一个 ``1/0/0`` 是 :ref:`tesla_p10` )

- 重启系统屏蔽Host主机使用 ``Intel UHD Graphics P630``

配置
=======

- 配置 ``/zdata/vms/.templates/x-vm.conf`` (修订使用 ``0/2/0`` 作为 ``passthru`` ，以及使用 ``tap1`` 作为网络接口, VNC使用5901端口):

.. literalinclude:: bhyve_intel_gpu_passthru/x-vm.conf
   :caption: 模版配置 ``/zdata/vms/.templates/x-vm.conf``

- 创建虚拟机 ``idev`` :

.. literalinclude:: bhyve_intel_gpu_passthru/create_vm
   :caption: 创建虚拟机 ``idev``

- 安装ubuntu:

.. literalinclude::  bhyve_intel_gpu_passthru/vm_install
   :caption: 安装虚拟机

**非常顺利** ， ``没有出现`` :ref:`bhyve_nvidia_gpu_passthru` 一旦passthru NVIDIA GPU就卡住bhyve虚拟机启动的问题。

重启安装好的 ``idev`` 虚拟机，进入虚拟机内部检查 ``lspci`` 输出可以看到 ``Intel UHD Graphics P630`` GPU正确passthru给了虚拟机使用:

.. literalinclude:: bhyve_intel_gpu_passthru/lspci
   :caption: 虚拟机内部 ``lspci`` 检查输出
   :emphasize-lines: 2

安装
========
