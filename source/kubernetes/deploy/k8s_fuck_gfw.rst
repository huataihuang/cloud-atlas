.. _k8s_fuck_gfw:

==================
墙内K8s部署
==================

.. note::

   本文是一些实践经验和想法，并不是 Kubernetes 的真正技术，然而对于墙内技术工作者来说又是不得不面对的挑战。

墙内部署Kubernetes: `不能说的秘密 <https://movie.douban.com/subject/2124724/>`_
==================================================================================

`使用国内的镜像源搭建 kubernetes（k8s）集群 <https://zhuanlan.zhihu.com/p/437166729>`_ 方法如下:

- 先使用 :ref:`kubeadm` 按照正常流程构建集群，显然下载镜像会失败
- 执行 ``kubeadm`` 检查当前集群需要的镜像列表:

.. literalinclude:: k8s_fuck_gfw/kubeadm_config_images_list
   :language: bash
   :caption: 检查Kubernetes部署使用的镜像

- 根据输出镜像列表以及对应版本信息，将 ``docker pull`` 命令的镜像改写成阿里云镜像registry来下载K8s镜像

- 为下载好的镜像打上对应的 ``k8s.gcr.io/XXXX`` 标签，这样就相当于直接从Google的镜像registry下载了正确的镜像

- 继续完成K8s部署

lank8s.cn
============

在墙内部署Kubernetes以及很多原生应用是非常麻烦的，有一些技术爱好者，例如 `申远鹏 <https://liangyuanpeng.com>`_ 创建了一个 `lank8s.cn服务 <https://liangyuanpeng.com/service-lank8s.cn/>`_ 为墙内Kubernetes用户提供 ``Kubernetes基础镜像`` 墙内镜像网站。这个项目弥补了微软镜像代理节点 ``azk8s.cn`` 从2020年上半年开始只对微软云的国内服务器提供服务的缺憾。( 微软azure.cn文档 `GCR Proxy Cache 帮助 <http://mirror.azure.cn/help/gcr-proxy-cache.html>`_ 介绍了 **Proxy Server仅限于 Azure China IP
使用，不再对外提供服务** ，以及使用方法)

.. note::

   如果是自建自用服务(不对外)，可以采用 :ref:`squid_socks_peer` 方式，在墙内和墙外构建一个代理通道，通过 :ref:`docker_proxy` / :ref:`containerd_proxy` / :ref:`helm_proxy` 等组合配置，实现全系列穿墙部署Kubernetes

不过，作为个人项目 `lank8s.cn服务 <https://liangyuanpeng.com/service-lank8s.cn/>`_ 依然存在不稳定的问题，我在一个项目部署上遇到一个问题，同事使用 :ref:`kubespray` 部署Kubernetes使用了 `lank8s.cn服务 <https://liangyuanpeng.com/service-lank8s.cn/>`_ ，然而在升级更新时遇到报错::

   failed to pull image "lank8s.cn/pause:3.2": failed to resolve image "lank8s.cn/pause:3.2": no available registry endpoint: unexpected status code https://lank8s.cn/v2/pause/manifests/3.2: 503 Service Unavailable

实际上是 `lank8s.cn服务 <https://liangyuanpeng.com/service-lank8s.cn/>`_ 服务器后端异常，这卡住了我的应用升级重启

`使用国内的镜像源搭建 kubernetes（k8s）集群 <https://zhuanlan.zhihu.com/p/437166729>`_ 采用的方法提示了我，可以从Google官方下载好镜像(如果你可以翻墙)或者阿里云镜像服务器(如果你的服务器能够访问阿里云)下载:

- 检查集群部署需要的镜像:

.. literalinclude:: k8s_fuck_gfw/kubeadm_config_images_list
   :language: bash
   :caption: 检查Kubernetes部署使用的镜像

显示出当前集群需要的镜像列表:

.. literalinclude:: k8s_fuck_gfw/kubeadm_config_images_list_output
   :language: bash
   :caption: 检查Kubernetes部署使用的镜像列表

