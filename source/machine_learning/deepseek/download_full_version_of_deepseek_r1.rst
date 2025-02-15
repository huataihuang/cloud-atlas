.. _download_full_version_of_deepseek_r1:

=====================================
下载满血版DeepSeek R1
=====================================

HuggingFace下载方法
=====================

.. note::

   实际上我们个人很少有本地大规模GPU集群硬件，所以通常无法也不需要运行完整的DeepSeek大模型文件。一种适合小型企业和个人使用大模型文件是使用 :ref:`gguf` 。我在 :ref:`deploy_deepseek-r1_locally_cpu_arch` 实践时，其实是下载 :ref:`gguf` 来完成的，并不是本文这里完全版本。具体下载方法可以使用 :ref:`git_clone_subdirectory` 或者直接下载文件(数量不多但非常巨大)

.. note::

   通过git下载DeepSeek需要使用 :ref:`git-lfs`

- :ref:`debian` 安装 :ref:`git-lfs` :

.. literalinclude:: ../../devops/git/git-lfs/apt_install_git-lfs
   :caption: 在debian安装git-lfs

- 下载(建议使用 :ref:`tmux` 保持 :ref:`ssh` 远程访问会话):

.. literalinclude:: download_full_version_of_deepseek_r1/git_clone_deepseek
   :caption: 下载完整版deepseek

直接使用wget
================

由于 :ref:`deploy_deepseek-r1_locally_cpu_arch` 需要下载的文件只有15个，所以直接下载也行。不过需要注意 ``huggingface.co`` 官网已经被GFW屏蔽，需要搭建梯子:

.. literalinclude:: download_full_version_of_deepseek_r1/wget
   :caption: 使用wget下载GUFF(8位量化)文件

参考
=======

- `How to download the full version of DeepSeek R1? <https://www.reddit.com/r/LocalLLaMA/comments/1iigodb/how_to_download_the_full_version_of_deepseek_r1/>`_
