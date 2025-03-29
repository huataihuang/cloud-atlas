.. _k8s_deploy_registry_startup:

===============================
Kubernetes部署registry仓库起步
===============================

在完成 :ref:`z-k8s` 之后，Kubernetes集群采用了 :ref:`cilium` CNI，现在采用私有化registry来方便部署自己的各种定制镜像。此外，在 :ref:`stable_diffusion_on_k8s` 遇到无法下载镜像以及软件的问题，我考虑通过以下方法改进:

- 使用本文的方法部署本地 registry 仓库，采用本地镜像仓库加速部署
- 采用 :ref:`app_inject_data` 向容器内部注入proxy环境变量，强制所有容器内部下载文件都通过 :ref:`squid` 代理(实现翻墙)

.. note::

   本文部署简化版本，后续扩展部署实现分布式存储以及多replica容灾

参考
=======

- `Install a Private Docker Container Registry in Kubernetes <https://faun.pub/install-a-private-docker-container-registry-in-kubernetes-7fb25820fc61>`_ 以此为基础
- `Deploying Docker Registry on Kubernetes <https://medium.com/geekculture/deploying-docker-registry-on-kubernetes-3319622b8f32>`_ 这篇文档较新且提供了较简便的证书安装和分发，可能比较可行
- `Deploy Your Private Docker Registry as a Pod in Kubernetes <https://medium.com/swlh/deploy-your-private-docker-registry-as-a-pod-in-kubernetes-f6a489bf0180>`_
- `How to Setup Private Docker Registry in Kubernetes (k8s) <https://www.linuxtechi.com/setup-private-docker-registry-kubernetes/>`_
- `How To Install A Private Docker Container Registry In Kubernetes <https://www.paulsblog.dev/how-to-install-a-private-docker-container-registry-in-kubernetes/>`_
- `Private Docker Registry on Kubernetes: Steps to Set Up <https://www.knowledgehut.com/blog/devops/private-docker-registry>`_

以上参考文档都是近期资料，比较适合参考

- `How To Set Up a Private Docker Registry on Top of DigitalOcean Spaces and Use It with DigitalOcean Kubernetes <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-top-of-digitalocean-spaces-and-use-it-with-digitalocean-kubernetes>`_ DigitalOcean的这篇文档采用了S3兼容存储后端，我将参考改造成采用Ceph后端
- `How To Set Up a Private Docker Registry on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-20-04>`_ 使用Docker运行
- `Deploy a registry server <https://docs.docker.com/registry/deploying/>`_ docker官方文档
