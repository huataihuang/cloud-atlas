.. _kubebox_startup:

====================
Kubebox快速起步
====================

Kubebox是一个开源的Kubernetes 终端和Web console的实现，可以实现Kubernetes集群的pods监视以及通过remote exec访问容器终端。对于现代的容器运行环境，已经轻量化去除了ssh登陆，则这种集中式的远程exec方式可以方便我们维护应用服务器。

Kubebox功能展示
==================

- 集群事件查看:

.. figure:: ../../../_static/kubernetes/deployment/kubebox/kubebox_cluster_event.png
   :scale: 25

- 登陆pod容器shell:

.. figure:: ../../../_static/kubernetes/deployment/kubebox/kubebox_container_shell.png
   :scale: 25

- 终端风格支持:

.. figure:: ../../../_static/kubernetes/deployment/kubebox/kubebox_term_themes.png
   :scale: 25

- Web浏览器终端:

.. figure:: ../../../_static/kubernetes/deployment/kubebox/kubebox_web_term.png
   :scale: 25

安装Kubebox
==============

独立可执行程序
-----------------

- 下载kubebox独立执行程序::

   # Linux (x86_64)
   $ curl -Lo kubebox https://github.com/astefanutti/kubebox/releases/download/v0.9.0/kubebox-linux && chmod +x kubebox
   # Linux (ARMv7)
   $ curl -Lo kubebox https://github.com/astefanutti/kubebox/releases/download/v0.9.0/kubebox-linux-arm && chmod +x kubebox
   # OSX
   $ curl -Lo kubebox https://github.com/astefanutti/kubebox/releases/download/v0.9.0/kubebox-macos && chmod +x kubebox
   # Windows
   $ curl -Lo kubebox.exe https://github.com/astefanutti/kubebox/releases/download/v0.9.0/kubebox-windows.exe

- 运行::

   $ ./kubebox

服务器运行
-----------

kubebox可以作为Kubernetes集群的服务运行，终端模拟是通过 `xterm.js <https://github.com/xtermjs/xterm.js>`_ 结合kubebox服务代理和Kubernetes master API通讯。

- 部署Kubernetes集群的kubebox服务::

   kubectl apply -f https://raw.github.com/astefanutti/kubebox/master/kubernetes.yaml

.. note::

   后续待实践...

   包括认证，高可用等

参考
=====

- `Kubebox GitHub <https://github.com/astefanutti/kubebox>`_
