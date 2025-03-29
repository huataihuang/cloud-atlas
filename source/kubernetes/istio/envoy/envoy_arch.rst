.. _envoy_arch:

================
Envoy架构
================

Envoy(信使)是一个7层代理服务器和为大型现代服务编排架构设计的通讯总线。最初目标是:

- 网络对于应用程序透明
- 当网络和应用出现问题可以迅速方便定位故障来源

在实践上，Envoy逐渐发展并尝试提供以下更高的功能:

- 进程无关架构(Out of process architecture): Envoy 是一个自包含进程，也就是设计成可以和所有应用服务器一起运行。

- L3/L4过滤架构(L3/L4 filter architecture):

- 7层HTTP过滤架构(HTTP L7 filter architecture)

- 最先支持HTTP/2

- 支持HTTP/3(alpha)

- 7层HTTP路由

- 支持gRPC

- 服务发现和动态配置

- 健康检查

- 高级负载均衡

- 支持 ``前端/边缘`` 代理

- 最佳的可观测性(Best in class observability)

参考
=======

- `Envoy Introduction <https://www.envoyproxy.io/docs/envoy/latest/intro/intro>`_
