.. _kind_deploy_fedora-dev-tini:

===============================================
kind部署 ``fedora-dev-tini`` (tini替代systmed)
===============================================

在完成 :ref:`fedora_tini_image` 制作之后，将镜像推送到 :ref:`kind_local_registry` 再次尝试部署个人开发环境( 暂时放弃 :ref:`kind_deploy_fedora-dev` )

准备工作
============

- 将制作完成的 :ref:`fedora_tini_image` ``fedora-dev-tini`` 打上tag并推送Local Registry:

.. literalinclude:: kind_deploy_fedora-dev-tini/push_fedora-dev-tini_registry
   :language: bash
   :caption: 将 ``fedora-dev-tini`` 镜像tag后推送Local Registry

部署
========

简单部署
----------

- 参考 :ref:`k8s_deploy_squid_startup` 相似部署:

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-deployment.yaml
   :language: yaml
   :caption: 部署到kind集群的fedora-dev-tini-deployment.yaml

- 部署:

.. literalinclude:: kind_deploy_fedora-dev-tini/deploy_fedora-dev-tini
   :language: bash
   :caption: 将 ``fedora-dev-tini`` 部署到kind集群

- 如果一切正常(显然不会这么简单，见下文我的折腾)，此时会看到::

   % kubectl get pods
   NAME                                READY   STATUS    RESTARTS     AGE
   fedora-dev-tini-6d6d88c84f-864s7    1/1     Running   0            25s

   % kubectl get services
   NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                 AGE
   fedora-dev-service   ClusterIP   10.96.175.32    <none>        22/TCP,80/TCP,443/TCP   47h

.. note::

   由于 ``fedora-dev-tini`` 是用于开发的容器，和服务容器有所区别:

   - (可选)如果 :ref:`configure_liveness_readiness_and_startup_probes` 应该仅检测默认启动的 :ref:`ssh` 服务端口，不检测其他服务端口(http/https)，因为开发主机不能保证WEB服务始终可用，但ssh服务是始终提供的

.. note::

   部署成功也仅是第一步，因为还需要配置 :ref:`kind_ingress` 和 :ref:`kind_loadbalancer` 才能对外提供服务

异常排查
============

.. note::

   我在实践中，按照上文部署 ``fedora-dev-tini`` 遇到很多波折，原因是我最初构建 :ref:`fedora_tini_image` 时使用的 ``/entrypoint.sh`` 脚本采用的是 :ref:`docker_tini` 的 ``entrypoint_ssh_cron_bash`` :

   .. literalinclude::  ../../docker/images/fedora_tini_image/ssh/entrypoint_ssh_cron_bash
      :language: bash
      :caption: 采用 :ref:`docker_tini` 的 ``entrypoint_ssh_cron_bash`` 存在缺陷，Kubernetes会判断命令运行结束，导致pod不断Crash

   排查和修正方法见下文，实际通过改进 ``/entrypoint.sh`` 脚本来解决(见最后)

覆盖Dockerfile的 ``ENTRYPOINT`` 和 ``CMD``
---------------------------------------------

- 和 :ref:`kind_deploy_fedora-dev` 类似，启动的 ``fedora-dev-tini`` pod也存在 ``CrashLoopBackOff`` ，所以采用 :ref:`configure_liveness_readiness_and_startup_probes` 中强制配置:

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-force-deployment.yaml
   :language: yaml
   :caption: 部署到kind集群强制启动 ``fedora-dev-tini-force``
   :emphasize-lines: 41-46,49-58

- 强制启动:

.. literalinclude:: kind_deploy_fedora-dev-tini/deploy_fedora-dev-tini-force
   :language: yaml
   :caption: 部署到kind集群强制启动 ``fedora-dev-tini-force``

奇怪，在Docker环境中运行 ``fedora-dev-tini`` 是自动启动了 ``sshd`` 和 ``crond`` ，这说明镜像工作正常， 镜像根目录下的 ``/tini`` 和 ``entrypoint.sh`` 脚本是正常运行的，为何到了 ``kind`` 环境不能工作了？

参考 :ref:`entrypoint_vs_command` 的对比表:

.. csv-table:: Docker和Kubernetes的ENTRYPOINT和COMMAND的对应关系
   :file: ../deploy_app/app_inject_data/entrypoint_vs_command/entrypoint_vs_command.csv
   :widths: 40,30,30
   :header-rows: 1

