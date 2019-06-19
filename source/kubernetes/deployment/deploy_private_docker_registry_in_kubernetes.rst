.. _deploy_private_docker_registry_in_kubernetes:

========================================
在Kubernetes中部署私有Docker镜像仓库
========================================

在生产环境中，不论是简单运行Docker容器还是部署Kubernetes集群，都需要使用私有镜像中心来实现中心化都镜像存储和分发:

- 定制私有镜像，不需要把镜像推送到公共镜像服务器，避免安全隐患
- 加速本地镜像的分发和容器部署

私有镜像仓库架构
==================

.. figure:: ../../_static/kubernetes/docker-registry-in-k8s.png
   :scale: 80%

准备工作
==========

.. note::

   部署需要使用Helm包管理器，分为两部分: 本地客户端安装Helm，远程Kubernetes集群安装Tiller。详细请参考 :ref:`helm` 。

安装Helm和Tiller
-----------------

- 本地安装helm工具（linux版本） ::

   wget https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz
   tar -zxvf helm-v2.14.1-linux-amd64.tar.gz
   sudo mv linux-amd64/helm /usr/local/bin/helm

- 使用 ``kubectl config view`` 确认当前连接的是目标 kubeernetes 集群

- 在Kubernetes集群安装服务端组件 ``tiller`` ::

   kubectl -n kube-system create serviceaccount tiller
   kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
   helm init --service-account tiller

激活Nginx ingress controller
------------------------------

.. note::

   本次部署采用的是 :ref:`minikube_deploy_nginx_ingrerss_controller` ，所以激活Nginx ingress controller非常简单。详细可参考 :ref:`deploy_nginx_ingress_controller` 。 



参考
========

- `How to run a Public Docker Registry in Kubernetes <https://www.nearform.com/blog/how-to-run-a-public-docker-registry-in-kubernetes/>`_
- `How To Set Up a Private Docker Registry on Top of DigitalOcean Spaces and Use It with DigitalOcean Kubernetes <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-top-of-digitalocean-spaces-and-use-it-with-digitalocean-kubernetes>`_