- 由于我们系统缺少 ``lank8s.cn/pause:3.2`` 实际上就是 ``k8s.gcr.io/pause:3.2`` ，所以我们下载阿里云提供的 ``k8s.gcr.io/pause:3.2`` 镜像:

.. literalinclude:: k8s_fuck_gfw/ctr_images_pull
   :language: bash
   :caption: 从阿里云镜像下载gcr.io的镜像

- 此时系统还看不到 ``lank8s.cn/pause:3.2`` ，我们需要给下载的阿里云对应镜像打上同名 ``tag`` (当初同事部署Kubernetes集群的时候应该是指定了):

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2

.. literalinclude:: k8s_fuck_gfw/ctr_images_tag
   :language: bash
   :caption: 将阿里云下载gcr.io的镜像打上tag

似乎早期版本 ``ctr`` 不支持 ``tag`` 命令，提示错误::

   No help topic for 'tag'

.. _docker_ctr_images:

结合 ``docker images`` 和 ``ctr images`` 实现镜像下载导入
-----------------------------------------------------------

采用变通方法，先导出再导入，导入时加上标签(晕倒，导出镜像没有成功)::

   ctr -n k8s.io images export pause_3.2.tar registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2

报错::

   ctr: export failed: content digest sha256:bbb7780ca6592cfc98e601f2a5e94bbf748a232f9116518643905aa30fc01642: not found

.. note::

   :ref:`ctr` 非常难用，实际上不如兼容Docker的 :ref:`nerdctl` 

怎么办呢? 我改为使用 :ref:`docker` 命令来下载镜像，然后通过 :ref:`transfer_docker_image_without_registry` 相似方法，利用 ``docker`` 功能丰富的镜像管理命令，先导出镜像，再用 ``ctr`` 导入镜像到 :ref:`containerd` (是的， ``ctr`` 导入命令可以使用):

.. literalinclude:: k8s_fuck_gfw/docker_images_pull
   :language: bash
   :caption: 使用 ``docker`` 从阿里云镜像下载gcr.io的镜像，然后 ``tag`` 上 ``lank8s.cn/pause:32`` 方便后续导出

此时检查 ``docker images`` 可以看到::

   REPOSITORY                                                  TAG                 IMAGE ID            CREATED             SIZE
   lank8s.cn/pause                                             3.2                 80d28bedfe5d        3 years ago         683 kB
   registry.cn-hangzhou.aliyuncs.com/google_containers/pause   3.2                 80d28bedfe5d        3 years ago         683 kB

``docker`` 导出镜像:

.. literalinclude:: k8s_fuck_gfw/docker_images_save
   :language: bash
   :caption: 使用 ``docker`` 导出(save)阿里云镜像下载gcr.io的镜像

现在使用 ``ctr`` 导入 ``docker`` 保存的镜像 :

.. literalinclude:: k8s_fuck_gfw/ctr_images_import
   :language: bash
   :caption: ``ctr images import`` 导入 ``docker`` 保存的镜像(有 ``lank8s.cn/pause:3.2`` TAG)

此时就会看到导入的是 ``lank8s.cn/pause:3.2`` :

.. literalinclude:: k8s_fuck_gfw/ctr_images_import_output
   :language: bash
   :caption: ``ctr images import`` 导入 ``docker`` 保存的镜像(有 ``lank8s.cn/pause:3.2`` TAG)提示信息显示标签正确

现在使用 ``ctr -n k8s.io images ls | grep lank8s.cn`` 就能够看到我们需要的镜像标记

参考
=======

- `使用国内的镜像源搭建 kubernetes（k8s）集群 <https://zhuanlan.zhihu.com/p/437166729>`_
- `国内镜像列表 <https://feisky.gitbooks.io/kubernetes/content/appendix/mirrors.html>`_ 非常有用的镜像网站列表，需要时可以参考
