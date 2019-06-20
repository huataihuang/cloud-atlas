.. _admission_controllers:

==========================
Admission Controllers
==========================

概念
===========

准入控制器(Admission Controller) 是请求已经被认证和授权但还没有执行对象持久化之前，负责拦截发给Kubernetes API server请求的代码片段。准入控制器已经被编译到  ``kube-apiserver`` 二进制代码内，并且可能只能通过集群管理员撇只。

Admission Controller的列表见 `What does each admission controller do? <https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#what-does-each-admission-controller-do>`_ 。

准入控制器列表中有两个特别的控制器：

- :ref:`mutating_admission_webhook`
- :ref:`validating_admission_webhook`

在API中配置了上述两个负责变更和验证的准入控制webhook。准入控制器可能是变更，也可能是验证，或者两者兼而有之。变更孔子起可能在对象被准入时修改对象；验证控制器可能不会修改。




参考
=========

- `Using Admission Controllers <https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers>`_
