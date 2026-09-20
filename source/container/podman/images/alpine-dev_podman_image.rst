.. _alpine-dev_podman_image:

==============================
``alpine-dev`` Podman image
==============================

.. note::

   在 :ref:`alpine_podman_image` 基础上结合轻量级开发环境设置

构建
======

.. literalinclude:: alpine-dev_podman_image/alpine-dev/Dockerfile
   :language: dockerfile
   :caption: alpine轻量级开发环境设置

其中 ``entrypoint.sh`` 脚本如下:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/entrypoint.sh
   :language: bash
   :caption: entrypoint.sh 提供对Docker环境进行修正

构建镜像:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/build
   :language: bash
   :caption: 构建镜像

.. warning::

   实际上为了解决GFW，需要设置代理才能pull镜像，但是为了避免代理环境变量污染容器镜像构建，在build时还需要 **显式** 清理调代理环境变量，所以实际build命令如下:

   .. literalinclude:: alpine-dev_podman_image/alpine-dev/build_with_proxy
      :caption: 结合代理构建镜像

然后再运行:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/run
   :language: bash
   :caption: 运行podman

异常排查
=========

整个实践过程其实非常波折，最大的困难就是 :ref:`across_the_great_wall` ，其次是存储问题

代理影响
-----------

- 安装过程 ``pip`` 报错:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/pip_error
   :caption: ``pip install`` 安装模块报错

实际上我为了能够避免代理全局影响，特意取消了Dockerfile开头的 ``ENV http_proxy=socks5://127.0.0.1:1082`` 改为在执行 ``curl`` 命令前设置环境变量:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/curl_proxy
   :caption: 最初设置的curl代理配置
   :emphasize-lines: 2,3

这里可能存在一些混乱，我采用 ``&&`` 连接多条命令，但是属于一条Dockerfile ``RUN`` 命令，其实就相当于一个shell会话，那么在 ``curl`` 命令前设置的这个环境变量一直保留着，影响到后面的 ``pip install`` 命令。

解决的方法有两种:

一种是拆分RUN命令，因为对Dockerfile来说每个RUN命令就是一次全新的shell环境:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/split_run
   :caption: 拆分RUN语句，将代理的语句和非代理语句分开

另一种方法是将 ``curl`` 代理限制在 **子Shell** 中，也就是添加一个 ``()`` :

.. literalinclude:: alpine-dev_podman_image/alpine-dev/curl_proxy_subshell
   :caption: 将设置的curl代理配置限制在 **子Shell** 中，即添加 ``()``

但是万万没有想到还是没有解决(已经尝试将pip命令放到设置proxy执行curl命令行之前，确保proxy设置不影响pip)，看起来确实访问 ``pypi.org`` 存在干扰?

(后备方案)显式使用国内镜像源来避开 ``pipy`` 官方源TLS握手不稳定的问题:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/pip_mirror_site
   :caption: 使用国内镜像网站安装pip

**找到原因了**

原来 **Podman自动继承宿主机代理** :

和 :ref:`docker_proxy` 不同，Podman在设计上为了方便用户在代理环境下构建，默认会自动将宿主Shell中的 ``http_proxy`` , ``https_proxy`` , ``HTTP_PROXY`` , ``HTTPS_PROXY`` 以及 ``no_proxy`` 作为默认的 ``--build-arg`` 传递给Dockerfile中每个 ``RUN`` 命令。

也就是说，即使 Dockerfile 中没有写 ``ARG http_proxy`` ，Podman在后台也会默默把它传进去!!!

这就是为什么我以为Dockerfile没有代理，但是容器 ``RUN pip install`` 依然从环境变量中读到了 ``socks5://127.0.0.1:1082`` 从而触发了 ``SSLError(SSLEOFError)`` 报错。

我之所以在 ``podman build`` 之前就在shell中使用了代理设置，是因为 ``dockerhub`` ( hub.docker.com )被GFW屏蔽了，要下载 Alpine Linux 的初始镜像必须开启代理。

这里的矛盾就是一旦在执行 ``podman build`` 时激活了代理环境变量，该环境变量就会被注入Dockerfile的整个构建过程，即使Dockerfile中没有配置代理也如此。

**解决的方法是在podman build时显式传入 --build-arg http_proxy="" ... 在命令中将代理参数显式清空**

.. literalinclude:: alpine-dev_podman_image/alpine-dev/podman_build_clean_proxy
   :caption: 执行 ``podman build`` 时显式清理调为pull镜像添加的代理环境变量

