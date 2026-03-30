.. _code-server_container:

==============================
code-server容器
==============================

`code-server-deploy-container <https://github.com/coder/deploy-code-server/tree/main/deploy-container>`_ 介绍了Coder团队核心成员 Ben Conant 维护的镜像 ``bencdr/code-server-deploy-container`` 部署容器的方法。根据 `code-server-deploy-container Dockerfile <https://github.com/coder/deploy-code-server/blob/main/Dockerfile>`_ 可以看到，这个镜像是基于 coder 官方核心基础镜像基础上，增加了VS Code设置以及添加了 :ref:`rclone` 同步数据的配置(框架案例)和进一步安装组件的案例。这个部署可以作为今后定制code-server容器的参考。

运行
=======

最初的实践可以从官方Docker镜像 `codercom/code-server官方镜像 <https://hub.docker.com/r/codercom/code-server>`_ 开始:

.. literalinclude:: code-server_container/run
   :caption: 运行 code-server 容器

改进运行
==========

我在 :ref:`ollama_nvidia_a2_gpu_docker` 环境上对上述运行进行修改:

.. literalinclude:: code-server_container/run_ai
   :caption: 运行 code-server 容器


 
参考
======

- `code-server-deploy-container <https://github.com/coder/deploy-code-server/tree/main/deploy-container>`_
