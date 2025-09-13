.. _git_diff:

==================
git diff
==================

.. note::

   本文记录一个简单的实践操作，来生成两个不同分支之间的差异补丁，用于后续在前一个分支上完成patch

我在实践 :ref:`bhyve_nvidia_gpu_passthru_intpin_patch` 发现开发者 ``corvink`` 提供的 `D51892.diff <https://reviews.freebsd.org/file/data/dnnvdlk6cbsbursoniwv/PHID-FILE-s3ttba5veb5qioermjqp/D51892.diff>`_ 实际上是针对 `Backhoff自动化公司 freebsd-src <https://github.com/Beckhoff/freebsd-src/>`_ 的 ``phab/corvink/15.0/nvidia-wip`` 分支，或者FreeBSD官方 ``stable/15`` 分支。

实际上源代码不复杂，也可以用于之前的FreeBSD官方 ``releng/14.3`` 分支。因为我目前还在使用 ``14.3-RELEASE-p2`` ，所以我尝试自己生成 ``diff`` 的patch文件:

- 首先按 :ref:`freebsd_build_from_source` 参考 `26.6.3. Updating the Source <https://docs.freebsd.org/en/books/handbook/cutting-edge/#updating-src-obtaining-src>`_ 根据 ``uname -r`` 获取当前安装的RELEASE，例如 ``14.3-RELEASE`` ，则下载对应的源代码分支:

.. literalinclude:: ../../freebsd/build/freebsd_build_from_source/freebsd_src
   :caption: 获取 freebsd 源代码

- 此时代码分支位于 ``releng/14.3`` ，所以要在这个分支基础上建立一个修订分支 ``releng/14.3-nvidia`` :

.. literalinclude:: git_diff/checkout_new_branch
   :caption: 建立一个修订分支 ``releng/14.3-nvidia``

- 参考 `bhyve: assign a valid INTPIN to NVIDIA GPUs <https://reviews.freebsd.org/D51892>`_ 修订一个 ``usr.sbin/bhyve/amd64/Makefile.inc`` 和增加一个 ``usr.sbin/bhyve/pci_passthru_quirks.c``

- 现在将修改过的文件commit(这样新分支就和老的分支有了区别):

.. literalinclude:: git_diff/commit
   :caption: 提交修改文件

- 完成commit之后，就可以进行两个分支对比，将对比差异写入patch文件，这个patch文件就可以用来修订旧分支:

.. literalinclude:: git_diff/diff
   :caption: 对比分支差异，注意 **旧分支在前，新分支在后才能正确生成差异**

- 最后，如果在生产环境中对旧分支使用补丁文件修正到新分支，则执行:

.. literalinclude:: git_diff/apply
   :caption: 将diff补丁应用到旧分支修正为新分支内容
