.. _docker_exit_code:

==========================
Docker容器异常退出码和排查
==========================

在运行docker容器时，可能会看到docker容器异常退出，例如，在 :ref:`alpine_dev` 中，我执行::

   docker run -itd --hostname x-node --name x-node -p 3000:3000 alpine-node:latest

结果发现容器没有启动::

   $ docker ps --all
   CONTAINER ID   IMAGE                COMMAND            CREATED        STATUS            PORTS         NAMES
   31639111bd58   alpine-node:latest   "node app.js"      18 hours ago   Exited (1) 18 hours ago         x-node

最佳实践
============

查找容器以及容器退出码
-------------------------

- 列出所有退出的容器::

   docker ps --filter "status=exited"

- 可以通过容器名字来过滤::

   docker ps -a | grep node

例如输出::

   db28254c826d  alpine-node  "/bin/sh -s"  3 hours ago   Exited (130) 3 hours ago   competent_grothendieck

- 通过以下命令可以直接获取容器的退出码::

   docker inspect <container-id> --format='{{.State.ExitCode}}'

上述案例就是::

   docker inspect db28254c826d --format='{{.State.ExitCode}}'

显示就是退出码::

   130

常见退出码
-------------

.. csv-table:: Docker容器退出常见退出码
   :file: docker_exit_code/docker_exit_code.csv
   :widths: 30, 70
   :header-rows: 1

docker logs
----------------

- 首先检查docker容器日志::

   docker logs x-node

``docker logs`` 命令可以看到异常如下::

   /home/node/code/app.js:3
   # const hostname = '127.0.0.1';
   ^
   
   SyntaxError: Invalid or unexpected token
       at Object.compileFunction (node:vm:352:18)
       at wrapSafe (node:internal/modules/cjs/loader:1032:15)
       ...

显然 ``app.js`` 语法错误 - js 注释应该使用 ``//``

覆盖镜像命令
--------------

由于Dockerfile修改需要重新build，对于调试不是很方便。 ``docker`` 提供了直接覆盖 ``CMD`` 和 ``ENTRYPOINT`` 的方法，也就是直接在 ``docker run`` 命令中传递运行参数::

   docker run -it --entrypoint /bin/bash $IMAGE_NAME -s

上述命令会使容器运行 ``/bin/bash`` ，并获得 ``-s`` 作为 ``CMD`` ，可以覆盖镜像中指令。这样就可以获得一个交互的bash环境: 实际上就是登陆到容器系统中，这样方便在容器中执行命令，检查输出，并查看问题。

举例，我使用如下命令，使用 ``alpine-node`` 镜像运行一个交互shell的容器(但是不执行Dockerfile最后的 ``node app.js`` 命令)::

   docker run -it --entrypoint /bin/sh alpine-node -s

此时就会看到进入容器的应用目录::

   /home/node/code #

可以检查容器，手工运行命令::

   /home/node/code # ls
   app.js
   /home/node/code # df -h
   Filesystem                Size      Used Available Use% Mounted on
   overlay                  31.2G      2.3G     27.4G   8% /
   tmpfs                    64.0M         0     64.0M   0% /dev
   tmpfs                   924.3M         0    924.3M   0% /sys/fs/cgroup
   shm                      64.0M         0     64.0M   0% /dev/shm
   /dev/sda2                31.2G      2.3G     27.4G   8% /etc/resolv.conf
   /dev/sda2                31.2G      2.3G     27.4G   8% /etc/hostname
   /dev/sda2                31.2G      2.3G     27.4G   8% /etc/hosts
   devtmpfs                 10.0M         0     10.0M   0% /dev/null
   devtmpfs                 10.0M         0     10.0M   0% /dev/random
   devtmpfs                 10.0M         0     10.0M   0% /dev/full
   devtmpfs                 10.0M         0     10.0M   0% /dev/tty
   devtmpfs                 10.0M         0     10.0M   0% /dev/zero
   devtmpfs                 10.0M         0     10.0M   0% /dev/urandom
   devtmpfs                 10.0M         0     10.0M   0% /proc/keys
   devtmpfs                 10.0M         0     10.0M   0% /proc/latency_stats
   devtmpfs                 10.0M         0     10.0M   0% /proc/timer_list
   tmpfs                   924.3M         0    924.3M   0% /sys/firmware 
   /home/node/code # node app.js
   Server running at http://${hostname}:${port}/

总之，可以完整实现交互验证

参考
======

- `Find out Why Your Docker Container Keeps Crashing <https://vsupalov.com/debug-docker-container/>`_
- `Understanding Docker Container Exit Codes <https://betterprogramming.pub/understanding-docker-container-exit-codes-5ee79a1d58f6>`_