.. note::

   原来Podman会默认将proxy环境变量注入容器构建，这个发现确实解释了为何我在build时候感觉明显的缓慢，原来每个 ``apk add`` 命令都是经过代理，导致网络速度降低。

修改文件id的问题
---------------------

- 执行运行报错

.. literalinclude:: alpine-dev_podman_image/alpine-dev/run_admin_home_data
   :caption: 运行 ``参数不合适``

报错:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/run_error
   :caption: 运行报错

这是因为我写错了镜像名字 ``localhost/alpine-dev_dev-env`` ，导致触发了Podman自动拉取机制尝试访问网络上的镜像仓库。由于使用了 ``localhost`` 导致podman以为本地有一个registry进行拉取。

``storage-chown-by-maps`` 异常
----------------------------------

- ``podman run`` 长时间没有反应，检查 ``top`` 发现有一个 ``storage-chown-by-maps`` 在疯狂读写，下面是在 :ref:`alpine_linux` 上 ``top`` 显示输出的负载最高的3个进程:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/run_storage-chown-by-maps
   :caption: 启动时进程 ``storage-chown-by-maps`` 在修改目录文件

这个问题困扰了我很久，gemini提示是因为 ``Dockerfile`` 中切换用户账号加上采用podman rootless导致的，也就是说，在Dockerfile中

但是，我按照提示将所有root身份的Dockerfile部分放在前面，只在Dockerfile最后部分采用了 ``USER admin`` 身份执行一些HOME目录下的 ``pip install`` 等操作，并且最后申明 ``USER admin`` :

.. literalinclude:: alpine-dev_podman_image/alpine-dev/user_admin_dockerfile
   :caption: 将admin身份的Dockerfile配置集中到后半部分

但是，一番折腾下来，我发现 ``podman run`` 依然通常出现了一个 ``storage-chown-by-maps`` 进程在疯狂读写磁盘:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/storage-chown-by-maps
   :caption: 一个疯狂读写磁盘的 ``storage-chown-by-maps`` 进程

这个问题在于我的运行命令:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/run_admin_home_data
   :caption: 运行命令中 ``:z`` 参数触发chown
   :emphasize-lines: 5,8-10

对于podman，当使用了 ``--userns keep-id`` ，Podman在启动阶段会检查和同步容器内部曾与宿主机的存储映射(Storage SubUID Mapping)，在老旧机器特别是老款SATA SSD上，磁盘随机IO会被堵死。

以前我使用这个运行参数没有发现问题是因为当时使用的是非常高性能的 :ref:`nvme` 存储，NVMe特有的随机IO高性能并发处理比传统SATA SSD **快100倍** ，所以很快完成没有发现这个异常。这次在Host主机的 ``/home/admin/docs`` 目录下有一个2GB的海量小文件的目录，就导致我的孱弱的 :ref:`mba11_late_2010` 暴露出这个问题。

:strike:`解决方法修改运行参数，将 --userns keep-id 修改成 --userns=host` 不行

两种解决方案对比
~~~~~~~~~~~~~~~~~

一种绕过的方法是使用 ``--user=admin`` 替代 ``--user 1000:1000 --userns keep-id`` :

.. literalinclude:: alpine-dev_podman_image/alpine-dev/run_admin
   :caption: 仅指定 ``--user=admin`` 但不设置uid,gid对应映射

这个过程确实会带来闪电般的快速启动，并且进入容器内部看到的就是 ``admin`` 用户身份:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/run_admin_time
   :caption: 仅指定 ``--user=admin`` 启动如同闪电

但是，这个解决方案有缺陷:

- 使用纯 ``--user admin`` (不加 ``--userns keep-id`` ) ，Podman在Host主机上分配的静态映射区通常是从 ``100000`` 开始(取决于 ``/etc/subuid`` )
- 容器内 ``root`` (UID 0) **对应** Host主机上的 ``100000``
- 容器内 ``admin`` (UID 1000) **对应** Host主机上的 ``100999`` (即 ``100000+1000-1`` )
- 当卷挂载(如 ``/workspace`` )时，容器内 ``admin`` 创建的文件落到Host磁盘上后，属主会显示为 ``100999:100999`` ，与Host上真正的 ``admin`` (UID 1000)彻底脱节，引发读写权限隔离或冲突

