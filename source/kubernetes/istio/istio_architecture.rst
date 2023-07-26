.. _istio_architecture:

============
Istio架构
============

Istio service mesh从逻辑上被划分为一个数据平面和一个控制平面:

- **数据平面** 是一组部署为智能代理(intelligent proxy) :ref:`envoy` 的sidecar。这些代理调解(mediate)和控制(control)所有的微服务(microservices)的网络通讯，也搜集(collect)和报告(report)所有网格(mesh)流量的遥测(telemetry)数据
- **控制平面** 负责管理和配置代理的路由流量

.. figure:: ../../_static/kubernetes/istio/istio_arch.svg

Istio组件
=========================

:ref:`envoy`
----------------

Istio使用了 :ref:`envoy` 代理的一个扩展版本:

- Envoy是一个C++开发的高性能代理，用于协调服务网格所有服务的入站和出站流量
- Envoy代理是Istio组件中唯一和数据平面流量交互的组件

Envoy代理是作为服务的 ``sidecar`` 部署的，通过Envoy的内置功能增强服务:

- 动态服务发现
- 负载均衡
- TLS termination
- HTTP/2 和 gRPC 代理
- 断路器(Circuit breakers)
- 健康检查
- 分阶段推出并根据百分比进行流量分配
- 故障注入(Fault injection)
- 丰富的指标(metrics)

通过sidecar部署可以使得 Istio 执行策略决策并提供丰富的遥测数据，能够提供给监控系统提供整个mesh网格的行为信息。

sidecar代理模型还提供了将Istio功能集成到现有部署，无需重新架构或重写代码。

Envoy代理提供的Istio功能举例:

- 流量控制功能: 通过丰富的HTTP, gRPC, WebSocket 和 TCP 流量路由股则实施细粒度的流量控制
- 网络弹性功能: 设置重试， 故障转移，断路器和故障注入
- 安全和身份验证功能: 强制执行安全策略并强制执行通过配置API定义的访问控制和速率控制
- 基于WebAssembly的可插拔扩展模型: 允许对网格流量执行自定义策略和遥测生成(telemetry generation for mesh traffic)

Istiod
----------

Istiod 提供服务发现、配置和证书管理:

- Istiod将控制流量的高级路由规则转换为特定Envoy的配置，并在运行时分发到sidecar
- Pilot抽象了特定于平台的服务发现机制，并将其组合成任何符合Envoy API的sidecar标准格式
- Istio可以支持多种环境(Kubernetes或VM)的发现

可以通过 Istio的流量管理API来设置Istiod优化Envoy配置，以便对service mesh的流量进行更为精细的控制。

Istio安全性是通过内置身份和凭证管理来实现服务到服务和最终用户身份雁阵，这样可日通过Istio升级service mesh中未加密的流量。

可以通过Istio的授权功能来控制服务访问，并且 Istiod 可以充当证书颁发机构(CA)并生成证书以允许数据平面的安全 mTLS 通信。

参考
=======

- `Istio Documentation > Operations > Deployment > Architecture <https://istio.io/latest/docs/ops/deployment/architecture/>`_
