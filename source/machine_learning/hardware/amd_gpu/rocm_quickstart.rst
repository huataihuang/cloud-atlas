.. _rocm_quickstart:

======================
``ROCm`` 快速起步
======================

AMD官方提供了主要Linux发行版安装ROCm的方法，我的实践在 :ref:`debian` 上完成:

.. literalinclude:: rocm_quickstart/debian_install
   :caption: 在 Debian 上安装 ROCm

.. note::

   执行 ``apt install amdgpu-dkms rocm`` 提示需要下载 ``3GB`` 软件包，并且安装需要 ``36GB`` 空间。

   由于我的根文件系统划分很小，需要有一个大容量空间磁盘来存储，然后构建软连接

   参考 `ROCm on Linux detailed installation overview > Post-installation instructions <https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/post-install.html>`_ 看起来安装目录是 ``/opt/rocm`` ，所以我将整个 ``/opt`` 目录迁移到大容量规格磁盘中，然后建立 ``/opt`` 目录软链接:

   .. literalinclude:: rocm_quickstart/link_opt
      :caption: 将 ``/opt`` 目录迁移到大容量磁盘后建立软链接

   **我发现 nvidia 也是将安装目录存储在 /opt 中，所以其实 nvidia 和 amd 的安装目录可以一起迁移**

下载软件包时间需要2小时，待续...

参考
======

- `ROCm™ Software 6.3.2 > Quick start installation guide <https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html#rocm-install-quick>`_
