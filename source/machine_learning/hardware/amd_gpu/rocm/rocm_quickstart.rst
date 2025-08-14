.. _rocm_quickstart:

======================
``ROCm`` 快速起步
======================

AMD官方提供了主要Linux发行版安装ROCm的方法，我的实践在 :ref:`debian` 上完成

安装
=======

RCOm安装
----------

- :ref:`debian` 12 系统安装方法:

.. literalinclude:: rocm_quickstart/debian_install
   :caption: 在 Debian 上安装 ROCm

.. note::

   执行 ``apt install amdgpu-dkms rocm`` 提示需要下载 ``3GB`` 软件包，并且安装需要 ``36GB`` 空间。

   由于我的根文件系统划分很小，需要有一个大容量空间磁盘来存储，然后构建软连接

   参考 `ROCm on Linux detailed installation overview > Post-installation instructions <https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/post-install.html>`_ 看起来安装目录是 ``/opt/rocm`` ，所以我将整个 ``/opt`` 目录迁移到大容量规格磁盘中，然后建立 ``/opt`` 目录软链接:

   .. literalinclude:: rocm_quickstart/link_opt
      :caption: 将 ``/opt`` 目录迁移到大容量磁盘后建立软链接

   **我发现 nvidia 也是将安装目录存储在 /opt 中，所以其实 nvidia 和 amd 的安装目录可以一起迁移**

- :ref:`ubuntu_linux` 系统安装方法需要区分 24.04 和 22.04，我的实践是在 :ref:`bhyve_amd_gpu_passthru` :ref:`bhyve` 中运行 Ubuntu 24.04，安装如下:

.. literalinclude:: rocm_quickstart/ubuntu_24.04_install
   :caption: Ubuntu 24.04 安装 ROCm

.. note::

   如果安装包不在 ``/tmp/`` 目录，例如在用户自己的home目录下，执行 ``sudo apt install xxx.deb`` 会报错:

   .. literalinclude:: rocm_quickstart/deb_install_error
      :caption: 安装提示 ``_apt`` 用户不能访问的权限错误

   原因是 "以 root 身份未在沙盒环境下下载文件，用户 ``_apt`` 无法访问" 。apt 软件包管理系统出于安全考虑，尤其是在 "沙盒" 环境中下载和验证软件包时，会使用专用的非特权用户 ``_apt`` 。上述报错通常发生在 ``.deb`` 文件位于非全局可读目录（例如用户的主目录或 "下载" 目录）时。

.. note::

   安装提示 "下载需要 4,365 MB，另外需要 25.3 GB 附加安装空间"，所以我需要先扩容虚拟机磁盘空间:

   我检查发现原来 :ref:`bhyve_ubuntu` 我配置的是稀疏卷(60G)，但是安装的系统只分配了一半的磁盘空间，所以我执行 :ref:`bhyve_ubuntu_extend_ext4_on_lvm`

AMDGPU驱动安装
------------------

.. note::

   AMD GPU驱动是ROCm的底层驱动和运行依赖

   对于 :ref:`amd_container_toolkit` :

   - Host主机安装 AMDGPU 驱动
   - 容器内部安装 ROCm

- 安装AMDGPU驱动: 

.. literalinclude:: rocm_quickstart/amdgpu_driver_install
   :caption: Ubuntu 24.04 安装 amdgpu 驱动

- 驱动安装完成后，在host主机上可以看到加载了 ``amdgpu`` 内核模块( ``lsmod | grep amd`` ):

.. literalinclude:: rocm_quickstart/lsmod
   :caption: 检查内核模块

可以通过 :ref:`dkms` 检查状态来获知驱动是否安装完成:

.. literalinclude:: rocm_quickstart/dkms
   :caption: 检查 ``dkms`` 状态

输出显示:

.. literalinclude:: rocm_quickstart/dkms_amdgpu_output
   :caption: 检查 ``dkms`` 状态可以看到amdgpu驱动模块

- 检查 ``rocminfo`` 输出中包含如下信息:

.. literalinclude:: rocm_quickstart/rocminfo_gfx906_output
   :caption: ``rocminfo`` 信息中包含显卡GPU信息

可以看到我的 :ref:`amd_radeon_instinct_mi50` 显示为 ``gfx906``

- 检查GPU是否检测到(这里遇到了异常)

.. literalinclude:: rocm_quickstart/clinfo
   :caption: 执行 ``clinfo`` 检查GPU是否列出

输出正常显示了 ``Platform Name`` 和 ``Board Name`` ，但是很不幸卡住了输出，最后出现了 ``GPU Hang`` 报错:

.. literalinclude:: rocm_quickstart/clinfo_output
   :caption: 执行 ``clinfo`` 检查出现GPU Hang报错
   :emphasize-lines: 8,9

异常问题在后续排查

.. note::

   到这里为止，就可以尝试 :ref:`ollama_amd_gpu` 

异常排查
============

虽然看上去成功安装了 ``ROCm`` 和  ``AMDGPU driver`` ，但是我发现 ``rocm-smi`` 输出显示没有可用的AMD GPU:

.. literalinclude:: rocm_quickstart/rocm-smi_no_gpu
   :caption: ``rocm-smi`` 显示没有可用AMD GPU

