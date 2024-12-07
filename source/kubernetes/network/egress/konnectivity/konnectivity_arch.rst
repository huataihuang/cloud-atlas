.. _konnectivity_arch:

========================
Konnectivity 架构
========================

企业级部署场景:

- 管控平面(Control plane)和工作平面(Worker节点)之间部署了防火墙，以保护和控制重要的数据资产，在这个场景下， ``Konnetivity`` 通过Server / Agents 架构提供了加密隧道贯通防火墙(只需要开通8132端口允许Konnectivity Server访问Agent)

参考
======

- `keps/sig-api-machinery/1281-network-proxy <https://github.com/kubernetes/enhancements/tree/master/keps/sig-api-machinery/1281-network-proxy>`_ K8s SIG小组讨论解释了Kube API Server引入扩展网络 traffic egress 或 network proxy系统的原理
- `kubernetes-sigs/apiserver-network-proxy <https://github.com/kubernetes-sigs/apiserver-network-proxy>`_
- `Improving Kubernetes Security with the Konnectivity Proxy <https://www.youtube.com/watch?v=wTRezbXnlj8>`_
- `Remote Control Planes With Konnectivity; What, Why And How? <https://www.youtube.com/watch?v=0yltsB3Cbr4>`_
