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

.. note::

   注意，操作系统的内核参数和cgroup配置，需要按照 :ref:`mini_k3s_prepare` 

- 下载源代码::

   git clone --depth 1 https://github.com/k3s-io/k3s.git

- ``k3s`` build进程需要一些自动生成到代码以及远程复制，这些源代码通过以下命令在build环境中准备::

   mkdir -p build/data && make download && make generate

- 编译完整发布代码::

   make

编译完成后将生成 ``./dist/artifacts/`` 目录下以下文件::

   total 733M
   -rw-------    1 huatai   dialout   415.5M Mar 28 08:20 k3s-airgap-images-arm.tar
   -rw-r--r--    1 huatai   dialout   147.2M Mar 28 09:01 k3s-airgap-images-arm.tar.gz
   -rw-------    1 huatai   dialout   116.3M Mar 28 08:50 k3s-airgap-images-arm.tar.zst
   -rwxr-xr-x    1 huatai   dialout    53.5M Mar 28 07:40 k3s-armhf

.. note::

   ``k3s`` 的编译是在Docker容器中进行的，所以需要确保容器能够畅通访问internet。从我的编译经验来看，需要配置 :ref:`squid_socks_peer` 并设置 :ref:`docker_proxy`

oom 问题
-----------

.. note::

   在 :ref:`pi_1` 上编译 ``k3s`` 是非常漫长的过程，也许应该采用 :ref:`cross_compile_pi`


在 :ref:`pi_1` 上编译 ``k3s`` 我还遇到一个问题是内存不足，编译过程有一个 ``compile`` 步骤被oomkill了，导致最终build失败。解决方法是:临时采用添加 1000MB swap(已验证512MBswap空间依然不足会有oom)::

   sudo dd if=/dev/zero of=/swap.img bs=100MB count=10
   sudo mkswap /swap.img
   sudo swapon /swap.img

整个编译过程在 :ref:`pi_1` 上需要超过11~12小时...

trivy coredump
-----------------

在编译最后成功生成arm镜像，依然出现镜像扫描coredump::

   ...
   Successfully tagged rancher/k3s:v1.23.5-rc2-k3s1-arm
   ++ '[' -z rancher/k3s:v1.23.5-rc2-k3s1-arm ']'
   ++ IMAGE=rancher/k3s:v1.23.5-rc2-k3s1-arm
   ++ SEVERITIES=HIGH,CRITICAL
   ++ trivy --quiet image --severity HIGH,CRITICAL --no-progress --ignore-unfixed rancher/k3s:v1.23.5-rc2-k3s1-arm
   ./scripts/image_scan.sh: line 17:  3463 Illegal instruction     (core dumped) trivy --quiet image --severity ${SEVERITIES} --no-progress --ignore-unfixed ${IMAGE}
   FATA[39880] exit status 132
   make: *** [Makefile:11: ci] Error 1

原因是官方下载的 :ref:`trivy` 默认是 ``armv7`` ，在 :ref:`pi_1` 上执行会出现异常。所以我采用变通方法，将 ``./scripts/image_scan.sh`` 扫描行命令注释掉，以便默认返回正常::

   ...
   IMAGE=(
   SEVERITIES="HIGH,CRITICAL"

   #trivy --quiet image --severity ${SEVERITIES}  --no-progress --ignore-unfixed ${IMAGE}

   exit 0

代理
--------

由于 github.com 很容易被GFW干扰，所以如果没有类似 :ref:`squid_socks_peer` 这样的翻墙代理，整个代码下载过程会非常坎坷。

最为关键的是，编译是在容器中进行，例如 ``go get`` 需要访问的 `golang网站 <https://golang.org>`_ 已经被GFW屏蔽，编译过程会阻塞。解决方法是采用 :ref:`docker_proxy` 配置所有运行容器采用统一的代理访问网络。

其他错误
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
