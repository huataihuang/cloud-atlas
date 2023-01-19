.. _build_kind:

=================
编译Kind
=================

本文尝试使用 kind Git仓库最新源代码编译，以便能够从修复 :ref:`debug_mobile_cloud_x86_kind_create_fail` 构建包含 ``zfs`` 工具的镜像

.. note::

   我清理掉了所有本地kind镜像，从最初开始

- 下载kind源代码并进行编译:

.. literalinclude:: build_kind/build_kind_from_git_source
   :language: bash
   :caption: 从kind的git源代码编译