另一种方法是保持 ``--user 1000:1000 --userns keep-id`` ，这个方案实际上是Rootless标准做法:

- 构建阶段( ``podman build`` ):

  - 镜像内的 ``root`` (UID 0) 被物理写入Host主机磁盘为 UID ``100000``
  - 镜像内的 ``admin`` (UID 0) 写入Host主机磁盘为 UID ``100999`` (100000+1000-1)
  - 此时镜像中每一个只读层(Read-Only Layer)在宿主机磁盘上的UID/GID属性已经固定下来

- 运行阶段( ``podman run --user 1000:1000 --userns keep-id`` )，强制把容器内的 ``admin`` (UID 1000)直接绑定到宿主机的真实 ``admin`` (UID 1000)，这意味着Podman必须重建一套全新的映射关系(User Namespace Mapping):

  - 此时镜像只读层里的文件在宿主机磁盘上的实际属主依然是旧账本的 ``100999`` 但是新账本要求容器内UID 1000对应宿主机的UID 1000: 这就带来容器内 ``admin`` 无法读写 ``/home/admin`` 目录下的文件，因为那些文件在创建镜像时保存为 ``UID 100999``
  - 为了解决这个UID映射和文件不一致问题，Podman在调用 ``containers/storage`` 挂载容器层是，必须由 ``storage-chown-by-maps`` 辅助工具在宿主机Mountpoint( ``/home/admin/.local/share/containers/storage/overlay/<HASH>/merged`` )上执行以下4个阶段的工作:

.. literalinclude:: alpine-dev_podman_image/alpine-dev/storage-chown-by-maps_steps
   :caption: ``storage-chown-by-maps`` 执行4个步骤

.. note::

   由于 Linux OverlayFS 机制的限制，它无法像传统文件系统那样“一行命令改变整个挂载点”。 ``storage-chown-by-maps`` 必须调用 ``filepath.Walk`` 或 ``fts_read`` 算法:

   - 深度优先递归遍历：从 / 根目录开始，递归扫描镜像中每一层的每一个目录、文件、软链接、设备节点。
   - 文件基数放大: 当镜像中安装了大量的软件和工具会导致需要遍历扫描的节点（Inode）数量达到数十万计。

.. note::

   OverlayFS Copy-Up 复制上移与元数据写盘:

   - Linux 内核的 OverlayFS 会触发 Copy-Up（复制上移） 动作——将该文件从只读层完整复制一份到 UpperDir（可写层）或元数据暂存区，然后再修改其 UID。
   - 这意味着不仅有巨量的随机 Inode 读写，还会伴随着大量小文件的磁盘拷贝与元数据 Flush（同步刷新到磁盘）。

.. csv-table:: 两种模式的权衡对比
   :file: alpine-dev_podman_image/alpine-dev/userns_keep-id_compare.csv
   :widths: 20,40,40
   :header-rows: 1

实际效果
~~~~~~~~~

老旧硬件上的物理瓶颈(I/O 放大效应):

- CPU 瓶颈: :ref:`mba11_late_2010` 的 Core 2 Duo 双核处理器在处理数十万次单线程/多线程 ``fchownat`` 系统调用时，CPU 会长时间陷入内核态（System Time 100%）
- 磁盘 IOPS 瓶颈: 早期 SATA 接口 SSD 的随机 4K 读写（IOPS） 非常低。数十万次递归遍历 + 修改元数据，会产生极其可怕的磁盘寻道与写放大，导致磁盘队列深度（Queue Depth）瞬间爆表，系统产生极高的 ``iowait`` 假死现象。

我实测在 :ref:`mba11_late_2010` 第一次启动耗时高达 **15分钟** :

而在我租用的使用 :ref:`nvme` 存储的VPS虚拟机中，只需要十几秒钟就能完成启动。

``好消息`` 是: **第二次启动（或重启）会瞬间完成**

- **持久化结果(Persistence)** ：``storage-chown-by-maps`` 的重转换结果是 **一次性** 的。修改完成后，对应的映射关系已经被物理写入并记录在 Podman 本地存储驱动( ``~/.local/share/containers/storage/overlay/`` )的容器独占层中。
- **复用 Overlay 索引** : 再次执行 ``podman start`` 或重新创建挂载该持久化层的容器时，Podman 检测到该容器层的 UserNS 映射转换已经完成，会直接 ``mount -t overlay`` 加载，彻底跳过扫描，秒级启动。

参考
======

- gemini
