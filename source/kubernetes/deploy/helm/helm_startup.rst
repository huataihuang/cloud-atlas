.. _helm_startup:

===========================
Helm - Kubernetes包管理器
===========================

`Helm (英文原义是"舵") <https://helm.sh/>`_ 是用来管理Kubernetes应用程序的包管理器，Helm Charts 可以用于定义、安装以及更新复杂的Kubernetes应用程序。最新的Helm由 `CNCF <https://www.cncf.io/>`_ 负责维护，由微软、Google，Bitnami以及Helm社区合作。

.. note::

   Helm是Kubernetes应用程序定义和安装、更新的管理器，而 Operator 是Kubernetes定义和部署工具。那么两者有什么区别和使用场景的不同呢？ 在Haker News上有一个 `Can anyone talk about the positives/negatives of Operators v/s Helm Charts? <https://news.ycombinator.com/item?id=16969495>`_ 的讨论

   `Comparing Kubernetes Operator Pattern with alternatives <https://medium.com/@cloudark/why-to-write-kubernetes-operators-9b1e32a24814>`_ 对比了Operator和Helm在实践Postgres数据库的不同点，可以参考。

Helm分为客户端Helm (运行在你的客户端电脑，有多种版本) 和集群服务器端组件Tiller (运行在Kubernetes集群)

安装Helm
===========

二进制执行程序安装
--------------------

`Helm的release <https://github.com/helm/helm/releases>`_ 提供了不同操作系统的二进制执行程序，可以手工下载进行安装:

- 在 macOS 安装::

   wget https://get.helm.sh/helm-v2.14.1-darwin-amd64.tar.gz
   tar -zxvf helm-v2.14.1-darwin-amd64.tar.gz
   sudo mv darwin-amd64/helm /usr/local/bin/helm

推荐采用 :ref:`homebrew` 安装和维护:

.. literalinclude:: helm_startup/homebrew_helm_install
   :language: bash
   :caption: 在 :ref:`macos` 平台通过 :ref:`homebrew` 安装Helm

- 在 Linux 安装:

.. literalinclude:: helm_startup/linux_helm_install
   :language: bash
   :caption: 在Linux平台安装helm

.. note::

   其他操作系统二进制版本安装方法类似

.. note::

   在 :ref:`macos` 平台推荐采用 :ref:`homebrew` 安装，便于升级维护；在Linux上建议采用发行版仓库安装

脚本安装
---------

https://git.io/get_helm.sh 提供了安装脚本:

.. literalinclude:: helm_startup/helm_install_by_script
   :language: bash
   :caption: 使用官方脚本安装 helm

当然，你也可以直接运行命令 ``curl -L https://git.io/get_helm.sh | bash`` 。

需要注意的是，上述网站访问可能需要翻墙。

安装Tiller(废弃)
===========================

.. warning::

   `Helm v3 Beta 1 Released <https://helm.sh/blog/helm-v3-beta/>`_ :

   - 从Helm v3开始，已经移除了 ``Tiller`` ，不再需要集群的 ``admin`` 权限，也不需要在任何namespace安装Tiller了
   - 对应 ``helm init`` 命令也不存在了，所以本段落安装步骤 **只适合 Helm v2** ，你可以看到我现在很多实践helm安装已经没有 ``Tiller`` 步骤(例如 :ref:`install_ingress_nginx` )

Tiller是 ``helm`` 命令的集群端组件，用于接收 ``helm`` 的命令并直接和Kubernetes API通讯以实际执行创建或删除资源的工作。大多数云平台激活了称为基于角色的访问控制(Role-Based Access Control, RBAC)功能。这种环境下，为了能够给予 Tiller 足够权限，可以使用 Kubernetes ``serviceaccount`` 资源。

最简单的在集群上安装 ``tiller`` 是使用 ``helm init`` 命令，该命令会校验 ``helm`` 的本地环境以便正确设置。然后会连接到 ``kubectl`` 默认连接的集群( 通过 ``kubectl config view`` 可以看到当前默认配置连接的集群 )，一旦正确连接到集群，就会在  ``kube-system`` 名字空间中安装 ``tiller`` 。

- 检查本地 ``kubectl`` 连接的默认集群:

.. literalinclude:: helm_startup/check_k8s_config
   :language: bash
   :caption: 检查当前连接的Kubernetes集群

.. note::

   请检查当前连接集群 ``current-context`` 是否正确，如果是多个集群，需要使用: ``kubectl config set current-context my-context`` 切换。

- 在 ``kube-system`` 名字空间创建 ``tiller`` 的 ``serviceaccount`` :

.. literalinclude:: helm_startup/create_tiller_serviceaccount
   :language: bash
   :caption: 创建tiller的serviceaccount

- 将 ``tiller`` 这个 ``serviceaccount`` 绑定到 ``cluster-admin`` 角色:

.. literalinclude:: helm_startup/clusterrolebinding_tiller
   :language: bash
   :caption: tiller的serviceaccount绑定到cluster-admin角色

