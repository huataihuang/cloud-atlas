.. _rocm_quickstart:

======================
``ROCm`` 快速起步
======================

AMD官方提供了主要Linux发行版安装ROCm的方法，我的实践在 :ref:`debian` 上完成

安装
=======

.. literalinclude:: rocm_quickstart/debian_install
   :caption: 在 Debian 上安装 ROCm

.. note::

   执行 ``apt install amdgpu-dkms rocm`` 提示需要下载 ``3GB`` 软件包，并且安装需要 ``36GB`` 空间。

   由于我的根文件系统划分很小，需要有一个大容量空间磁盘来存储，然后构建软连接

   参考 `ROCm on Linux detailed installation overview > Post-installation instructions <https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/post-install.html>`_ 看起来安装目录是 ``/opt/rocm`` ，所以我将整个 ``/opt`` 目录迁移到大容量规格磁盘中，然后建立 ``/opt`` 目录软链接:

   .. literalinclude:: rocm_quickstart/link_opt
      :caption: 将 ``/opt`` 目录迁移到大容量磁盘后建立软链接

   **我发现 nvidia 也是将安装目录存储在 /opt 中，所以其实 nvidia 和 amd 的安装目录可以一起迁移**

安装完成后步骤
==================

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
