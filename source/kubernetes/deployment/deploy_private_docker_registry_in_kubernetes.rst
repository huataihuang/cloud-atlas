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

- 执行以下命令激活NGINX Ingress controller::

   minikube addons enable ingress

.. note::

   对于常规Kubernetes集群，可以使用以下 ``helm`` 命令安装 Nginx Ingress controller ::

      helm install stable/nginx-ingress --name quickstart

- 验证NGINX ingress controller已经运行::

   kubectl get pods -n kube-system

.. note::

   确认在 ``kube-system`` namespace中正确运行了 ``nginx-ingress-controller``

在DNS provider中创建域名
==========================

- 首先需要创建一个域名解析记录指向Kubernetes Cluste，这个IP地址是 ``nginx-ingress-controller`` 服务的 ``EXTERNAL-IP`` ::

   kubectl get svc -n kube-system

.. note::

   这个IP地址我理解是 nginx-ingress 输出的对外IP地址，但是这个IP地址和Node节点的IP地址应该是不绑定的，而是Kubernetes对外输出负载均衡的访问VIP。

   待确认

安装 ``cert-manager`` addon
===============================

构建Docker Registry需要具备一个TLS证书。这个工作可以结合Let's Encrypt和 ``cert-manager`` Kubernetes addon来完成。这个addon自动管理和发布TLS证书，确保证书周期更新。并且会在证书过期之前尝试renew。

- 安装 ``cert-manager`` CRDs，这个步骤必须在Helm chart安装cert-manager之前完成::

   kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml

- 将标签添加到 ``kube-system`` namespace (对于已经存在的namespace此步骤必须) ::

   kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"

- 添加 `Jetstack Helm repository <https://hub.helm.sh/charts/jetstack>`_ 到Helm，这个仓库包含了 cert-manager Helm chart ::

   helm repo add jetstack https://charts.jetstack.io

- 更新 repo （如果已经存在) ::

   helm repo update

- 最后安装 chart 到 ``kube-system`` namespace ::

   helm install \
    --name cert-manager \
    --namespace kube-system \
    --version v0.8.1 \
    jetstack/cert-manager

.. note::

   详细的解释和遇到过的异常排查过程，请参考 :ref:`deploy_nginx_ingress_controller`

参考
========

- `How to run a Public Docker Registry in Kubernetes <https://www.nearform.com/blog/how-to-run-a-public-docker-registry-in-kubernetes/>`_
- `How To Set Up a Private Docker Registry on Top of DigitalOcean Spaces and Use It with DigitalOcean Kubernetes <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-top-of-digitalocean-spaces-and-use-it-with-digitalocean-kubernetes>`_
