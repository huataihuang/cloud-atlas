.. _run_hyperkit:

===========================
运行HyperKit
===========================

HyperKit是一个具有hyperisor能力的工具集，包含了基于 :ref:`xhyve`/bhyve (轻量级虚拟机和容器部署) 的完整hypervisor。HyperKit设计成上层组件诸如 `VPNKit <https://github.com/moby/vpnkit>`_ 和 `DataKit <https://github.com/moby/datakit>`_ 的接口。

.. note::

   `VPNKit <https://github.com/moby/vpnkit>`_ 是一个工具和服务集合用于帮助HyperKit虚拟机和主机VPN配置协作。

   `DataKit <https://github.com/moby/datakit>`_ 是一个使用类似Git的工作流来编排应用程序的工具，借鉴了UNIX管道(pipline)概念，使用了替代底层文本的树状结构数据的流。DataKit可以在版本控制数据上定义复杂的编译工作流。当前DataKit作为HyperKit的一个写作流，以及用于 `DataKitCI <https://github.com/moby/datakit/tree/master/ci>`_ 持续集成系统。

安装HyperKit
===============

我推荐通过 :ref:`install_docker_macos` 方式获得HyperKit，因为Docker Desktop on Mac就是基于HyperKit实现的，所以安装Docker Desktop on Mac就能够获得完整的HyperKit运行环境。整个过程会非常顺畅和简单。

.. _build_hyperkit:

编译HyperKit
=============

通过源代码编译HyperKit::

   git clone https://github.com/moby/hyperkit
   cd hyperkit
   make

生成的二进制执行程序位于 ``build/hyperkit``

要激活块设备后端支持qcow，准备一个 OCaml OPAM开发环境。则需要通过 ``brew`` 安装 ``opam`` 和 ``libev`` 然后使用 ``opam`` 来安装相应的库::

   brew install opam libev
   opam init
   eval `opam config env`
   opam install uri qcow.0.10.4 conduit.1.0.0 lwt.3.1.0 qcow-tool mirage-block-unix.2.9.0 conf-libev logs fmt mirage-unix prometheus-app

.. note::

   为了能够在编译hyperkit之前找到ocaml环境，必须在编译前执行一次 ``opam config env``

   可以通过以下命令移除之前旧版本的 ``mirage-block-unix`` 的 ``pin`` 或者 ``qcow`` ::

      opam update
      opam pin remove mirage-block-unix
      opam pin remove qcow

- 安装HyperKit::

   git clone https://github.com/moby/hyperkit
   cd hyperkit
   make

.. note::

   二进制执行程序位于 ``build/hyperkit`` 。为了能够让 ``docker-machine-driver-hyperkit`` 找到hyperkit可执行程序，请将这个目录加入到环境变量，例如 ``~/.bash_profile`` 。

.. note::

   升级macOS 10.14.4 之后，对应的Xcode版本升级，clang编译对于源代码的语法校验加强，遇到类型错误::

      cc src/lib/firmware/fbsd.c
      src/lib/firmware/fbsd.c:690:7: error: implicit conversion changes signedness: 'unsigned int' to 'int' [-Werror,-Wsign-conversion]

   修改 ``config.mk`` 将::

      -Weverything \

   删除

.. note::

   遇到报错::

      ocamlfind: Package `cstruct.lwt' not found

   则重新安装一次 ``cstruct-lwt`` ::

      opam reinstall cstruct-lwt

Tracing
===========

HyperKit定义了一组静态DTrace  probes(探针)来简化调查性能问题。要列出HyperKit支持的探针，在在运行HyperKit VM时候窒息感以下命令::

   sudo dtrace -l -P 'hyperkit$target' -p $(pgrep hyperkit)

.. note::

   Ubuntu开发了一个跨平台运行虚拟机的 :ref:`multipass` 项目，底层就是针对不同的操作系统Hypervisor包装的快速启动Ubuntu工具。在macOS平台上，Multipass就使用了HyperKit实现虚拟机运行::

      brew cask install multipass

   然后就可以启动Ubuntu虚拟机::

      multipass launch

   启动的实例还可以挂载host主机目录(假设虚拟机启动命名是 ``keen-yak`` )::

      multipass mount $HOME keen-yak:/some/path`

   使用参考 `Working with Multipass instances <https://multipass.run/docs/working-with-instances>`_
