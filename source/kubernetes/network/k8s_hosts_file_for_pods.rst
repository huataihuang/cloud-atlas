.. _k8s_hosts_file_for_pods:

================================
Kubernetes配置Pods中的hosts文件
================================

在故障排查中(也可能测试环境)，需要为 pod 中注入 ``/etc/hosts`` 配置，以便能够绕过DNS解析来直接访问目标服务器。在Kubernetes中， ``PodSpec`` 段落提供了 ``HostAliases`` 字段完成配置:

.. literalinclude:: k8s_hosts_file_for_pods/hostalias.yaml
   :language: yaml
   :caption: 为pod添加hosts

- 测试:

.. literalinclude:: k8s_hosts_file_for_pods/kubectl_hostalias
   :caption: 创建测试pods

- 检查:

.. literalinclude:: k8s_hosts_file_for_pods/kubectl_get_hostalias
   :caption: 查看创建的测试pods

输出可以看到运行的pod:

.. literalinclude:: k8s_hosts_file_for_pods/kubectl_get_hostalias_output
   :caption: 查看创建的测试pods


- 查看日志:

.. literalinclude:: k8s_hosts_file_for_pods/kubectl_logs_hostalias
   :caption: 查看创建的测试pods的日志

- 日志结果(就是 ``cat /etc/hosts`` 的输出内容验证):

.. literalinclude:: k8s_hosts_file_for_pods/kubectl_logs_hostalias_output
   :caption: 查看创建的测试pods的日志内容就是 hosts 内容


参考
=======

- `Adding entries to Pod /etc/hosts with HostAliases <https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/>`_
