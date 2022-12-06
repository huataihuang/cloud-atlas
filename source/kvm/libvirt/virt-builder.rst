.. _virt-builder:

===========================
virt-builder快速构建VM工具
===========================

在 :ref:`archlinux_arm_kvm` 遇到一个非常奇怪的问题: ``virt-install`` 安装ARM虚拟机，当内核下载完毕后开始安装就进入CPU 100%打满，并且不启动进入安装界面。似乎就无法启动aarch64架构虚拟机...

``virt-builder`` 提供了一个快速构建虚拟机的方法，也可以用来快速构建 ``aarch64`` 架构的 :ref:`fedora` 虚拟机。所以我决定先尝试构建虚拟机，以验证启动运行。

- 构建 :ref:`fedora` 37 ``aarch64`` 虚拟机:

.. literalinclude:: virt-builder/virt-builder_fedora_37_arm
   :language: bash
   :caption: virt-builder构建Fedora 37 ARM64镜像

- 然后通过 ``--import`` 方式导入镜像运行:

.. literalinclude:: virt-builder/virt-install_fedora_37_arm_import
   :language: bash
   :caption: virt-install 通过import方式导入Fedora 37 ARM64镜像

- `Fedora 37 Server 官方下载 <https://getfedora.org/en/server/download/>`_ 提供了x86_64和ARM版本安装ISO镜像和VM镜像。可以直接使用官方下载的VM镜像采用相同方法导入运行:

.. literalinclude:: virt-builder/virt-install_fedora_37_server_arm_import
   :language: bash
   :caption: virt-install 通过import方式导入官方提供Fedora 37 Server ARM64镜像



参考
=======

- `Virt-builder: Tool to quickly build (and customize) virtual machine images <https://developer.fedoraproject.org/tools/virt-builder/about.html>`_
