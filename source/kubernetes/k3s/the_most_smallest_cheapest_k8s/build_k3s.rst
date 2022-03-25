.. _build_k3s:

=================
源代码编译k3s
=================

由于直接采用 ``k3s`` 官方提供执行程序在 :ref:`pi_1` 上 :ref:`mini_k3s_deploy` 失败，我尝试自己编译 :ref:`armv6` 架构的执行程序。

编译环境:

- :ref:`pi_1`
- :ref:`alpine_linux` for armhf

编译
==========

- :ref:`pi_1` 安装 :ref:`alpine_linux` for armhf 版本，准备编译工具::

   sudo apk add build-base git

- :ref:`alpine_docker` ( ``k3s`` 运行不需要docker，但是编译过程需要在docker容器中完成，这也是一个构建开发环境的思路 )::

   sudo apk add docker
   sudo service docker start

- 下载源代码::

   git clone --depth 1 https://github.com/k3s-io/k3s.git

- ``k3s`` build进程需要一些自动生成到代码以及远程复制，这些源代码通过以下命令在build环境中准备::

   mkdir -p build/data && make download && make generate

- 编译完整发布代码::

   make

编译完成后将生成 ``./dist/artifacts/k3s``

.. note::

   ``k3s`` 的编译是在Docker容器中进行的，所以需要确保容器能够畅通访问internet。从我的编译经验来看，需要配置 :ref:`squid_socks_peer` 并设置 :ref:`docker_proxy`

.. note::

   在 :ref:`pi_1` 上编译 ``k3s`` 是非常漫长的过程，也许应该采用 :ref:`cross_compile_pi`

.. note::

   在 :ref:`pi_1` 上编译 ``k3s`` 我还遇到一个问题是内存不足，编译过程有一个 ``compile`` 步骤被oomkill了，导致最终build失败。目前，我临时采用添加512MB swap来尝试绕过。

代理
--------

由于 github.com 很容易被GFW干扰，所以如果没有类似 :ref:`squid_socks_peer` 这样的翻墙代理，整个代码下载过程会非常坎坷。

最为关键的是，编译是在容器中进行，例如 ``go get`` 需要访问的 `golang网站 <https://golang.org>`_ 已经被GFW屏蔽，编译过程会阻塞。解决方法是采用 :ref:`docker_proxy` 配置所有运行容器采用统一的代理访问网络。

错误排查
----------

- ``k3s`` master 镜像编译完成后，启动会出现一个报错::

   Step 2/2 : COPY . /go/src/github.com/k3s-io/k3s/
    ---> dd1a6281cdf6
    Successfully built dd1a6281cdf6
    Successfully tagged k3s:master
   docker: Error response from daemon: privileged mode is incompatible with user namespaces.  You must run the container in the host namespace when running privileged mode.
   See 'docker run --help'.
   FATA[1443] exit status 125
   make: *** [Makefile:11: download] Error 1

原因是我在之前做过 :ref:`alpine_docker` 安装时，特别设置了 `docker userns-remap <https://docs.docker.com/engine/security/userns-remap/>`_ 没想到这个还和 ``k3s`` 冲突，所以需要去除

参考
=====

- `Build k3s from source <https://github.com/k3s-io/k3s/blob/master/BUILDING.md>`_
