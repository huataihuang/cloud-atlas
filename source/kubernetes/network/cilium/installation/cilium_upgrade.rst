.. _cilium_upgrade:

===================
升级Cilium
===================

.. note::

   本文实践参考 `Cilium Upgrade Guide <https://docs.cilium.io/en/stable/operations/upgrade/>`_ 中 :ref:`helm` 方式，如果需要采用 ``kubectl`` 方式，请参考原文

Cilium升级前检查
=================

在滚动升级Kubernetes时，Kubernetes会首先终止pod，然后拉取新镜像版本，并最终基于新镜像创建容器。为了降低agent的中断实践并且避免更新过程中出现 ``ErrImagePull`` ，建议预先拉取镜像和进行模拟检查(pre-flight check)。如果采用 :ref:`cilium_kubeproxy_free` 则需要在升级在生成 ``cilium-preflight.yaml`` 配置文件中指定 Kubernetes API服务器IP地址和端口。

运行pre-flight检查(必须)
=========================

- 由于我已经采用了 :ref:`cilium_kubeproxy_free` 模式，所以我这里执行 :ref:`helm` 的 ``kubeproxy-free`` 模式:

.. literalinclude:: cilium_upgrade/helm_cilium-preflight
   :language: bash
   :caption:  使用Helm运行pre-flight检查(hubeproxy-free模式)

这里可能会遇到无法下载问题::

   Error: INSTALLATION FAILED: failed to download "cilium/cilium" at version "1.12.0"

这个问题参考 `Error: INSTALLATION FAILED: failed to download #10285 <https://github.com/helm/helm/issues/10285>`_ 需要先更新仓库配置 (非常类似 :ref:`dnf` )::

   helm repo update

然后再次执行 ``helm install`` 就行成功，提示信息如下::

   NAME: cilium-preflight
   LAST DEPLOYED: Mon Aug 15 17:33:14 2022
   NAMESPACE: kube-system
   STATUS: deployed
   REVISION: 1
   TEST SUITE: None
   NOTES:
   You have successfully ran the preflight check.
       Now make sure to check the number of READY pods is the same as the number of running cilium pods.
       Then make sure the cilium preflight deployment is also marked READY 1/1.
       If you have an issues please refer to the CNP Validation section in the upgrade guide.
   
   Your release version is 1.12.0.
   
   For any further help, visit https://docs.cilium.io/en/v1.12/gettinghelp

- 在完成了 ``cilium-preflight.yaml`` apply之后，检查:

.. literalinclude:: cilium_upgrade/helm_cilium-preflight_check
   :language: bash
   :caption:  Helm运行pre-flight(hubeproxy-free模式)之后检查

输出信息:

.. literalinclude:: cilium_upgrade/helm_cilium-preflight_check_output
   :language: bash
   :caption:  Helm运行pre-flight(hubeproxy-free模式)之后检查输出信息

注意，需要确保 READY pods 的数量和 Cilium pods 的运行数量一致。但是我看到 ``cilium`` 数量是 8 但是 ``cilium-pre-flight-check`` 数量是 5 是不一致的

检查pods::

   kubectl get pods -n kube-system -o wide

可以看到和 cilium 相关::

   NAME                                      READY   STATUS    RESTARTS       AGE     IP              NODE        NOMINATED NODE   READINESS GATES
   cilium-2qcdd                              1/1     Running   0              2d15h   192.168.6.113   z-k8s-n-3   <none>           <none>
   cilium-4drkm                              1/1     Running   0              2d15h   192.168.6.102   z-k8s-m-2   <none>           <none>
   cilium-4xktc                              1/1     Running   0              2d15h   192.168.6.101   z-k8s-m-1   <none>           <none>
   cilium-5j2xb                              1/1     Running   0              2d15h   192.168.6.112   z-k8s-n-2   <none>           <none>
   cilium-d7mmq                              1/1     Running   0              2d15h   192.168.6.114   z-k8s-n-4   <none>           <none>
   cilium-fw9b5                              1/1     Running   0              2d15h   192.168.6.115   z-k8s-n-5   <none>           <none>
   cilium-operator-7d4657d9c5-brcgn          1/1     Running   0              2d15h   192.168.6.112   z-k8s-n-2   <none>           <none>
   cilium-operator-7d4657d9c5-qgdbp          1/1     Running   0              2d15h   192.168.6.115   z-k8s-n-5   <none>           <none>
   cilium-pre-flight-check-2fnfk             1/1     Running   21 (10m ago)   21h     192.168.6.115   z-k8s-n-5   <none>           <none>
   cilium-pre-flight-check-68f5m             1/1     Running   21 (11m ago)   21h     192.168.6.111   z-k8s-n-1   <none>           <none>
   cilium-pre-flight-check-d474b6964-pv4bz   1/1     Running   21 (10m ago)   21h     192.168.6.114   z-k8s-n-4   <none>           <none>
   cilium-pre-flight-check-lshwz             1/1     Running   21 (11m ago)   21h     192.168.6.114   z-k8s-n-4   <none>           <none>
   cilium-pre-flight-check-qxcp8             1/1     Running   21 (11m ago)   21h     192.168.6.113   z-k8s-n-3   <none>           <none>
   cilium-pre-flight-check-xwdpq             1/1     Running   21 (11m ago)   21h     192.168.6.112   z-k8s-n-2   <none>           <none>
   cilium-t675t                              1/1     Running   0              2d15h   192.168.6.103   z-k8s-m-3   <none>           <none>
   cilium-tsntp                              1/1     Running   0              2d15h   192.168.6.111   z-k8s-n-1   <none>           <none>

