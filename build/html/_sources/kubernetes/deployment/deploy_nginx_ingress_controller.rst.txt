.. _deploy_nginx_ingress_controller:

=================================
部署Nginx Ingress Controller
=================================

安装和配置Cert-Manager
========================

使用Helm安装 ``cert-manager`` 实现TLS证书（从 `Let's Encrypt <https://letsencrypt.org/>`_ 获取) 以及其他证书授权和管理证书生命期。证书需要配置申明 Ingress Resource 的 ``certmanager.k8s.io/issuer`` ，在Ingress spec中添加一个 ``tls`` 段落，并且配置一个或多个指定证书授权声明。

.. note::

   以下安装在 ``kube-system`` namespace 安装 ``cert-manager``

- 安装 ``cert-manager`` CRDs，这个步骤必须在Helm chart安装cert-manager之前完成::

   kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml

- 将标签添加到 ``kube-system`` namespace ::

   kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"

.. note::

   这里标记安装 ``cert-manager`` 的namespace关闭资源验证。对于一个已经存在的namespace，必须添加上述标签，否则安装 ``cert-manager`` 会失败，报错见下文。

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

   要验证 ``cert-manager`` 是否安装成功，可以参考 `Cert Manager Quick Start <https://github.com/jetstack/cert-manager/blob/master/docs/tutorials/acme/quick-start/index.rst>`_ 官方文档

安装 cert-manager 异常排查
-----------------------------

socat命令不存在
~~~~~~~~~~~~~~~~~

在执行安装 ``cert-manager`` 命令报错::

   helm install --name cert-manager --namespace kube-system stable/cert-manager

出现报错::

   E0619 16:43:00.960750   29826 portforward.go:400] an error occurred forwarding 50374 -> 44134: error forwarding port 44134 to pod f4e5e03b5b5f994784598ca6f91c362aba04ceac3e1ac32560b22413f32a385f, uid : unable to do port forwarding: socat not found.
   ...
   E0619 16:43:39.474973   29826 portforward.go:340] error creating error stream for port 50374 -> 44134: Timeout occured
   E0619 16:44:04.599089   29826 portforward.go:362] error creating forwarding stream for port 50374 -> 44134: Timeout occured

这里的报错 ``uid : unable to do port forwarding: socat not found.`` 表示在服务器上没有找到工具命令 ``socat`` （参考 `helm commands error with "socat not found" <https://github.com/helm/helm/issues/1371>`_ ) ::

   sudo apt install socat

no matches for kind "Certificate"报错
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 如果忘记先安装 ``cert-manager`` CRDs，则直接安装 ``cert-manager`` 会报错::

   Error: validation failed: [unable to recognize "": no matches for kind "Certificate" in version "certmanager.k8s.io/v1alpha1", unable to recognize "": no matches for kind "Issuer" in version "certmanager.k8s.io/v1alpha1"]

这个报错参考 `helm install stable/cert-manager does not work anymore?  <https://github.com/jetstack/cert-manager/issues/1255>`_ 介绍，引用 `Step 4 — Installing and Configuring Cert-Manager <https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes#step-4-%E2%80%94-installing-and-configuring-cert-manager>`_ ，需要在安装 cert-manager 之前，创建 cert-manager CRDs 。

在 `Cert Manager Quick Start <https://github.com/jetstack/cert-manager/blob/master/docs/tutorials/acme/quick-start/index.rst>`_ 文档 ``Step 5 - Deploy Cert Manager`` 说明，按照以下步骤分布执行：

- 安装 ``cert-manager`` CRDs，这个步骤必须在Helm chart安装cert-manager之前完成::

   kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml

镜像下载异常
~~~~~~~~~~~~~

- 安装 ``cert-manager`` 后检查pod发现状态异常::

   kubectl get pods -n kube-system -o wide

输出显示::

   NAME                                        READY   STATUS              RESTARTS   AGE     IP               NODE       NOMINATED NODE   READINESS GATES
   cert-manager-cainjector-5dfd7c584d-sndhr    0/1     ImagePullBackOff    0          14m     172.17.0.11      minikube   <none>           <none>
   cert-manager-dcbb6f5b9-7tzs9                0/1     ImagePullBackOff    0          14m     172.17.0.12      minikube   <none>           <none>
   cert-manager-webhook-f6f965745-svjhc        0/1     ContainerCreating   0          14m     <none>           minikube   <none>           <none>

