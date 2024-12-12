.. _lfs_kernel_api_header:

===============================
Linux-6.10.5 API 头文件
===============================

Linux 内核需要导出一个应用程序编程接口 (API) 供系统的 C 运行库 (例如 LFS 中的 Glibc) 使用。这通过净化内核源码包中提供的若干 C 头文件完成。

.. literalinclude:: lfs_kernel_api_header/headers
   :caption: 安装Linux API头文件

我在LFS构建时遇到虚拟机oom杀死，重启以后，因为 :ref:`lfs_cross_build_tools` 的M4编译错误，反过来重新从GCC步骤中补齐limits.h，此时我想重新走一遍，却发现在执行 ``make mrproper`` 时候报错:

.. literalinclude:: lfs_kernel_api_header/make_mrproper_err
   :caption: 执行 ``make mrproper`` 报错

检查 ``Makefile`` 可以看到是 ``include $(srctree)/arch/$(SRCARCH)/Makefile`` 中 ``$(SRCARCH)`` 变量为空导致错误

是什么导致了 ``$(SRCARCH)`` 无法获得呢？

参考 `linux kernel make tag variable <https://stackoverflow.com/questions/50791012/linux-kernel-make-tag-variable>`_ 和 `Vim configuration for Linux kernel development <https://stackoverflow.com/questions/33676829/vim-configuration-for-linux-kernel-development>`_ ，原来内核源代码中 ``scripts/tags.sh`` 提供了定义

但是我发现当前 ``scripts/`` 目录下的 ``.sh`` 文件包括 ``scripts/tags.sh`` 都是空的。我后来重复解压缩(移除目录后重新解压缩)才正常，看来之前可能是其他用户(root?)解压缩文件后，再次用 ``lfs`` 用户解压缩无法覆盖文件?

