.. _podman_rootless_volumes:

==============================
Podman rootless容器的卷挂载
==============================

在 :ref:`alpine_podman` 实践中发现， ``podman`` 运行 ``rootless`` 容器，默认挂载Host主机卷时，容器内部挂载卷的属主是 ``root`` 。这对普通用户 ``admin`` 身份访问 ``/home/admin`` 非常不方便。

本文在实践基础上学习如何在rootless容器中挂载Host主机卷

动态设置Dockerfile的用户id
=============================

之前在 :ref:`docker_tini` 改进 ``tini`` 脚本时，同时也采用了在 ``Dockerfile`` 开头设置环境变量方式将 ``admin`` 用户的账户 ``uid/gid`` 设置为 ``1000`` :

.. literalinclude:: podman_rootless_volumes/docker_uid_gid
   :caption: ``admin`` 用户的账户 ``uid/gid`` 设置为 ``1000`` 的 Dockerfile
   :emphasize-lines: 5,6,12,13

但是这种Dockerfile设置比较死，假如用户环境的id不是 ``1000`` 就要手工调整Dockerfile，比较麻烦

更好的的方法是在 ``docker build`` 动态传递环境变量:

.. literalinclude:: podman_rootless_volumes/dynamic_uid_gid
   :caption: 动态向Dockerfile传递环境变量

这样构建的 :ref:`docker_images` 就会自动具备和当前环境用户 ``uid/gid`` 一致的容器内部 ``admin`` 账号 ``uid/gid`` ，为下一步运行时匹配 ``/home/admin`` 属主做好准备

运行pod时对齐uid/gid
========================

- 执行 ``podman run`` 时，挂载卷同时传递 ``keep-id`` 的 ``uid/gid`` 环境变量( **传递变量一定要有确定对应值** ):

.. literalinclude:: podman_rootless_volumes/podman_run_keep-id
   :caption: 传递 ``keep-id`` 的 ``uid/gid`` 环境变量方式运行 ``podman run``

参考
=====

- `How to debug issues with volumes mounted on rootless containers <https://www.redhat.com/en/blog/debug-rootless-podman-mounted-volumes>`_
