.. _git_clone_subdirectory:

==========================
git clone仓库指定子目录
==========================

有时候，我们仅仅需要git代码仓库的一部分，例如一个子目录的数据。

我在 :ref:`deploy_deepseek-r1_locally_cpu_arch` 遇到这个问题，我只需要 ``unsloth/DeepSeek-R1-GGUF`` 仓库中的一个子目录 ``DeepSeek-R1-Q8_0`` 数据来部署满血版(8位量化)DeepSeek 该如何避免clone整个巨大的git仓库呢?

主要有3种方法:

- 使用 sparse checkout ，这是最常用的方法
- 使用 git 归档
- 使用 partial clone (需要Git 2.19+)

.. note::

   我最终因为下载文件量不多，并且我需要通过阿里云服务器中转，所以还是直接采用 :ref:`wget` 完成，本文作为后续参考

Sparse Checkout
=================

使用稀疏检出(sparse checkout)可以只check out某个部分工作目录，例如对于大型仓库，可能只需要部分子目录:

以下举例 https://huggingface.co/unsloth/DeepSeek-R1-GGUF 仓库下的子目录 ``DeepSeek-R1-Q8_0`` :

.. literalinclude:: git_clone_subdirectory/git_sparse_checkout
   :caption: 使用git的 ``sparse checkout`` clone出部分目录

使用git archive
================

使用 ``git archive`` 命令可以对某个子目录进行归档( ``tar`` 格式)，所以通过管道 ``|`` 加上 ``tar`` 命令解包就可以完整clone出一个子目录:

.. literalinclude:: git_clone_subdirectory/git_archive
   :caption: 通过 ``git archive`` 来获得子目录

部分clone(需要Git 2.19+)
==========================

部分clone功能可以只fetch需要的对象，虽然这个方法不如 sparse checkout 精确，但是减少了传输的数据量

.. literalinclude:: git_clone_subdirectory/git_partial_clone
   :caption: 部分clone

参考
========

- `How to Clone Only a Subdirectory of a Git Repository? <https://www.geeksforgeeks.org/how-to-clone-only-a-subdirectory-of-a-git-repository/>`_
- `How do I clone a subdirectory only of a Git repository? <https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository>`_
- `Clone Only a Subdirectory of a Git Repository <https://www.baeldung.com/ops/git-clone-subdirectory>`_
