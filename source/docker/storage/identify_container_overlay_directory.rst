.. _identify_container_overlay_directory:

===============================
根据overlay目录获取对应容器
===============================

一个生产环境的问题排查案例 :ref:`overlay_mount_influnce_rootfs` ，我发现根据overlay目录找到容器在日常维护中很有用，特别是一些目录异常(占用空间)，快速定位到存在异常的容器可以帮助我们迅速缩小排查范围。

简单来说，当系统中 :ref:`docker_overlay_driver` 挂载异常:

.. literalinclude:: overlay_mount_influnce_rootfs/mount_sda3_output
   :caption: 通过 ``mount`` 检查 ``/dev/sda3`` 挂载输出
   :emphasize-lines: 2-4

可以通过以下命令获得每个overlay目录对应的容器:

.. literalinclude:: identify_container_overlay_directory/docker_inspect_overlay_directory
   :caption: 通过 overlay 目录获取容器名

输出:

.. literalinclude:: identify_container_overlay_directory/docker_inspect_overlay_directory_output
   :caption: 通过 overlay 目录获取容器名

进一步，可以通过 ``docker inspect`` 检查容器配置


参考
======

- `How do I identify which container owns which overlay directory? <https://stackoverflow.com/questions/50875513/how-do-i-identify-which-container-owns-which-overlay-directory>`_
