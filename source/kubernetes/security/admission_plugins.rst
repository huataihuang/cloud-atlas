.. _admission_plugins:

==========================
Admission 插件
==========================

检查默认启用的admission plugins
==================================

- ``kube-apiserver`` 提供了查询哪些插件是默认启用:

.. literalinclude:: admission_plugins/apiserver_default_admission_plugins
   :caption: 检查默认启用的Admission Plugins

不过，需要注意的是，默认通过 :ref:`kubespray` 部署的 ``kube-apiserver`` 容器内部没有提供任何 ``sh`` 命令，所以我参考 `How to access kube-apiserver on command line? <https://stackoverflow.com/questions/56542351/how-to-access-kube-apiserver-on-command-line>`_ 想要登陆到容器内部并没有成功。不过，还是可以通过以下命令观察:

.. literalinclude:: admission_plugins/kubectl_apiserver_default_admission_plugins
   :caption: 通过 ``kubectl`` 运行pod内部的 ``kube-apiserver`` 检查默认启用的Admission Plugins

输出类似(注意：输出实际是一行，我这里为了方便查看做了多行格式化)

.. literalinclude:: admission_plugins/kubectl_apiserver_default_admission_plugins_output
   :caption: 通过 ``kubectl`` 运行pod内部的 ``kube-apiserver`` 检查默认启用的Admission Plugins 输出

.. _admission_plugins_DefaultStorageClass:

Admission Plugin ``DefaultStorageClass``
-------------------------------------------

Admission Plugin ``DefaultStorageClass`` 为 **没有请求任何特定存储类** 的 ``PersistentVolumeClaim`` (PVC) 对象的创建请求，自动添加默认存储类。这样用户无需关心存储类型(很多用户也不care)，就可以自动完成配置。

注意，当没有配置默认存储类是，这个Adminssion Controller不执行任何操作。而且，如果有多个存储类被标记为默认存储类，也会导致该控制器拒绝所有创建 PVC 的请求并返回错误。

参考
=========

- `Using Admission Controllers <https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers>`_
