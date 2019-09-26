.. _install_run_local_etcd:

========================
安装运行本地etcd
========================

一个集群中etcd服务的运行数量必须是奇数才能保证稳定。在开发测试环境，可以本地运行一个单一节点单服务 etcd或者一个单机节点etcd集群用于验证功能。

.. note::

   本文实践是开发测试环境单机运行，服务监听 127.0.0.1 端口，所以没有任何安全加密认证，仅供测试。

Linux安装local etcd
=====================

- 执行以下安装::

   ETCD_VER=v3.4.1

   # choose either URL
   GOOGLE_URL=https://storage.googleapis.com/etcd
   GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
   DOWNLOAD_URL=${GOOGLE_URL}

   rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
   rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

   curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
   tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
   rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

   /tmp/etcd-download-test/etcd --version
   /tmp/etcd-download-test/etcdctl version

   sudo cp /tmp/etcd-download-test/etcd /usr/local/sbin/etcd
   sudo cp /tmp/etcd-download-test/etcdctl /usr/local/bin/etcdctl

macOS安装local etcd
=====================

- 执行以下安装::

   ETCD_VER=v3.4.1

   # choose either URL
   GOOGLE_URL=https://storage.googleapis.com/etcd
   GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
   DOWNLOAD_URL=${GOOGLE_URL}

   rm -f /tmp/etcd-${ETCD_VER}-darwin-amd64.zip
   rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

   curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-darwin-amd64.zip -o /tmp/etcd-${ETCD_VER}-darwin-amd64.zip
   unzip /tmp/etcd-${ETCD_VER}-darwin-amd64.zip -d /tmp && rm -f /tmp/etcd-${ETCD_VER}-darwin-amd64.zip
   mv /tmp/etcd-${ETCD_VER}-darwin-amd64/* /tmp/etcd-download-test && rm -rf /tmp/etcd-${ETCD_VER}-darwin-amd64

   /tmp/etcd-download-test/etcd --version
   /tmp/etcd-download-test/etcdctl version

   sudo cp /tmp/etcd-download-test/etcd /usr/local/sbin/etcd
   sudo cp /tmp/etcd-download-test/etcdctl /usr/local/bin/etcdctl

验证local single etcd
========================

- 执行以下命令验证本地运行etcd::

   # start a local etcd server
   /usr/local/sbin/etcd

   # write,read to etcd
   etcdctl --endpoints=localhost:2379 put foo bar
   etcdctl --endpoints=localhost:2379 get foo

运行本地etcd集群
===================

- 安装 `goreman <https://github.com/mattn/goreman>`_ ::

   go get github.com/mattn/goreman

.. note::

   ``go get`` 是标准的下载和安装软件包和依赖的命令，安装执行程序位于 ``~/go/bin`` 目录。

   参考 `"go get" command <https://nanxiao.gitbooks.io/golang-101-hacks/content/posts/go-get-command.html>`_

- 下载etcd提供的学习案例 Procfile.learner ::

   curl https://raw.githubusercontent.com/etcd-io/etcd/master/Procfile -o ~/go/bin/Procfile.learner

- 修改一下 Procfile.learner ，将 ``bin/etcd`` 修改成 ``/usr/local/sbin/etcd`` ，并且启动一个proxy::

   # Use goreman to run `go get github.com/mattn/goreman`
   etcd1: /usr/local/sbin/etcd --name infra1 --listen-client-urls http://127.0.0.1:2379 --advertise-client-urls http://127.0.0.1:2379 --listen-peer-urls http://127.0.0.1:12380 --initial-advertise-peer-urls http://127.0.0.1:12380 --initial-cluster-token etcd-cluster-1 --initial-cluster 'infra1=http://127.0.0.1:12380,infra2=http://127.0.0.1:22380,infra3=http://127.0.0.1:32380' --initial-cluster-state new --enable-pprof --logger=zap --log-outputs=stderr
   etcd2: /usr/local/sbin/etcd --name infra2 --listen-client-urls http://127.0.0.1:22379 --advertise-client-urls http://127.0.0.1:22379 --listen-peer-urls http://127.0.0.1:22380 --initial-advertise-peer-urls http://127.0.0.1:22380 --initial-cluster-token etcd-cluster-1 --initial-cluster 'infra1=http://127.0.0.1:12380,infra2=http://127.0.0.1:22380,infra3=http://127.0.0.1:32380' --initial-cluster-state new --enable-pprof --logger=zap --log-outputs=stderr
   etcd3: /usr/local/sbin/etcd --name infra3 --listen-client-urls http://127.0.0.1:32379 --advertise-client-urls http://127.0.0.1:32379 --listen-peer-urls http://127.0.0.1:32380 --initial-advertise-peer-urls http://127.0.0.1:32380 --initial-cluster-token etcd-cluster-1 --initial-cluster 'infra1=http://127.0.0.1:12380,infra2=http://127.0.0.1:22380,infra3=http://127.0.0.1:32380' --initial-cluster-state new --enable-pprof --logger=zap --log-outputs=stderr

   proxy: /usr/local/sbin/etcd grpc-proxy start --endpoints=127.0.0.1:2379,127.0.0.1:22379,127.0.0.1:32379 --listen-addr=127.0.0.1:23790 --advertise-client-url=127.0.0.1:23790 --enable-pprof

   # A learner node can be started using Procfile.learner

- 启动本地etcd集群::

   goreman -f ./Procfile.learner start

- 现在可以通过etcd-proxy入口来访问::

   etcdctl --endpoints=127.0.0.1:23790 put foor bar
   etcdctl --endpoints=127.0.0.1:23790 get foor

参考
====

- `etcd releases <https://github.com/etcd-io/etcd/releases>`_
- `github etcd <https://github.com/etcd-io/etcd>`_
