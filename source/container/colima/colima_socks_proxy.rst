.. _colima_socks_proxy:

===========================
Colima Socks 代理
===========================

.. note::

   之前 :ref:`colima_proxy` 设置还是太复杂且记录不清晰，我在2026年5月重新构建Colima工作环境时，改为采用 :ref:`ssh_tunneling_dynamic_port_forwarding` 构建socks代理。本文为实践记录，比之前的方式更简洁更有效。

物理主机
=========

物理主机 :ref:`macos` 上配置 ``~/.ssh/config`` 设置通过墙外VM的ssh连接构件DynamicForward:

.. literalinclude:: ../../infra_service/ssh/ssh_tunneling_dynamic_port_forwarding/ssh_config_tunning
   :caption: 设置SSH动态端口转发
   :emphasize-lines: 12-21

在物理主机上执行 ``ssh MyProxy`` 建立ssh tunnel

虚拟机注入proxy环境变量
========================

:ref:`colima_config` 提供了一种向虚拟机注入环境变量的方式，可以通过修改 ``~/.colima/_template/default.yaml`` 设置虚拟机中 ``env`` ，这样虚拟机的操作系统 :ref:`curl` 以及 :ref:`apt` 就会走代理方式 :ref:`across_the_great_wall` :

.. literalinclude:: colima_config/default.yaml
   :caption: 修订 ``default.yaml``
   :start-after: # [start:env-proxy]
   :end-before: # [end:env-proxy]
   :emphasize-lines: 4-7

.. note::

   上述Colima环境变量注入是对VM操作系统的调整，但是 :ref:`containerd` 和 :ref:`docker` 需要通过两种方式传递该环境变量:

   - :ref:`buildkit` 需要明确的 ``--build-arg`` 参数，或者 BuildKit 守护进程的运行参数来获得这个代理设置
   - ``dockerd`` 和 :ref:`containerd` 同样需要守护进程的运行参数来获知这个代理设置，这样才能正确拉取镜像

BuildKit代理
==============

官方推荐的做法，不需要修改任何底层配置文件。BuildKit 允许你在执行构建时，通过 ``--build-arg`` 将宿主机的代理作为参数显式传递给构建沙盒:

.. literalinclude:: colima_socks_proxy/nerdctl_build
   :caption: 直接传递 ``--build-arg`` 参数给 ``nerdctl build``

.. note::

   ``HTTP_PROXY`` 、 ``HTTPS_PROXY`` 和 ``ALL_PROXY`` 是 BuildKit 内置的特权内置参数（Built-in Build Args）。不需要在 Dockerfile 里写 ``ARG HTTP_PROXY`` ，BuildKit 会自动识别并在构建容器内的 RUN 执行阶段将其临时设为环境变量，构建完成后自动擦除，不会将敏感的代理 IP 写入最终的镜像层中。

配置方法(一劳永逸)
--------------------

如果不想每次敲命令都带上一长串 ``--build-arg`` ，则需要进入 Colima 虚拟机内部( ``colima ssh`` )，去修改 BuildKit 的守护进程配置。

- 在虚拟机内部执行以下命令为 ``BuildKit`` 服务添加运行环境变量:

.. literalinclude:: colima_socks_proxy/buildkit_service
   :caption: 为 ``BuildKit`` 服务添加运行环境变量

- 在 ``proxy.conf`` 中配置如下(这里 ``192.168.5.2`` 是Colima宿主机网关):

.. literalinclude:: colima_socks_proxy/proxy.conf
   :caption: ``proxy.conf`` 中配置运行参数

- 然后重新启动 ``BuildKit`` 服务

.. literalinclude:: colima_socks_proxy/buildkit_restart
   :caption: 重启buildkit服务

Containerd代理
================

除了 ``build`` 阶段需要通过代理，镜像拉取也需要通过代理，否则 :ref:`containerd` 也会出现连接报错。同样通过 ``colima ssh`` 登陆到虚拟机内部，为 ``containerd`` 配置代理:

- 在虚拟机内部执行以下命令为 ``Containerd`` 服务添加运行环境变量:

.. literalinclude:: colima_socks_proxy/containerd_service
   :caption: 为 ``Containerd`` 服务添加运行环境变量

- 在 ``proxy.conf`` 中配置如下(和上文配置 ``BuildKit`` 是一样的):

.. literalinclude:: colima_socks_proxy/proxy.conf
   :caption: ``proxy.conf`` 中配置运行参数

- 然后重启 ``Containerd`` 服务

.. literalinclude:: colima_socks_proxy/containerd_restart
   :caption: 重启Containerd服务

容器内部代理
=============

wget/curl
-----------

在执行 ``nerdctl build`` 时，虽然上述BuildKit代理和Containerd代理能够让容器镜像下载丝滑完成，但是当 ``Dockerfile`` 中需要安装大量应用时，常常会被防火长城阻塞导致安装失败。此时需要解决构建容器内部注入 ``socks5h`` 代理。

详细的方法可以参考 :ref:`buildkit_proxy` ，我为了每次都自动将代理配置注入容器，采用了全局网络代理配置: 修订Colima虚拟机内部的 ``/etc/buildkit/buildkitd.toml`` 配置:

.. literalinclude:: ../../docker/moby/buildkit/buildkit_proxy/buildkitd.toml
   :caption: 在 buildkitd.toml 添加代理设置
   :emphasize-lines: 3-8,12-17

然后重启BuildKit守护进程

.. literalinclude:: ../../docker/moby/buildkit/buildkit_proxy/restart_buildkit
   :caption: 重启BuildKit

上述配置能够让容器内部的 :ref:`curl` :ref:`wget` 都自动使用代理配置。

apt
-----

需要注意， ``apt-get`` 虽然支持 ``socks5h://`` 但是不能通过环境变量直接使用，而是要配置 ``/etc/apt/apt.conf.d/proxy.conf`` 设置专属配置。详见 :ref:`apt_proxy` :

.. literalinclude:: ../../linux/ubuntu_linux/admin/apt/proxy.conf
   :caption: 配置APT代理 ``/etc/apt/apt.conf.d/proxy.conf``

为了能够在 ``nerdctl build`` 使得上述配置生效，也就是在build过程中容器内apt能够走socks代理，需要在Dockerfile的开头添加一个写入配置的命令:

.. literalinclude:: colima_socks_proxy/Dockerfile
   :caption: 在Dockerfile中添加apt代理配置 
   :emphasize-lines: 4-5
