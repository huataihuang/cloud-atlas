.. _k8s_custom_resources:

=======================================
Kubernetes 定制资源(Custom Resource)
=======================================

- 定制资源(Custom Resource)是Kubernetes API 的扩展:

  - 资源(Resource) 是 Kubernetes API 的端点 (endpoint)，其中存储的是某个类别的 **API对象** 的一个集合。例如，内置的 ``Pod`` 资源包含一组Pod对象
  - 定制资源(Custom Resource)是对Kubernetes API 的扩展，代表对特定Kubernetes安装的一种 **定制** ，这使得 Kubernetes 更加模块化

定制资源可以通过动态注册(dynamic registration)的方式在运行的集群中出现或消失。一旦某个定制资源被安装，用户就可以使用 ``kubectl`` 来创建和访问其中的对象，就像使用 pod 这种内置资源一样。

- **定制控制器** (Custom controllers): 

  - 当定制资源与定制控制器结合时，定制资源就能够提供真正的 **声明式API** ( ``Declarative API`` )
  - 在一个运行的集群上部署和更新定制控制器，则这类操作于集群的生命周期无关

``声明式API`` vs ``命令式API``
================================

- 声明式API:

  - API包含数量不多且尺寸较小的对象(资源)
  - 对象定义了应用或基础设施的配置信息
  - 对象更新操作频率较低
  - 通常需要人来读取和写入对象
  - 对象操作主要是CRUD风格的(增删改查)
  - 不需要跨对象的事物操作: API 对象代表的是期望状态而非确切实际状态

- 命令式API:

  - 客户端发出指令后，指令操作结束时需要获得 **同步响应**
  - 客户端发出指令，并获得一个操作ID，需要查询一个操作(operation)对象来判断是否成功完成
  - API类似于远程过程调用（RPC, Remote Procedure Call)
  - 需要存储大量数据: 例如每个对象几KB，或者存储上千个对象
  - 需要较高的访问带宽: 长时间保持每秒数十个请求
  - 存储最终用户数据(如图片，个人标识信息等)或者其他大规模数据
  - 在对象上执行的常规操作并非CRUD风格
  - API不容易用对象来建模
  - 决定使用操作ID或操作对象来表示pending操作

``ConfigMap`` vs ``定制资源``
=================================

- 如果满足以下 **条件之一** 应该使用 ``ConfigMap`` :

  - 存在一个已有的、文档完备的配置文件格式约定，例如 :ref:`mysql_config` 或 ``pom.xml``
  - 希望将整个配置文件放到某个 configMap 中的一个主键下面
  - 配置文件的主要用途是针对运行在集群中Pod内的程序(你可以理解成传统意义上的服务运行配置文件，通过映射进容器)
  - 配置文件的使用者(也就是容器内的服务程序)希望通过Pod内文件或Pod内环境变量方式来使用配置，而不是通过 Kubernetes API (这是一种非常直观的方式，静态配置，在pod生命周期内不能动态修改)
  - 当需要更新配置文件的时候，需要通过类似 Deployment 之类的资源完成滚动更新(如上，也就是即使修改ConfigMap配置文件也需要完成一次发布，Pod会重建)

- 如果以下条件中 **大多数** 都被满足，则应该使用定制资源(CRD或聚合API):

  - 希望使用Kubernetes客户端库和CLI来创建和更新资源
  - 希望 ``kubectl`` 能够直接支持资源，例如 ``kubectl get my-object object-name``
  - 希望构建新的自动化机制，监测新对象上的更新实践，并对其他对象执行CRUD操作，或者监测后者更新前者
  - 希望编写自动化组件来处理对对象的更新
  - 希望使用Kubernetes API对诸如 ``.spec`` , ``.status`` 和 ``.metadata`` 等字段的约定
  - 希望对象是一组受控资源的抽象，或者对其资源的归纳提炼

.. note::

   这里的一些定义和条件比较抽象，不过你在Kubernetees实践中，用以上条款对比应该能够逐步体会到深意

添加定制资源
===============

Kubernetes 提供了两种方式添加定制资源:

- CRD: 无需编程，相对简单
- API聚合: 需要编程，但支持对API进行更多控制，例如数据如何存储以及在不同的API版本之间如何转换

.. note::

   聚合API指运行在主API服务器后面: 主API服务器实际上是代理服务器(API Aggregation, AA)。其实很简单，就类似于 :ref:`nginx_reverse_proxy` ，也就是当访问某个API URL时，会反向代理到后端实际提供服务的聚合API服务器。此时，对于客户端而言，只看到访问单一的API服务器。

CRD不需要添加新的API服务器，不需要理解API聚合。

.. note::

   要避免将定制资源作为数据存储: 这会导致过于紧密耦合

   避免工作负载需要依赖某个组件运行:

   也就是说控制面和数据面要分离，即使Kubernetes管控组件全部挂掉，最多也就影响pod创建、销毁这种workload变化操作，但是不会影响已经交付的workload工作(例如pod继续在工作节点运行)。这种松散耦合对于现代化大规模集群非常重要的能力。

CustomResourceDefinitions
===========================

:ref:`k8s_crd` 用于自定义资源。定义CRD对象可以使用自己设置的名字和模式定义(schema)创建一个新的定制资源。Kubernetes API负责为定制资源提供存储和访问服务。 **CRD对象的名称必须是合法的DNS子域名**

CRD不需要编程来实现API Server就能够处理定制资源，但是通用性和灵活性不如 **API聚合**

参考
=========

- `Kubernetes Custom Resources <https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/>`_ 中文文档: `Kubernetes 文档 >> 概念 >> 扩展 Kubernetes >> 扩展 Kubernetes API >> 定制资源 <https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/api-extension/custom-resources/>`_
