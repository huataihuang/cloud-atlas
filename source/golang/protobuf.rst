.. _protobuf:

============================
Protocol Buffers (Protobuf)
============================

Protocol Buffers (Protobuf) 是免费开源的跨平台数据格式，用于结构化数据的序列化和反序列化:

- Protocol Buffer的设计目标强调简单性和性能，特别设计成比XML更小、更快。Protocol Buffers 在 Google 被广泛用于存储和交换各种结构化信息。 该方法是自定义远程过程调用 (RPC) 系统的基础，几乎用于 Google 的所有机器间通信。
- Protocol Buffer 与 Apache Thrift、Ion 和 Microsoft Bond 协议类似。 提供一个具体的 RPC 协议栈以用于称为 gRPC 的定义服务。
- 数据结构模式（称为消息）和服务在 proto 定义文件 (.proto) 中描述并使用 protoc 进行编译。 此编译生成可由这些数据结构的发送者或接收者调用的代码。
- Protobuf 没有单一的规范。该格式最适合不超过几兆字节的小数据块，并且可以立即加载/发送到内存中，因此不是可流格式(streamable format)。
- Protobuf不仅是一种消息格式，还是一组定义和交换这些消息的规则和工具。Google开源了该协议，并提供了最为常用的编程语言生成代码的工具。例如，JavaScript、Java、PHP、C#、Ruby、Objective C、Python、C++ 和 Go。
- Protobuf比JSON拥有更多的数据类型，例如枚举和方法，并且也大量用于RPC(远程过程调用)

.. note::

   :ref:`kubernetes` 的apiserver提供了支持Protobuf通讯的模式，可以大幅度提高客户端和apiserver的效率，所以在大型Kuernetes集群常会看到这样的支持配置


参考
========

- `wikipedia: Protocol Buffers <https://en.wikipedia.org/wiki/Protocol_Buffers>`_
- `Beating JSON performance with Protobuf <https://auth0.com/blog/beating-json-performance-with-protobuf/>`_