.. note::

   当Pod状态是 ``ImagePullBackOff`` 表示和镜像下载有关错误，可以通过 ``kubectl describe pod <pod-id>`` 来查看原因。(参考 `How to debug “ImagePullBackOff”? <https://stackoverflow.com/questions/34848422/how-to-debug-imagepullbackoff>`_ )

- 检查::

   kubectl describe pod cert-manager-dcbb6f5b9-7tzs9 -n kube-system

可以看到输出排查::

  Events:
     Type     Reason     Age                From               Message
     ----     ------     ----               ----               -------
     Normal   Scheduled  26m                default-scheduler  Successfully assigned kube-system/cert-manager-dcbb6f5b9-7tzs9 to minikube
     Warning  Failed     24m                kubelet, minikube  Failed to pull image "quay.io/jetstack/cert-manager-controller:v0.8.1": rpc error: code = Unknown desc = Error response from daemon: Get https://quay.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
     Warning  Failed     24m                kubelet, minikube  Error: ErrImagePull
     Normal   BackOff    24m                kubelet, minikube  Back-off pulling image "quay.io/jetstack/cert-manager-controller:v0.8.1"
     Warning  Failed     24m                kubelet, minikube  Error: ImagePullBackOff
     Normal   Pulling    24m (x2 over 26m)  kubelet, minikube  Pulling image "quay.io/jetstack/cert-manager-controller:v0.8.1"

这个 ``ImagePullBackOff`` 是因为下载镜像 ``quay.io/jetstack/cert-manager-controller:v0.8.1`` 出现错误导致的。不过，Kubernetes是最终一致性，所以会不断重试下载镜像。如果网络恢复正常，可能过一段实践还是会恢复 ``running`` 正常状态的。

volume "certs"挂载异常
~~~~~~~~~~~~~~~~~~~~~~~

- ``cert-manager-webhook`` 启动遇到无法挂载卷 "certs" 错误::

   Events:
     Type     Reason       Age                From               Message
     ----     ------       ----               ----               -------
     Normal   Scheduled    49s                default-scheduler  Successfully assigned kube-system/cert-manager-webhook-f6f965745-svjhc to minikube
     Warning  FailedMount  17s (x7 over 49s)  kubelet, minikube  MountVolume.SetUp failed for volume "certs" : secret "cert-manager-webhook-webhook-tls" not found

参考 `[stable/cert-manager] v0.6.0 fails to install w/ missing webhook tls secret <https://github.com/helm/charts/issues/10856>`_ :

**如果在一个已经存在的namespace上部署， ``必须确保`` 这个namespace具备一个附加的label才能部署成功**

果然，我检查了 ``kube-system`` namespace，发现确实没有加上标签 ``certmanager.k8s.io/disable-validation: "true"`` ，所以补上之前漏掉的命令::

   kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"

然后删除掉异常的pod ``cert-manager-webhook-f6f965745-svjhc`` ::

   kubectl delete pod cert-manager-webhook-f6f965745-svjhc -n kube-system

删除以后，Kubernetes会自动重建新的 ``cert-manager-webhook`` ，就能够成功。

.. note::

   cert-manager 官方文档采用单独建立 ``cerrt-manager`` namespce （请参考 `Cert Manager Quick Start <https://github.com/jetstack/cert-manager/blob/master/docs/tutorials/acme/quick-start/index.rst>`_ ），不过，我的部署参考 `How to Set Up an Nginx Ingress with Cert-Manager on DigitalOcean Kubernetes <https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes>`_ 步骤4 ，将 ``cert-manager`` 安装在 ``kube-system`` namespace，所以执行将标签添加到 ``kube-system`` namespace ::

      kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"

参考
=======

- `NGINX Ingress Controller Installation Guide <https://kubernetes.github.io/ingress-nginx/deploy/>`_
- `How to Set Up an Nginx Ingress with Cert-Manager on DigitalOcean Kubernetes <https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes>`_