- 执行 ``helm init`` 则将 ``tiller`` 安装到集群中:

.. literalinclude:: helm_startup/helm_init
   :language: bash
   :caption: helm init安装tiller

.. note::

   注意默认Tiller部署采用的是非安全的 ``allow unauthenticated users`` 策略，为避免这个问题，请在运行 ``helm init`` 命令时添加参数 ``--tiller-tls-verify`` 。这里我是测试环境验证，后续生产环境部署需要改进。

- 安装完成后检查验证 tiller 运行，注意在kubernetes集群中的 ``kube-system`` namespace有新的pod名为 ``tiller-deploy-xxxx`` ::

   kubectl get pods --namespace kube-system

输出显示::

   NAME                                   READY   STATUS    RESTARTS   AGE
   ...
   tiller-deploy-9bf6fb76d-lj2dx          1/1     Running   0          2m1s

helm使用
==============

- 安装软件举例( :ref:`install_nvidia_device_plugin` ):

.. literalinclude:: helm_startup/helm_list
   :language: bash
   :caption: 检查通过helm已经安装的软件release(删除时候必须指定release)

显示输出举例:

.. literalinclude:: helm_startup/helm_list_output
   :language: bash
   :caption: 检查通过helm已经安装的软件release输出信息

- 删除helm chart(uninstall release):

.. literalinclude:: helm_startup/helm_uninstall
   :language: bash
   :caption: 使用helm uninstall删除指定release，注意必须指定namespace(如果不是默认namespace)

提示信息::

   release "nvidia-device-plugin-1673515385" uninstalled

对于非默认namespace的helm chart，如果没有指定namespace，则会报错。例如上文的 ``nvidia-device-plugin`` 如果执行::

   helm uninstall nvidia-device-plugin-1673515385

会报错::

   Error: uninstall: Release not loaded: nvidia-device-plugin-1673515385: release: not found

指定 ``$KUBECONFIG``
-----------------------

对于需要维护多个集群的环境， ``helm`` 也可以和 :ref:`kubectl` 一样指定 ``$KUBECONFIG`` 变量::

   export KUBECONFIG=/path_to_your_kubeconfig_file
   helm version
   helm list

.. note::

   ``helm`` 默认使用 ``~/.kube/config``  (同 :ref:`kubectl` )

helm代理
==========

在墙内使用 ``helm`` 最大的困扰是很多仓库位于google，在墙内访问几乎是 `不可能完成的任务 <https://movie.douban.com/subject/1292484/>`_ 。解决的方法是采用代理，例如 :ref:`squid_socks_peer` ，此时只需要配置 ``proxy`` 环境变量(其实就是Linux操作系统通用的代理配置) :ref:`linux_proxy_env`

.. _helm_install_specific_chart_version:

helm安装特定版本chart
=======================

我在 :ref:`intergrate_gpu_telemetry_into_k8s` 遇到一个问题: ``dcgm-exporter`` 要求 Kubernetes >= 1.19.0-0:

.. literalinclude:: helm_startup/dcgm-exporter_version_err
   :caption: 安装 :ref:`dcgm-exporter` 遇到Kubernetes版本不满足要求(需要安装低版本 ``dcgm-exporter`` )

解决方法是先检查仓库提供了哪些chart版本:

.. literalinclude:: helm_startup/helm_search_repo_dcgm-exporter
   :caption: 搜索helm仓库获取软件的不同版本列表

输出显示版本列表，依次尝试后可知 ``2.6.10`` 满足当前 Kubernetes 版本要求: 

.. literalinclude:: helm_startup/helm_search_repo_dcgm-exporter_output
   :caption: 搜索helm仓库获取软件的不同版本列表
   :emphasize-lines: 5

安装指定 ``2.6.10`` 版本 ``dcgm-exporter`` chart:

.. literalinclude:: helm_startup/helm_install_dcgm-exporter_specific_chart_version
   :caption: 安装指定版本helm chart

安装成功的输出信息:

.. literalinclude:: helm_startup/helm_install_dcgm-exporter_specific_chart_version_output
   :caption: 安装指定版本helm chart成功的输出信息

参考
=======

- `How To Install Software on Kubernetes Clusters with the Helm Package Manager <https://www.digitalocean.com/community/tutorials/how-to-install-software-on-kubernetes-clusters-with-the-helm-package-manager>`_
- `Helm Documentation <https://helm.sh/docs/>`_
- `Helm User Guide - Helm 用户指南 <https://whmzsu.github.io/helm-doc-zh-cn/>`_ - 官方 `Helm Documentation <https://helm.sh/docs/>`_ 的中文翻译，方便快速学习
- `使用Helm管理kubernetes原生应用 <https://jimmysong.io/posts/manage-kubernetes-native-app-with-helm/>`_
- `Helm command with kubeconfig inline <https://stackoverflow.com/questions/42849148/helm-command-with-kubeconfig-inline>`_
- `How to install a specific Chart version <https://stackoverflow.com/questions/51200917/how-to-install-a-specific-chart-version>`_
