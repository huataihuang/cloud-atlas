.. _list_container_image:

==========================
列出集群的容器镜像
==========================

列错所有namespaces中的容器镜像
===============================

以下命令可以列出集群所有namespace中容器镜像:

.. literalinclude:: list_container_image/get_pods_images
   :caption: 列出集群中所有pod的容器镜像

输出类似:

.. literalinclude:: list_container_image/get_pods_images_output
   :caption: 列出集群中所有pod的容器镜像的输出

上面的命令中:

- ``kubectl get pods --all-namespaces`` 获取所有pods列表
- ``-o jsonpath={.items[*].spec['initContainers', 'containers'][*].image}`` 获取json格式的实例镜像，此时输出是堆叠在一行里面
- 通过 ``tr`` 将空格替换成换行
- 通过 ``sort`` 排序
- 通过 ``uniq`` 聚合

不过，上述命令没有列出每个镜像的大小，有一个改进命令如下:

.. literalinclude:: list_container_image/get_pods_images_size
   :caption: 获取集群中容器镜像以及大小

输出类似

.. literalinclude:: list_container_image/get_pods_images_size_output
   :caption: 获取集群中容器镜像以及大小输出案例，数字的单位是字节(也可以转换成MB)

列出指定pod中所有container
=============================

列粗一个pod中所有容器::

   kubectl get pods [pod-name-here] -n [namespace] -o jsonpath='{.spec.containers[*].name}'

举例::

   kubectl --kubeconfig admin.kubeconfig -n kube-system get pods apiserver-56c6db8b58-8l4dn -o jsonpath='{.spec.containers[*].name}'

.. note::

   其他案例以后补充

参考
=======

- `List All Container Images Running in a Cluster <https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/>`_
- `How to List All Containers in a Pod in Kubernetes Cluster <https://discuss.devopscube.com/t/how-to-list-all-containers-in-a-pod-in-kubernetes-cluster/429>`_
- `List container images in Kubernetes cluster with SIZE (like docker image ls) <https://stackoverflow.com/questions/62125346/list-container-images-in-kubernetes-cluster-with-size-like-docker-image-ls>`_
