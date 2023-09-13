.. _kubectl-plugins:

=====================
Kubectl插件
=====================

:ref:`kubectl` 插件使用kubectl命令扩展，来构建复杂行为方法，创建新的和自定义特性来扩展 ``kubectl`` 。插件本质上就是一个独立可执行文件，名称以 ``kubetl-`` 开头，只要这个执行文件在 ``PATH`` 的任何位置，就可以通过 ``kubectl`` 运行。

:ref:`krew` 提供了发现和安装开源 ``kubectl`` 插件的能力，这是 `Kubernetes SIG CLI社区 <https://github.com/kubernetes/community/tree/master/sig-cli>`_ 维护的插件管理器

安装kubectl插件
=================

参考
=======

- `用插件扩展 kubectl <https://kubernetes.io/zh-cn/docs/tasks/extend-kubectl/kubectl-plugins/>`_
