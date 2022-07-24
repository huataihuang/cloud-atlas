.. _nerdctl:

================
nerdctl
================

nerdctl 是 ``containerd`` 子项目，提供Docker兼容的CLI命令:

- 类似 :ref:`docker` 的交互方式
- 支持Docker Compose
- 支持rootless模式
- 支持 lazy-pulling (例如 :ref:`estargz_lazy_pulling` )
- 支持加密镜像
- 支持P2P镜像分发 ( :ref:`ipfs` )
- 支持容器镜像签名和验证

参考
======

- `nerdctl: Docker-compatible CLI for containerd <https://github.com/containerd/nerdctl>`_
- `Rancher desktop: Working with Images <https://docs.rancherdesktop.io/tutorials/working-with-images>`_
