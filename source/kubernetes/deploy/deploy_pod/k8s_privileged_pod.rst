.. _k8s_privileged_pod:

====================
Kubernetes特权Pod
====================

Kubernetes特权Pod (privileged Pod) 是一种特殊运行Pod:

- 运行在 ``privileged`` 模式下的容器，能够完全访问物理节点内核(full access to the node's kernel)
- 可以仔细地通过屏蔽掉特定能力来授权以限制容器的特权
- 通过定义一些安全相关特性，例如 ``runAsUser`` / ``RunAsNonRoot`` 等

准备工作
=========

要运行 privileged pod，只需要在容器配置的 ``securityContext`` 部分设置 ``privileged: true`` :

创建 privileged pod
---------------------

.. literalinclude:: k8s_privileged_pod/privileged-pod-1.yaml
   :language: yaml
   :caption: 一个特权pod案例

- 创建测试pod:

.. literalinclude:: k8s_privileged_pod/create_privileged-pod
   :caption: 创建测试 privilege pod

- 当上述测试pod运行正常后，进入该pod:

.. literalinclude:: k8s_privileged_pod/exec_privileged-pod
   :caption: 进入privileged pod

- 然后在这个 ``privileged`` pod中检查容器能力:

.. literalinclude:: k8s_privileged_pod/capsh_privileged-pod
   :caption: 在容器内部检查该容器能力

输出可以看到:

.. literalinclude:: k8s_privileged_pod/capsh_privileged-pod_output
   :caption: 在容器内部检查该容器能力，输出信息

创建 non-privileged pod
--------------------------

.. note::

   虽然配置 ``privileged: false`` 和 ``allowPrivilegedEscalation: false`` ，但是实际上 pod 还是会有一些privileges的

- 创建 ``non-privileged`` pod:

.. literalinclude:: k8s_privileged_pod/privileged-pod-2.yaml
   :language: yaml
   :caption: 一个 ``non-privileged`` pod案例

- 运行:

.. literalinclude:: k8s_privileged_pod/create_non-privileged-pod
   :caption: 创建测试 privilege pod

- 然后在这个 ``non-privileged`` pod中检查容器能力:

.. literalinclude:: k8s_privileged_pod/capsh_privileged-pod
   :caption: 在容器内部检查该容器能力( ``non-privileged``  )

则输出内容明显降低了能力:

.. literalinclude:: k8s_privileged_pod/capsh_non-privileged-pod_output
   :caption: 在 ``non-privileged`` pod容器内部检查该容器能力，输出信息

创建完全drop privileged的pod
------------------------------

最严格的是 ``drop: ALL`` 的 ``non-privileged`` pod:

- 创建 ``drop ALL`` 的 ``non-privileged`` pod

.. literalinclude:: k8s_privileged_pod/privileged-pod-3.yaml
   :language: yaml
   :caption: 一个 drop ALL 的 ``non-privileged`` pod案例

- 运行:

.. literalinclude:: k8s_privileged_pod/create_drop_all_non-privileged-pod
   :caption: 创建测试 drop ALL的 ``non-privilege`` pod

在这个 drop ALL的 non-privileged pod中，可以看到没有任何能力

.. literalinclude:: k8s_privileged_pod/capsh_drop_all_non-privileged-pod_output
   :caption: 在 drop ALL 的  ``non-privileged`` pod容器内部检查该容器能力，输出信息

此时容器中不能安装rpm包，不能删除文件

创建以特定非Root用户运行 non-privileged pod
----------------------------------------------

- 以 1000 uid 运行的容器配置:

.. literalinclude:: k8s_privileged_pod/privileged-pod-4.yaml
   :language: yaml
   :caption: 一个特定用户的 drop ALL ``non-privileged`` pod案例

创建特定能力的特定非Root用户运行 non-privileged pod
--------------------------------------------------------

进一步，可以给容器一些特定的权限，例如允许调整进程的nice值:

.. literalinclude:: k8s_privileged_pod/privileged-pod-5.yaml
   :language: yaml
   :caption: 一个特定能力的用户 drop ALL ``non-privileged`` pod案例

.. note::

   总之，调整比较细节，可以进一步参考原文 `Kubernetes Privileged Pod Practical Examples <https://www.golinuxcloud.com/kubernetes-privileged-pod-examples/>`_


参考
======

- `Kubernetes Privileged Pod Practical Examples <https://www.golinuxcloud.com/kubernetes-privileged-pod-examples/>`_
