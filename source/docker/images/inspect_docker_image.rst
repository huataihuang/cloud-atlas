.. _inspect_docker_image:

========================
检查Docker镜像
========================

我在探索 :ref:`prometheus-webhook-dingtalk_template` ，想将容器中的 ``template.tmpl`` 文件提取出来检查，以便做一些小小修改来满足项目要求。然而，这个 ``timonwong/prometheus-webhook-dingtalk`` 做得非常精简，只提供了一个运行环境，甚至都没有打包 :ref:`shell` (为作者点赞，非常云原生的做法)。但是这也带来一个问题，我该如何检查这个文件呢？至少 ``docker exec -it <container_id> /bin/sh`` 是无法使用了。

``docker export``
=====================

docker提供了一个 ``export`` 指令可以将容器中的文件系统题通过 ``tar`` 输出出来，甚至可以不运行容器:

- 首先 ``create`` 容器(不需要 ``run`` )::

   docker create --name="tmp_$$" timonwong/prometheus-webhook-dingtalk:latest

- 然后可以直接使用 ``export`` 命令输出容器文件列表::

   docker export tmp_$$ | tar t

此时会看到::

   .dockerenv
   bin/
   bin/prometheus-webhook-dingtalk
   boot/
   dev/
   dev/console
   dev/pts/
   dev/shm/
   etc/
   etc/debian_version
   ...
   etc/prometheus-webhook-dingtalk/
   etc/prometheus-webhook-dingtalk/config.yml
   etc/prometheus-webhook-dingtalk/k8s/
   etc/prometheus-webhook-dingtalk/k8s/config/
   etc/prometheus-webhook-dingtalk/k8s/config/config.yaml
   etc/prometheus-webhook-dingtalk/k8s/config/template.tmpl
   etc/prometheus-webhook-dingtalk/k8s/deployment.yaml
   etc/prometheus-webhook-dingtalk/k8s/kustomization.yaml
   etc/prometheus-webhook-dingtalk/k8s/service.yaml
   etc/prometheus-webhook-dingtalk/templates/
   etc/prometheus-webhook-dingtalk/templates/default.tmpl
   etc/prometheus-webhook-dingtalk/templates/issue43/
   etc/prometheus-webhook-dingtalk/templates/issue43/template.tmpl
   etc/prometheus-webhook-dingtalk/templates/legacy/
   etc/prometheus-webhook-dingtalk/templates/legacy/template.tmpl
   ...

- 如果我们需要提取文件，可以使用 ``save`` 命令先将镜像打包成一个 ``tar`` 文件，然后解压出来::

   docker save timonwong/prometheus-webhook-dingtalk:latest > prometheus-webhook-dingtalk.tar
   tar -xvf prometheus-webhook-dingtalk.tar

注意，这里解压缩出来的文件是按照docker文件系统层来列出的::

   $ tree
   .
   ├── 09bc616b7e9a34da47833370f482a89d4bf12c78e9e966b95ad3d5720b5d00bc
   │   ├── json
   │   ├── layer.tar
   │   └── VERSION
   ├── 2571f63daa6afb686869ae2501d092b25386e86ae827c2fa0aabba974e824bcb
   │   ├── json
   │   ├── layer.tar
   │   └── VERSION
   ├── 3dc9b4c4844e1f6451b10d96d9cf0979d2ac62fa92f46123e4a70da373e74b0c.json
   ├── bf6b3566efeb15eab33ca0e022f0cf1704e67c9676e9618f1f6c31fa78e6c379
   │   ├── json
   │   ├── layer.tar
   │   └── VERSION
   ├── f6d821d8bbcde064dc20e35ea47385cdbfe15434bda289545835e17747bbfb7c
   │   ├── json
   │   ├── layer.tar
   │   └── VERSION
   ├── manifest.json
   └── repositories

   4 directories, 16 files

**我们怎么知道这些文件系统的层次关系呢？**

应该是字符串排序，从小到大，也就是 ``ls`` 默认列出的目录顺序(我观察如此)

- 要获取具体文件，需要进入上面4个文件层的目录下，分别解开每个目录下的 ``layer.tar``

- 通过上文方法，我最后在 ``f6d821d8bbcde064dc20e35ea47385cdbfe15434bda289545835e17747bbfb7c/layer.tar`` 中获得::

   $ tree
   .
   ├── config.yml
   ├── k8s
   │   ├── config
   │   │   ├── config.yaml
   │   │   └── template.tmpl
   │   ├── deployment.yaml
   │   ├── kustomization.yaml
   │   └── service.yaml
   └── templates
       ├── default.tmpl
       ├── issue43
       │   └── template.tmpl
       └── legacy
           └── template.tmpl

默认 :ref:`prometheus-webhook-dingtalk_template` 就是解压出来的 ``templates/default.tmpl``

第三方工具
================

`wagoodman / dive <https://github.com/wagoodman/dive>`_ 可以浏览docker镜像，内容层以及提供了多种方法来所见Docker/OCI镜像...待实践

.. figure:: ../../_static/docker/images/dive.gif

参考
=====

- `How to see docker image contents <https://stackoverflow.com/questions/44769315/how-to-see-docker-image-contents>`_
- `docker image inspect <https://docs.docker.com/engine/reference/commandline/image_inspect/>`_
- `How to Inspect a Docker Image’s Content Without Starting a Container <https://www.howtogeek.com/devops/how-to-inspect-a-docker-images-content-without-starting-a-container/>`_
