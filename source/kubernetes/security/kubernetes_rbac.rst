.. _kubernetes_rbac:

====================
Kubernetes RBAC鉴权
====================

RBAC(Role-based Access control)访问控制模型
=============================================

基本的RBAC模型中定义了三个对象和两个关系，三个对象分别是：user，role，resourc。一个用户可以属于多个角色，而一个角色下面也可以有多个用户。同样，角色和权限之间也是这种多对多的关系。

.. figure:: ../../_static/kubernetes/security/rbac_relation.png
   :scale: 80

RBAC支持公认的安全原则：

- 最小特权原则
- 责任分离原则
- 数据抽象原则

RBAC支持数据抽象的程度与RBAC模型的实现细节有关。

RBAC缺点:

- RBAC模型没有提供操作顺序控制机制。这一缺陷使得RBAC模型很难应用关于那些要求有严格操作次序的实体系统。

Kubernetes和RBAC鉴权
======================

基于角色（Role）的访问控制（RBAC）是一种基于组织中用户的角色来调节控制对计算机或网络资源的访问的方法。在Kubernetes中，RBAC 鉴权机制使用 ``rbac.authorization.k8s.io`` API组来驱动鉴权决定，允许通过Kubernetes API 动态配置策略。

要启用RBAC，在启动API服务器时将 ``--authorization-mode`` 参数设置为一个逗号分隔的列表并确保其中包含 ``RBAC`` ::

   kube-apiserver --authorization-mode=Example,RBAC --<其他选项> --<其他选项>

.. note::

   在默认部署的Kubernetes集群，默认启用的认证模式参数是 ``--authorization-mode=Node,RBAC``

Kubernetes的API对象
====================

RBAC API 声明了四种 Kubernetes 对象:

- Role
- ClusterRole
- RoleBinding
- ClusterRoleBinding

Role 和 ClusterRole
---------------------

Role和ClusterRole的区别在于作用域:

- Role 总是用来在某个名字空间内设置访问权限；在创建 Role 时，必须指定该 Role 所属的名字空间。
- ClusterRole 则是一个集群作用域的资源:

  - 集群范围资源(例如节点Node)
  - 非资源端点(例如 ``/helthz`` )

注意：Kubernetes对象要么是名字空间作用域，要么是集群作用域，不可两者兼具。

ClusterRole的使用案例:

- 定义对某名字空间域对象的访问权限，并将在各个名字空间内完成授权
- 为名字空间作用域的对象设置访问权限，并跨所有名字空间执行授权
- 为集群作用域的资源定义访问权限

如果你希望在名字空间内定义角色，应该使用 Role； 如果你希望定义集群范围的角色，应该使用 ClusterRole。

.. note::

   关于Role和ClusterRole，我举个应用例子：

   - 如果你的应用要部署在不同集群，我们可以采用每个应用分配一个以应用名字为命名的名字空间，这样只要授权给对应应用的维护人员一个Role，就可以允许用户自己处理所有集群该应用的部署和使用。

   - 如果你想让用户自己维护集群，并且允许用户维护某个集群的跨名字空间作用域的资源，可以使用ClusterRole来配置，这样按照集群维度授权特别适合运维人员负责独立的集群。

   - 可以将Role视为横向扩展权限，ClusterRole视为纵向扩展权限

RoleBinding和ClusterRoleBinding
---------------------------------

角色绑定(Role Binding)是将角色定义的权限赋予一个或一组用户。它包含若干 ``主体`` (用户、组或者服务账户)的列表和对这些主体所获得的角色的引用。

RoleBinding在指定的名字空间中执行授权，而ClusterRoleBinding在集群范围内进行授权。

RoleBinding也可以引用ClusterRole，以将对应ClusterRole中定义的访问权限授予 RoleBinding所在名字空间的资源。这种引用使得你可以跨整个集群定义一组通用的角色，之后在多个名字空间中复用。

参考
=====

- `Kubernetes 文档/参考/访问 API/使用 RBAC 鉴权 <https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/>`_
