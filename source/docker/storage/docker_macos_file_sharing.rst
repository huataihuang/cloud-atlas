.. _docker_macos_file_sharing:

===================================
Docker Desktop for macOS文件共享
===================================

思路
=======

对于 ``Docker Desktop for macOS`` 虽然可以在容器运行时通过 ``-v`` 参数将卷影射到容器内部，但是对于 :ref:`kind` 集群，已经部署的容器节点该如何影射:

- 部署一个 ``nfs-sharing`` 容器，这个容器将物理主机的本地磁盘目录 ``docs/data`` 挂载到该容器的 ``/data`` 目录下
- 在 ``nfs-sharing`` 容器内部运行NFS共享，将 ``/data`` 目录共享给 ``kind`` 集群
- 配置 ``PV/PVC`` ，这样可以在 ``kind`` 集群启动后部署的容器都能够挂载NFS，也就实际通过 ``nfs-shareing`` 存储到了物理主机上

待实践...

参考
=======

- `File Sharing with Docker Desktop <https://www.docker.com/blog/file-sharing-with-docker-desktop/>`_
