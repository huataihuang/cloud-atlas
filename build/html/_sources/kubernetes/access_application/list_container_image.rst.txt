.. _list_container_image:

==========================
列出集群的容器镜像
==========================

列出指定pod中所有container
=============================

列粗一个pod中所有容器::

   kubectl get pods [pod-name-here] -n [namespace] -o jsonpath='{.spec.containers[*].name}'

举例::

   kubectl --kubeconfig admin.kubeconfig -n kube-system get pods apiserver-56c6db8b58-8l4dn -o jsonpath='{.spec.containers[*].name}'

参考
=======

- `List All Container Images Running in a Cluster <https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/>`_
- `How to List All Containers in a Pod in Kubernetes Cluster <https://discuss.devopscube.com/t/how-to-list-all-containers-in-a-pod-in-kubernetes-cluster/429>`_
