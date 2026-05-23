.. _buildkit_proxy:

=======================
BuildKit代理设置
=======================

在 :ref:`colima_images` 构建时，我通过 :ref:`colima_socks_proxy` 解决镜像下载问题。不过，实际上构建运行的容器也需要配置代理，以便能够无障碍安装开发软件。

虽然可以为每个容器手工配置代理，但是如果能够在 ``docker build`` 时自动注入和设置好代理环境变量，那么会方便后续的维护工作。这个步骤可以通过 ``BuildKit`` 实现。

单次构建动态注入
====================

在执行 ``nerdctl build`` 命令:

.. literalinclude:: ../../../container/colima/images/debian_tini_image/ssh/build_debian-ssh-tini_image
   :caption: 构建镜像命令

修订为

.. literalinclude:: buildkit_proxy/build_debian-ssh-tini_image
   :caption: 增加注入环境变量
   :emphasize-lines: 4-6

配置全局网络代理
==================

每次 ``nerdctl build`` 都传递代理参数比较麻烦，所以可以配置BuildKit默认的"全局构建网络代理"

.. literalinclude:: buildkit_proxy/vi_buildkitd
   :caption: 编辑 ``/etc/buildkit/buildkitd.toml``

在配置文件中加入 ``[worker.oci]`` 或 ``[worker.containerd]`` (取决于 Colima 当前使用的 worker 类型，通常在 Colima 中两者都写上最稳妥) 的环境变量配置:

.. literalinclude:: buildkit_proxy/buildkitd.toml
   :caption: 在 buildkitd.toml 添加代理设置
   :emphasize-lines: 3-8,12-17

然后重启BuildKit守护进程

.. literalinclude:: buildkit_proxy/restart_buildkit
   :caption: 重启BuildKit

.. note::

   在 Go 语言编写的底层组件（BuildKit / nerdctl）中，环境变量对大小写极其敏感。

   - 很多 Linux 工具（如 curl、wget）能同时识别小写 ``all_proxy`` 和大写 ``ALL_PROXY``
   - BuildKit 的内置构建参数只严格识别 **大写** ``HTTP_PROXY`` / ``HTTPS_PROXY`` / ``ALL_PROXY``

   如果传入了小写的 ``--build-arg all_proxy=...`` ，BuildKit 会直接将其视作普通的自定义参数，从而失去 "构建期自动注入、构建完自动擦除" 的特权，导致容器内部依然没有网络。因此，请务必全部使用大写。

