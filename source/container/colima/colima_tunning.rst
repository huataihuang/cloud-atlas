.. _colima_tunning:

===================
Colima 优化
===================

我在 :ref:`mbp15_late_2013` 旧笔记本上只能使用 macOS Big Sur v11，安装的Colima运行容器感觉有以下不足:

- 磁盘IO缓慢，在执行一些IO密集的操作时感觉进程时不时D住
- 编译 :ref:`sphinx_doc` 时耗时很长

.. literalinclude:: colima_tunning/sphinx_make
   :caption: sphinx文档在colima容器中make耗时

:ref:`apple_virtualization`
===============================

因为硬件限制，这个11年前的旧笔记本只能运行macOS v11，虽然macOS v11已经内置了 :ref:`apple_virtualization` ，但是 :ref:`lima` 使用的 ``EFILoader`` 功能只有macOS v13开始提供，所以Lima官方文档 `Lima VM types <https://lima-vm.io/docs/config/vmtype/>`_ 申明在 macOS v13 提供 ``VZ`` 选项。

不过， `GitHub: lima-vm/lima Support for Virtualization.framework #923 <https://github.com/lima-vm/lima/discussions/923>`_ 讨论中，lima的vz核心开发解释了 :ref:`intro_vz` 是支持macOS Big Sur的。我理解 :ref:`lima` 需要macOS 13的高级特性所以放弃了低版本macOS支持，所以需要自己定制 :ref:`vz` 来替换 Lima 核心 实现Big Sur上使用 :ref:`apple_virtualization` VZ性能优化。

``hvf`` 加速
===============

macOS Big Sur v11 中运行的 :ref:`qemu` 会自动使用 ``hvf`` 加速( ``qemu`` 运行参数中有 ``-machine q35,accel=hvf`` )。根据 :ref:`qemu` 文档 `qemu Features/HVF <https://wiki.qemu.org/Features/HVF>`_ :

- ``hvf`` 是一个稳定功能，但是缺乏一些特性
