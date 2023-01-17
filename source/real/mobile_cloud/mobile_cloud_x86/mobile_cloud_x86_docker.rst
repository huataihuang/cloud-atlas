.. _mobile_cloud_x86_docker:

=========================
X86移动云Docker环境
=========================

采用 :ref:`archlinux_docker` 方式安装Docker:

  - :ref:`pacman` 安装docker
  - 并启动和激活docker
  - 将 自己的账号(huatai)添加到该用户分组，这样就可以无需sudo操作docker

.. literalinclude:: ../../../docker/startup/archlinux_docker/archlinux_install_docker
   :language: bash
   :caption: 在arch linux上安装稳定版本docker
