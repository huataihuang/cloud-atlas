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

- 配置 ``/etc/buildkit/buildkitd.toml`` :

.. literalinclude:: buildkit_startup/buildkitd.toml
   :language: bash
   :caption: 配置 /etc/buildkit/buildkitd.toml

然后就可以使用 :ref:`nerdctl` 工具执行 ``nerdctl build`` 指令来构建镜像。但是我发现手工启动的 ``buildkitd`` 并没有使用 ``containerd`` 的网络，所以还是需要配置一个 ``buildkit`` 的 systemd 服务，或者(仔细看了readme)在运行参数中添加 ``containd`` 参数::

   By default, the OCI (runc) worker is used. You can set --oci-worker=false --containerd-worker=true to use the containerd worker.

- 重新运行(指定使用conterd worker):

.. literalinclude:: buildkit_startup/buildkitd-containerd
   :language: bash
   :caption: 使用root身份运行buildkitd，并且指定使用 containerd worker

不过，没有解决 :ref:`nerdctl` 中 ``nerdctl build`` 网络不通问题



参考
=======

- `moby/buildkit <https://github.com/moby/buildkit>`_