可以看到 ``cilium-pre-flight-check`` 只运行在工作节点，但是没有部署到 master 节点

检查 ``cilium-pre-flight-check-2fnfk`` pods::

   kubectl -n kube-system get pods cilium-pre-flight-check-2fnfk -o yaml

可以看到实际上 ``cilium-pre-flight-check`` 的 ``tolerations`` 配置是避开master节点的::

     tolerations:
     ...
     - effect: NoSchedule
       key: node-role.kubernetes.io/master

所以不部署到master节点是正常的

参考 `CNP Validation <https://docs.cilium.io/en/stable/operations/upgrade/#cnp-validation>`_ 我按照以下步骤执行 ``CNP Validateor`` :

按照 `CNP Validation <https://docs.cilium.io/en/stable/operations/upgrade/#cnp-validation>`_ 文档， ``CNP Validator`` 是作为 ``pre-flight check`` 的一部分自动执行的，所以执行以下命令检查::

   kubectl get deployment -n kube-system cilium-pre-flight-check -w

我这里遇到一个奇怪的问题，终端显示输出::

   NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
   cilium-pre-flight-check   1/1     1            1           17h

一直没有返回提示符?

检查日志输出::

   kubectl logs -n kube-system deployment/cilium-pre-flight-check -c cnp-validator --previous

提示信息::

   time="2022-08-16T01:34:02Z" level=info msg="Setting up Kubernetes client"
   time="2022-08-16T01:34:02Z" level=info msg="Establishing connection to apiserver" host="https://192.168.6.101:6443" subsys=k8s
   time="2022-08-16T01:34:02Z" level=info msg="Connected to apiserver" subsys=k8s
   time="2022-08-16T01:34:03Z" level=info msg="All CCNPs and CNPs valid!"

看起来似乎没有问题。

- 然后检查 ``cilium-pre-flight-check`` 是否也是 ``READY 1/1`` :

.. literalinclude:: cilium_upgrade/cilium-pre-flight-check_ready_check
   :language: bash
   :caption: 检查 cilium-pre-flight-check 是否也正常运行

输出状态::

   NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
   cilium-pre-flight-check   1/1     1            1           18h

符合要求

清理pre-flight check
=======================

一旦 preflight :ref:`daemonset` 符合 cilium pods 运行数量并且 preflight ``Delpoyment`` 被标记为 ``READY 1/1`` 就可以删除掉 ``cilium-preflight`` 并开始升级:

.. literalinclude:: cilium_upgrade/delete_cilium-pre-flight-check
   :language: bash
   :caption: cilium-pre-flight-check 检查正确后即可删除

此时会提示::

   release "cilium-preflight" uninstalled

升级Cilium
==============

对于常规集群操作，所有Cilium组件应该运行相同版本。只升级单一组件(例如升级agent但没有升级operator)会导致不可预测的集群问题。以下步骤说明是从一个稳定版本升级所有组件到一个更新到稳定版本:

步骤一: 升级到当前版本到最新补丁版本
------------------------------------

在更新大版本之前(例如 ``1.11 => 1.12`` )，应该先参考 Cilium relase ，确保升级到当前主版本的最新patch版本，例如 ``1.11.7``

步骤二: 使用Helm更新Cilium deployment
---------------------------------------

:ref:`helm` 可以用于直接更新Cilium或者生成YAML文件然后通过 ``kubectl`` 来更新现有deployment。默认，Helm将使用每个新版本打包的默认参数值文件生成新模版。需要确保指定用户初始部署的等效选项，方法是在命令行中指定参数值或者将参数值提交到YAML文件。

.. note::

   必须使用Helm 3

- 设置Helm仓库:

.. literalinclude:: cilium_install_with_external_etcd/helm_repo_add_cilium
   :language: bash
   :caption: 设置cilium Helm仓库

- 为最小化升级过程中数据路径中断，可以使用 ``upgradeCompatibility`` 选项 ``1.7 / 1.8 / 1.9 / 1.10`` (不过，我是从 ``1.11`` 升级，所以没有使用该参数):

.. literalinclude:: cilium_upgrade/helm_upgrade_cilium
   :language: bash
   :caption: 使用helm升级cilium

升级很快，输出信息如下:

.. literalinclude:: cilium_upgrade/helm_upgrade_cilium_output
   :language: bash
   :caption: 使用helm升级cilium的输出信息

当使用 ``helm upgrade`` 进行小版本升级时， **不要** 使用 Helm 的 ``--reuse-values`` 参数，这个 ``--reuse-values`` 参数会忽略所有新版本引入的新参数导致Helm模版渲染错误。要保留旧版本的安装参数，应该先把旧参数保存到文件，然后检查该文件的参数，然后通过 ``helm upgrade`` 命令订正参数，可以通过以下命令保存现有安装的参数值::

   helm get values cilium --namespace=kube-system -o yaml > old-values.yaml

回滚
------

如果出现升级错误，则采用如下方法回滚::

   helm history cilium --namespace=kube-system
   helm rollback cilium [REVISION] --namespace=kube-system

.. note::

   详细的升级细节，请参考官方原文 `Cilium Upgrade Guide <https://docs.cilium.io/en/stable/operations/upgrade/>`_

参考
=======

- `Cilium Upgrade Guide <https://docs.cilium.io/en/stable/operations/upgrade/>`_
