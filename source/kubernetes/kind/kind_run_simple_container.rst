.. _kind_run_simple_container:

======================
在kind运行简单的容器
======================

采用 :ref:`alpine_docker_image` 来从0开始一步步完成完整的应用服务器运行集群: 将我的 :ref:`cloud_atlas` WEB网站( :ref:`sphinx_doc` )部署到 :ref:`kubernetes` 模拟 :ref:`kind` 集群中，作为 :ref:`workload_resources` 运行...

准备工作
================

- 首先结合 :ref:`kind_local_registry` 部署一个 :ref:`kind_multi_node` (快速脚本可以采用 :ref:`kind_local_registry` 整合好的脚本 ``kind-with-registry-arm.sh`` ):

.. literalinclude:: kind_run_simple_container/create_kind_multi_node_local_registry
   :language: bash
   :caption: 执行kind-with-registry-arm.sh创建具备本地Registry的kind多节点集群

- 采用 :ref:`alpine_docker_image` 创建的 :ref:`alipine-nginx` 镜像:

.. literalinclude:: kind_run_simple_container/build_alpine-nginx_image_push_local_registry
   :language: bash
   :caption: 创建具备nginx的alpine linux镜像并推送到本地Registry

运行容器
===========

- 准备一个简单 :ref:`workload_resources` : 运行2个pod ``deployment-simple.yaml`` :

.. literalinclude:: kind_run_simple_container/deployment-simple.yaml
   :language: yaml
   :caption: 简单运行2个pod的deployment-simple.yaml

- 部署采用 ``kubectl create`` :

.. literalinclude:: kind_run_simple_container/kubectl_create_deployment-simple
   :language: bash
   :caption: kubectl执行部署

pod创建问题排查
=================

- 检查::

   kubectl get pods -o wide

可以看到::

   NAME                               READY   STATUS             RESTARTS      AGE    IP           NODE          NOMINATED NODE   READINESS GATES
   nginx-deployment-c64787574-j5hsl   0/1     CrashLoopBackOff   4 (31s ago)   2m4s   10.244.3.3   dev-worker2   <none>           <none>
   nginx-deployment-c64787574-n6wvw   0/1     CrashLoopBackOff   4 (27s ago)   2m4s   10.244.5.2   dev-worker4   <none>           <none>

启动失败 ``CrashLoopBackOff`` ，参考 :ref:`k8s_crashloopbackoff`

- 检查pod详情采用 ``kubectl describe pods`` 命令::

   kubectl describe pods nginx-deployment-c64787574-j5hsl

可以看到事件如下::

   Events:
     Type     Reason     Age                    From               Message
     ----     ------     ----                   ----               -------
     Normal   Scheduled  3m45s                  default-scheduler  Successfully assigned default/nginx-deployment-c64787574-j5hsl to dev-worker2
     Normal   Pulling    3m45s                  kubelet            Pulling image "localhost:5001/alpine-nginx:20221126-01"
     Normal   Pulled     3m45s                  kubelet            Successfully pulled image "localhost:5001/alpine-nginx:20221126-01" in 138.657406ms
     Normal   Created    2m13s (x5 over 3m45s)  kubelet            Created container nginx
     Normal   Started    2m13s (x5 over 3m45s)  kubelet            Started container nginx
     Normal   Pulled     2m13s (x4 over 3m44s)  kubelet            Container image "localhost:5001/alpine-nginx:20221126-01" already present on machine
     Warning  BackOff    2m12s (x9 over 3m43s)  kubelet            Back-off restarting failed container

为何启动容器失败?

- 使用以下命令登录到 ``dev-worker2`` node节点中::

   docker exec -it dev-worker2 /bin/bash


