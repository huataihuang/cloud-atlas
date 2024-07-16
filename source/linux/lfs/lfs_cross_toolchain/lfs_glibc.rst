.. _lfs_glibc:

==================
LFS Glibc-2.39
==================

.. literalinclude:: lfs_glibc/build
   :caption: 安装Glibc

.. note::

   文档中提到 『有报告称该软件包在并行构建时可能失败，如果发生了这种情况，加上 -j1 选项重新执行 make 命令。』

   我第一次编译没有问题，但是再次编译遇到显示找不到某个文件 ``ld: cannot find -lgcc_s: No such file or directory`` :

   .. literalinclude:: lfs_glibc/make_err

.. warning::

   确认新工具链的各基本功能 (编译和链接) 能如我们所预期的那样工作。执行以下命令进行完整性检查

   .. literalinclude:: lfs_glibc/check_toolchain
      :caption: 检查新工具链基本功能(编译和链接)

   输出应该类似:

   .. literalinclude:: lfs_glibc/check_toolchain_output
      :caption: 检查新工具链基本功能(编译和链接)输出信息
