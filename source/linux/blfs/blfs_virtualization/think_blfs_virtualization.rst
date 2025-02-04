.. _think_blfs_virtualization:

=============================================
思考BLFS(Beyond Linux from scratch)虚拟化
=============================================

.. note::

   目前还只是一个构想，逐步完善和实践

我想在 :ref:`lfs` 基础上运行简化部署的 :ref:`qemu` ，不使用 :ref:`libvirt` ，通过非常raw的方式来运行 :ref:`kvm` Virtualization。在BLFS手册中有关于构建 :ref:`qemu` 的指导，但是这个过程可能是比较折腾的。我会在后续探索这个方向，力争在自己的二手旧 :ref:`hpe_dl360_gen9` 运行起一个完整的虚拟化集群

参考
======

- `How to build VM from scratch and make it bootable? <https://www.reddit.com/r/kvm/comments/sh8w45/how_to_build_vm_from_scratch_and_make_it_bootable/>`_