Kubernetes 的 ``command`` 和 ``args`` 分别覆盖 :ref:`dockerfile` 的 ``Entrypoint`` 和 ``Cmd`` ，也就是说，这里强制启动的 ``fedora-dev-tini-force-deployment.yaml`` 配置行::

     spec:
       containers:
       - args:
         - date; sleep 10; echo 'Hello from fedora-dev'; touch /tmp/healthy; sleep 1; while
           true; do sleep 120; done;
         command:
         - /bin/bash
         - -ec

实际上完整覆盖掉了 :ref:`fedora_tini_image` 镜像中定义的 ``Entrypont`` 和 ``Cmd`` ，也就是完全不运行 :ref:`dockerfile` 中的命令，所以强制启动仅仅是用于检查镜像内容，而不适合验证Docker容器是否正常运行。

仅覆盖Dockerfile的 ``CMD``
-----------------------------

如果不是怀疑 Dockerfile 中的 ``Entrypoint`` 异常( :ref:`docker_tini` 是标准程序，通常不会出错 )，那么在 Kubernetes的 yaml 文件中，就不要定义 ``command`` ，只定义 ``args`` 。这要就巧妙地覆盖掉了 :ref:`fedora_tini_image` 中的运行参数，也就是传递给 :ref:`docker_tini` 的运行脚本 ``/entrypoint.sh`` ，而代之以自己定义的替代脚本(一定是准确运行的，生成一个检测文件)::

     spec:
       containers:
       - name: fedora-dev-tini
         image: localhost:5001/fedora-dev-tini:latest
         args:
         - /bin/sh
         - -c
         - touch /tmp/healthy; sleep 10; echo 'Hello from fedora-dev-tini'; date; while
           true; do (sleep 120; echo 'Hello from fedora-dev-tini'; date); done
         livenessProbe:
           exec:
             command:
             - cat
             - /tmp/healthy
           initialDelaySeconds: 5
           periodSeconds: 5

这样，仅仅覆盖 ``/entrypoint.sh`` 还是可以验证 ``/tini`` 是否运行正确

- 尝试 ``fedora-dev-tini-args-deployment.yaml`` :

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-args-deployment.yaml
   :language: yaml
   :caption: 保留tini运行，采用k8s的args覆盖Dockerfile的CMD来运行pod: fedora-dev-tini-args-deployment.yaml
   :emphasize-lines: 47-57

- 启动::

   kubectl apply -f fedora-dev-tini-args-deployment.yaml

果然可以启动::

   % kubectl get pods
   NAME                                    READY   STATUS             RESTARTS        AGE
   fedora-dev-tini-args-7d588768f-6gbhg    1/1     Running            0               11s

登陆到这个启动容器中检查 ``top`` 显示:

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-args-top
   :language: bash
   :caption: 保留tini运行，采用k8s的args覆盖Dockerfile的CMD来运行pod: 容器内检top查进程可以看到tini正常运行
   :emphasize-lines: 8

简化部署，仅配置一个端口
-------------------------------

既然 ``tini`` 能正常运行，而且我看到其实最早的部署其实有一瞬间是 ``running`` 状态的，推测是服务检测错误。我是不是定义了太多的服务(实际只有 :ref:`ssh` 在容器中启动)，而没有配置 ``livenessProbe`` ，则默认可能是检测所有配置的端口?

- 简化配置 ``fedora-dev-tini-1port-deployment.yaml``

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-1port-deployment.yaml
   :language: yaml
   :caption: 简化配置，只配置一个ssh服务端口: fedora-dev-tini-1port-deployment.yaml
   :emphasize-lines: 10-14,35-38

依然 ``CrashLoopBackOff``

- 参考 :ref:`configure_liveness_readiness_and_startup_probes` 添加一个简单的端口侦测 ``livenessProbe`` :

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-1port-live-deployment.yaml
   :language: yaml
   :caption: 为ssh服务端口配置livenessProbe: fedora-dev-tini-1port-live-deployment.yaml
   :emphasize-lines: 10-14,35-38

依然 ``CrashLoopBackOff`` ，检查 ``get pods xxx -o yaml`` 显示::

   status:
     conditions:
     - lastProbeTime: null
       lastTransitionTime: "2023-01-28T09:17:05Z"
       status: "True"
       type: Initialized
     - lastProbeTime: null
       lastTransitionTime: "2023-01-28T09:17:05Z"
       message: 'containers with unready status: [fedora-dev-tini-1port-livefile]'
       reason: ContainersNotReady
       status: "False"
       type: Ready

