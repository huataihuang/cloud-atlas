.. _private_helm_repo:

=====================
私有Helm仓库
=====================

在Kubernetes部署中，我们常用的 :ref:`helm` 包管理提供了快捷的本地文件系统安装或远程chart仓库安装。本质上，一个chart repository实际上就是一个HTTP :ref:`web` 服务器，保存了一个 ``index.yaml`` 文件以及相应的一堆 ``.tgz`` 文件。

所以，我们可以自己定制一个Helm仓库，或者直接使用 GitHub ( :ref:`gitlab` )作为自己的私有Helm仓库，方便快速部署Kubernetes应用。

待续

参考
======

- `Using a Private GitHub Repository as a Helm Chart Repository <https://dev.to/frosnerd/using-a-private-github-repository-as-a-helm-chart-repository-5fa8>`_
- `The Chart Repository Guide <https://helm.sh/docs/topics/chart_repository/>`_
