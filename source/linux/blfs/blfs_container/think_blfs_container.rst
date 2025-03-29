.. _think_blfs_container:

=========================================
思考BLFS(Beyond Linux from scratch)容器
=========================================

我想在 :ref:`lfs` 基础上运行容器环境，类似 :ref:`docker` ，可能有一些参考:

- `Docker in Linux From Scratch <https://www.linuxquestions.org/questions/linux-from-scratch-13/docker-in-linux-from-scratch-4175612279/>`_

在 :ref:`docker` 容器中构建LFS
================================

除了在 :ref:`lfs` 上构建一个运行容器的环境，另外一个切入角度是反方向，在标准的 :ref:`docker` 中构建 :ref:`lfs` ，也就是从0开始构建自己的发行版镜像。这方面已经有很多人做过并留有经验分享:

- `reddit讨论: Linux container from scratch <https://www.reddit.com/r/docker/comments/1h90e6o/linux_container_from_scratch/>`_
- `Hacker News讨论: Show HN: Build your Linux from Scratch inside Docker with one command <https://news.ycombinator.com/item?id=15909604>`_
- `Make Your Own Bespoke Docker Image <https://zwischenzugs.com/2015/01/12/make-your-own-bespoke-docker-image/>`_