- 检查 ``dmesg | grep amdgpu`` 发现初始化异常，通过完整的 ``dmesg`` 显示，似乎 ``atom_bios`` （看起来是bhyve模拟的bios存在问题不能支持 ``amdgpu`` )

.. literalinclude:: rocm_quickstart/dmesg_amdgpu_error
   :caption: 检查系统日志发现AMD GPU初始化失败
   :emphasize-lines: 35,36

看起来驱动初始化异常，可能原因(可能性从高到低):

  - :ref:`bhyve_amd_gpu_passthru` 对这款 :ref:`amd_radeon_instinct_mi50` 驱动对虚拟化支持存在问题
  
    - 可能需要裸物理主机安装一个Ubuntu来对比验证
    - 可能需要再部署一个 :ref:`lfs` 来对比Linux环境 :ref:`iommu` :ref:`ovmf_gpu_nvme`

  - AMDGPU driver可能需要降级到低版本来支持旧GPU
  - :ref:`amd_radeon_instinct_mi50` 硬件问题

我看到Reddit上的一个帖子 `Mi50 32gb (Working config, weirdness and performance) <https://www.reddit.com/r/LocalLLaMA/comments/1mi5s6w/mi50_32gb_working_config_weirdness_and_performance/>`_ 可以正常使用ROCm和AMDGPU驱动(非虚拟机)

- **这个方法已经验证没有解决我的问题** PROXMOX论坛帖子 `AMD GPU firmware/bios missing? amdgpu fatal error <https://forum.proxmox.com/threads/amd-gpu-firmware-bios-missing-amdgpu-fatal-error.134739/>`_ 提出了通过安装 ``firmware-amd-graphics`` 来解决。不过这个firmware是私有软件，我直接在Ubuntu中执行 ``apt install firmware-amd-graphics`` 显示不存在(PROXMOX提供的虚拟机可能已经内置提供了软件仓库)

上述帖子提供了手工下载Firmware的方法: 在 `debian firmware-nonfree <http://ftp.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/>`_ 提供下载:

.. literalinclude:: rocm_quickstart/firmware-amd-graphics
   :caption: 手工安装 firmware-amd-graphics

.. warning::

   我发现上述手工安装的 firmware 实际上在之前安装 amdgpu driver 已经安装在 ``/lib/firmware/amdgpu`` 目录下了

   但是比较奇怪，在 ``/lib/firmware/amdgpu`` 目录下似乎是 ``.zst`` 后缀的压缩文件，例如 ``yellow_carp_vcn.bin.zst`` ; 而 ``firmware-amd-graphics/usr/lib/firmware/amdgpu/`` 目录下是解压缩的文件，例如 ``yellow_carp_vcn.bin``

   我尝试了上述方法，没有解决问题，报错依旧

安装完成后步骤(归档)
======================

.. note::

   以前的实践笔记，有些步骤可能不再需要，例如 ``/etc/ld.so.conf.d/`` 目录下现在安装软件包会自动添加 ``10-rocm-opencl.conf`` 和 ``20-amdgpu.conf``

- 配置系统链接器为ROCm应用指明查找共享目标文件 ``.so`` 位置:

.. literalinclude:: rocm_quickstart/ldconfig
   :caption: 配置 ``ldconfig``

- 配置 ROCm 执行文件路径，有以下两种方法(使用一个即可):

  - ``update-alternatives`` 可以用来管理多个程序版本(当前 :ref:`debian` 12 已经具备)
  - ``environment-modules`` 是shell工具用于简化初始化，可以使用module文件来修改会话的环境

这里使用 ``update-alternatives`` :

.. literalinclude:: rocm_quickstart/update-alternatives
   :caption: 使用 ``update-alternatives`` 显示所有的ROCm命令

输出显示:

.. literalinclude:: rocm_quickstart/update-alternatives_output
   :caption: 使用 ``update-alternatives`` 显示ROCm的输出

如果安装了多个 ``ROCm`` 版本，则使用以下命令切换版本:

.. literalinclude:: rocm_quickstart/update-alternatives_config
   :caption: 使用 ``update-alternatives`` 切换ROCm的版本

- 验证内核模块驱动的安装:

.. literalinclude:: rocm_quickstart/dkms
   :caption: 执行 ``dkms`` 检查安装的内核模块驱动

输出显示主机安装了 AMD 和 NVIDIA 的模块驱动:

.. literalinclude:: rocm_quickstart/dkms_output
   :caption: 执行 ``dkms`` 检查安装的内核模块驱动，这里可以看到AMD和NVIDIA驱动

- 输出 ``LD_LIBRARY_PATH`` ，我这里修订 ``/etc/profile`` 添加:

.. literalinclude:: rocm_quickstart/profile
   :caption: 设置 ``LD_LIBRARY_PATH``

- 验证 ROCm 安装:

.. literalinclude:: rocm_quickstart/rocminfo
   :caption: 执行 ``rocminfo``

输出:

.. literalinclude:: rocm_quickstart/rocminfo_output
   :caption: 执行 ``rocminfo``


参考
======

- `ROCm™ Software 6.3.2 > Quick start installation guide <https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html#rocm-install-quick>`_
- `ROCm™ Software 6.3.2 > Post-installation instructions <https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/post-install.html>`_
- `Instinct MI50 on consumer hardware <https://www.reddit.com/r/ROCm/comments/1kwirmw/instinct_mi50_on_consumer_hardware/>`_
