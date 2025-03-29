.. _k8s_deploy_squid_startup:

=============================
Kubernetes部署Squid快速起步
=============================

我在构建 :ref:`fedora_image` 并在 :ref:`macos_studio` 的 :ref:`kind` 中测试自己的开发环境，需要不断地从 :ref:`dockerfile` 创建系统。虽然可以修改Dockerfile来指定层层递进的镜像基础，但是考虑到后续部署Kubernetes集群应用，每个容器的操作系统和应用都需要保持更新，有必要在本地构建一个缓存代理服务器。

对于本地局域网 :ref:`squid` 是一个常用的缓存代理服务器，部署简单方便，并且Ubuntu的母公司Canonical在dockerhub官方维护了一个基于 Ubuntu LTS 的squid镜像 `ubuntu/squid Docker Image <https://hub.docker.com/r/ubuntu/squid>`_ ，并提供了长期安全维护，非常适合作为企业级应用部署。

.. note::

   :ref:`docker_squid` 适合单机部署测试，可以验证 `ubuntu/squid Docker Image <https://hub.docker.com/r/ubuntu/squid>`_ 基本配置工作正常之后，再来实践本文在Kubernetes中部署。

准备工作
============

- 完成 :ref:`docker_squid` 验证了基本配置工作正常， :strike:`停止验证容器并删除(防止端口抢占，节约资源)` ，不过不用删除docker容器:  :ref:`kind` 集群部署的 ``squid`` pod在没有输出服务之前，只在Kubernetes集群内部访问，而验证 :ref:`dockerfile` 和 :ref:`kind` 集群运行的pod不在同一个层次，相互无干扰
- 在 :ref:`kind` ``dev`` 集群的每个worker node上，先创建一个 ``/var/spool/squid`` 本地目录，这样部署时候就能够直接通过 ``hostpath`` 挂载到容器内部作为 :ref:`squid` 的缓存目录(另一种方法是 :ref:`docker_macos_file_sharing` 共享NFS ):

.. literalinclude:: k8s_deploy_squid_startup/kind_node_mkdir
   :language: bash
   :caption: 在 :ref:`kind` ``dev`` 集群的每个worker node上，先创建一个 ``/var/spool/squid`` 本地目录

- 由于我在 :ref:`macos_studio` 上使用 :ref:`kind` 运行了一个 :ref:`kind_local_registry` ，需要将 :ref:`docker_squid` 验证正确的镜像先推送到 ``registry`` 中，才能方便部署到这个本地 ``dev`` Kubernetes集群:

.. literalinclude:: k8s_deploy_squid_startup/push_squid_image_to_kind_registry
   :language: bash
   :caption: 将squid镜像推送到 :ref:`kind_local_registry`

.. note::

   我这里标记 :ref:`kind_local_registry` 镜像名为 ``squid-ubuntu:5.2-22.04`` :

   - squid v5.2
   - ubuntu 22.04 LTS

部署
=====

- 下载 `squid-deployment.yml <https://git.launchpad.net/~ubuntu-docker-images/ubuntu-docker-images/+git/squid/plain/examples/squid-deployment.yml?h=5.2-22.04>`_ 并修订:

.. literalinclude:: k8s_deploy_squid_startup/squid-deployment.yml
   :language: yaml
   :caption: 部署到kind集群的squid-deployment.yml
   :emphasize-lines: 1-15,24,36,58

.. note::

   - 存储修订为 ``hostpath`` 方式( 定义了 ``storageClassName: squid-spool`` )
   - ``service`` 配置段落我添加了 ``LoadBalancer`` 类型(目前暂时注释掉简化配置)::

      spec:
        type: LoadBalancer

   这会需要进一步配置一个本地的LoadBalancer 如 :ref:`metallb` 才能输出服务。如果没有指定 ``LoadBalancer`` ，则默认 ``ClusterIP`` 服务仅在集群内部可以访问，见 :ref:`k8s_service_think`

- 下载 `squid.conf <https://git.launchpad.net/~ubuntu-docker-images/ubuntu-docker-images/+git/squid/plain/examples/config/squid.conf?h=5.2-22.04>`_ 或者和我一样继续采用 :ref:`docker_squid` 验证过的 :ref:`fedora` 发行版 ``squid`` 默认配置 ``squid.conf`` :

.. literalinclude:: ../../../web/proxy/squid/squid_startup/squid.conf
   :language: bash
   :caption: fedora默认初始squid配置: /etc/squid/squid.conf

- 创建定制的configmap ``squid-config`` 以便 :ref:`config_pod_by_configmap` ，并部署pod:

.. literalinclude:: k8s_deploy_squid_startup/deploy_k8s_squid
   :language: yaml
   :caption: 部署到kind集群的squid

- 完成检查::

   % kubectl get pods -o wide
   NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
   squid-deployment-679756756d-drflk   1/1     Running   0          40m   10.244.7.2   dev-worker3   <none>           <none>

   % kubectl get svc -o wide
   NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
   squid-service   ClusterIP   10.96.119.129   <none>        3128/TCP   39m   app=squid

参考
=======

- `Deploying squid 🦑 in k3s on an RPI4B <https://dev.to/mediocredevops/deploying-squid-in-k3s-on-a-rpi4b-1nic>`_
