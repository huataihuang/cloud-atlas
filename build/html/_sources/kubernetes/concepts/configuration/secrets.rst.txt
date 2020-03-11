.. _secrets:

========================
Kubernetes Secrets
========================

Kubernetes ``secret`` 对象可以村粗和管理敏感信息，例如密码, OAuth令牌和ssh keys等。将这些信息存放到 ``secret`` 可以比将敏感信息存放在Pod定义或容器景象中更为安全和更具伸缩性。

Secrets概览
==============

secret是包含一些诸如密码，令牌或密钥的敏感信息的对象。这些信息可能会存放到指定Pod或镜像中，将这些信息存放到安全对象可以更好控制使用并降低泄漏风险。

要使用一个secret，pod需要引用这个secret。pod使用secret的方法有两种：

- 作为卷里面的文件挂载到容器中
- 通过kubelet为pod拉取镜像

内建的secrets
----------------

- 一些服务帐号通过API证书自动创建和添加secrets

Kubernetes会自动创建包含访问API证书的secrets，并且自动修改pods来使用这种类型的证书。这种自动创建和使用的API证书可以在必要时禁止或覆盖。然而，如果你只是需要安全访问API服务器，则建议使用这个工作流。

详细请参考 :ref:`configure_service_accounts_for_pods`

参考
=========

- `Kubernetes 文档 - Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_
