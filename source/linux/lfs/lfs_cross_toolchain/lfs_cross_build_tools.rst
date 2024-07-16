.. _lfs_cross_build_tools:

========================================
LFS 交叉编译临时工具
========================================

前面已经完成了交叉工具链，现在可以使用自己构建的交叉工具链来编译一些基本工具。这些基本工具将被安装到最终位置。虽然目前基本操作仍然依赖宿主机的工具，但是链接的时候会使用刚刚安装的库。最后，通过 ``chroot`` 进入环境之后，就可以真正使用这些工具。

.. warning::

   一定要使用 ``lfs`` 用户身份来完成工具编译。如果使用root用户身份进行构建，可能会导致宿主机操作系统破坏。

安装M4
==========

.. literalinclude:: lfs_cross_build_tools/m4
   :caption: 安装m4

.. _m4_make_err_limit.h:

M4编译报错(limits.h)
------------------------

我在 ``make`` 时候遇到报错:

.. literalinclude:: lfs_cross_build_tools/m4_make_err
   :caption: 编译m4报错
   :emphasize-lines: 7,18

这个报错参考 `Problems with  compiling the M4 packet for my LFS system (LFS 10.1)  <https://www.linuxquestions.org/questions/linux-newbie-8/problems-with-compiling-the-m4-packet-for-my-lfs-system-lfs-10-1-a-4175699442/>`_ ，也就是LFS faq中提到的，是由于GCC提供的 ``limits.h`` 没有被包含在Glibc中导致。有两个地方需要修复，分别是 :ref:`lfs_gcc_1` 和 Glibc 。