奇怪，我改为一定成功的 ``livenessProbe`` ，也就是检查 ``ls /etc/hosts`` 文件:

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-1port-livefile-deployment.yaml
   :language: yaml
   :caption: livenessProbe只检测必定存在的文件: fedora-dev-tini-1port-livefile-deployment.yaml
   :emphasize-lines: 10-14,35-38

还是同样的 ``ContainersNotReady``

等等，怎么是 ``ContainersNotReady`` ，难道必须配置 ``ContainersNotReady`` ?

修订再加上 ``readinessProbe`` :

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-1port-livefile-readyfile-deployment.yaml
   :language: yaml
   :caption: livenessProbe和readinessProbe检测必定存在的文件: fedora-dev-tini-1port-livefile-readyfile-deployment.yaml
   :emphasize-lines: 10-14,35-38

还是同样的 ``ContainersNotReady``

到底是什么原因的导致明明能够正常运行的 ``tini`` init服务(前面已经验证通过 ``args`` 覆盖掉 Dockerfile 中的 ``/entrypoint.sh`` 可以启动pod，并且在容器内部 ``tini`` 进程运行正常)。但是 ``/entrypoint.sh`` 脚本也看不出什么毛病，在启动后的容器中运行 ``/entrypoint.sh`` 完全正常...

突然， "灵光一闪" : 等等，所有的 ``livenessProbe`` 都是采用了一个无限循环的检测脚本，脚本永远在执行...而 ``/entrypoint.sh`` 脚本启动 ``sshd`` 和 ``crond`` 之后，执行的是一个没有任何命令参数的 ``bash`` ，直接返回控制台，虽然 ``$?`` 是 ``0`` 表示成功，但是这不是对于 Kubernetes 来说程序已经执行完了么? 难怪 ``kubectl get pods`` 时候能够看到pod的很短的一段时间闪过 ``running`` 然后立即转为 ``completed`` ，接着就是无限循环的 ``Crash`` : Kubernetes 判断容器程序终止了呀!!!

- 马上模仿 ``livenessProbe`` 改写一个简化版部署:

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-simple.yaml
   :language: yaml
   :caption: 简化版配置，通过 ``args`` 覆盖 Dockerfile 中启动sshd的 entrypoint.sh 脚本，但是这次 ``args`` 附带了一个永远不结束的循环脚本
   :emphasize-lines: 35-41

- 部署 ``fedora-dev-tini-simple`` :

.. literalinclude:: kind_deploy_fedora-dev-tini/deploy_fedora-dev-tini-simple
   :language: yaml
   :caption: 部署简化版配置，通过 ``args`` 覆盖Dockerfile 中启动sshd的 entrypoint.sh 脚本，但是这次 ``args`` 附带了一个永远不结束的循环脚本

WOW，终于启动起来了:

.. literalinclude:: kind_deploy_fedora-dev-tini/check_fedora-dev-tini-simple
   :language: yaml
   :caption: 部署简化版配置 ``fedora-dev-tini-simple`` 使用无限循环的脚本使得Kubernetes判断容器持续运行，检查容器内部可以看到 sshd 在 tini 进程管理下运行
   :emphasize-lines: 10,12,20

解决方法
---------------

经过上述的反复尝试，可以归纳以下思路:

- 最简单的 Kubernetes deployment 可以不用 :ref:`configure_liveness_readiness_and_startup_probes`
- 但是一定要确保 :ref:`dockerfile` 最后 ``ENTRYPOINT`` + ``CMD`` 是一个持续运行的前台程序，否则 Kubernetes 会判断应用运行结束，进入 ``Completed`` 状态。此时不管有没有配套 :ref:`configure_liveness_readiness_and_startup_probes` 都会判断pod出现了 ``Crash`` ，除非配置一个Kubernetes的 ``args`` 覆盖掉 :ref:`dockerfile` 中的 ``CMD`` 且这个 ``args`` 是始终运行的无限脚本

我的解决方法就是改写 :ref:`fedora_tini_image` 中的 ``/entrypoint.sh`` 脚本，将最后的 ``/bin/bash`` 改写成持续运行输出信息的循环脚本:

.. literalinclude:: ../../docker/images/fedora_tini_image/ssh/entrypoint_ssh_cron_bash
   :language: bash
   :caption: 改写 ``/entrypoint.sh`` 脚本，确保持续运行(循环)
