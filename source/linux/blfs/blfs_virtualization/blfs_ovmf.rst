.. _blfs_ovmf:

=================
BLFS OVMF
=================

Open Virtual Machine Firmware (OVMF)是在虚拟机内部提供正常UEFI的开源项目，从EDK II代码为基础构建

编译OVMF
===========

.. warning::
   
   `How to build OVMF <https://github.com/tianocore/tianocore.github.io/wiki/How-to-build-OVMF>`_ 没有看懂，EDK II文档也非常古老，暂时没有搞清楚如何从源代码编译OVMF。

   由于没有时间折腾，本文暂停，有待后续再探索...

- 获取 EDK II 主仓库代码 `EDK II Main Repository <https://github.com/tianocore/edk2>`_ 进行编译

.. literalinclude:: blfs_ovmf/ovmf
   :caption: 获取edk2代码并编译X64架构的OVMF

使用OVMF
===========

.. warning::

   我暂时使用从 :ref:`ubuntu_linux` 发行版提供的 ``OVMF_CODE.fd`` ( ``/usr/share/OVMF/OVMF_CODE.fd`` )

- 执行 :ref:`run_debian_gpu_passthrough_in_qemu` :

.. literalinclude:: ../../../kvm/qemu/run_debian_gpu_passthrough_in_qemu/d2l_run_vnc
   :caption: 运行UEFI虚拟机(使用VNC)
   :emphasize-lines: 7

参考
======

- `OVMF FAQ <https://github.com/tianocore/tianocore.github.io/wiki/OVMF-FAQ>`_
- `How to build OVMF <https://github.com/tianocore/tianocore.github.io/wiki/How-to-build-OVMF>`_

  - `Getting Started with EDK II <https://github.com/tianocore/tianocore.github.io/wiki/Getting-Started-with-EDK-II>`_

- `How to run OVMF <https://github.com/tianocore/tianocore.github.io/wiki/How-to-run-OVMF>`_
- `gentoo linux: GPU passthrough with virt-manager, QEMU, and KVM >> Linux Guest <https://wiki.gentoo.org/wiki/GPU_passthrough_with_virt-manager,_QEMU,_and_KVM#Linux_Guest>`_ 简单的使用方法
