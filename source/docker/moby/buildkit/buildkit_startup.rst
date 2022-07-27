.. _buildkit_startup:

===================
BuildKit快速起步
===================

Buildkit是一个以高效、富有表现力和可重复的方式将源代码转换为构建架构的工具包:

- 自动垃圾收集
- 可扩展的前端格式
- 并发的依赖解析
- 高效的指令缓存
- 构建缓存导入/导出
- 嵌套构建作业调用
- 分布式worker
- 多种输出格式
- 可插拔架构
- 无root权限执行

安装
=======

- 从 `buildkit releases <https://github.com/moby/buildkit/releases>`_ 下载最新执行包，解压缩后移动到 ``/usr/bin`` 目录下::

   tar xfz buildkit-v0.10.3.linux-amd64.tar.gz
   cd bin
   sudo mv * /usr/bin/

- 运行(需要先安装和运行 OCI(runc) 和 containerd):

.. literalinclude:: buildkit_startup/buildkitd
   :language: bash
   :caption: 使用root身份运行buildkitd，启动后工作在前台等待客户端连接

然后就可以使用 :ref:`nerdctl` 工具执行 ``nerdctl build`` 指令来构建镜像

参考
=======

- `moby/buildkit <https://github.com/moby/buildkit>`_
