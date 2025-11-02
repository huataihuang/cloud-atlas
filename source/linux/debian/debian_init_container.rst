.. _debian_init_container:

===============================
Debian容器精简系统初始化
===============================

采用 :ref:`docker` 官方镜像，通过 :ref:`distrobox_debian` 部署 :ref:`debian` 容器之后，进行基础的开发环境初始化:

- 安装 :ref:`devops` 工具:

.. literalinclude:: debian_init/debian_init_devops
   :caption: 安装初始工具

- 安装gcc以及开发库:

.. literalinclude:: debian_programming/c_grogramming
   :caption: debian的C语言开发环境安装


