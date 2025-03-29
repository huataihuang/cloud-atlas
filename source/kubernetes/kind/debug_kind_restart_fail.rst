.. _debug_kind_restart_fail:

========================
排查kind重启失败
========================

.. note::

   惭愧，由于时间紧张，我暂时没有精力继续排查，所以对于测试集群 ``dev`` 采用了粗暴删除然后重建的方式::

      kind delete cluster --name dev
      kind create cluster --name dev --config kind-config.yaml --image kindest/node:v1.25.3-arm64

   不过，参考 `Cluster doesn't restart when docker restarts #148 <https://github.com/kubernetes-sigs/kind/issues/148>`_ 重启后失败很可能和docker动态分配IP地址导致kind集群的节点IP地址变化导致的。最新kind版本应该是修复的:

   - `When after restart docker, kind cluster could't connect #1685 <https://github.com/kubernetes-sigs/kind/issues/1685>`_
   - `Fix multi-node cluster not working after restarting docker #2671 <https://github.com/kubernetes-sigs/kind/pull/2671>`_

   如果kind版本如果不能解决，可以考虑从docker方向着手，分配给节点固定IP地址: **已经有人使用脚本方法让docker分配固定IP地址来解决这个问题** :  `seguidor777/kind_static_ips.sh <https://gist.github.com/seguidor777/5cda274ea9e1083bfb9b989d17c241e8>`_ 针对 `multi-node: Kubernetes cluster does not start after Docker re-assigns node's IP addresses after (Docker) restart #2045 <https://github.com/kubernetes-sigs/kind/issues/2045>`_ ，也提到 kind 0.15.0 将解决多管控节点重启后无法访问的问题
   这也促使我考虑如何确保测试集群的备份和恢复，以及快速重建。虽然目前是刚刚搭建集群，没有任何数据，但是随着业务的推进，即使是测试集群也需要确保稳定性和数据可靠性。

我在 :ref:`mobile_cloud` 架构下，也就是采用 :ref:`asahi_linux` 运行 ``kind`` 模拟集群，但是，重启了笔记本操作系统之后，发现 ``kind`` 没有正常运行:

- ``docker`` 服务启动时自动启动了 ``kind`` ，但是 ``dev-external-load-balancer`` 没有启动
- 我尝试 ``docker start dev-external-load-balancer`` 启动容器，但是依然无法使用 ``kubectl get nodes`` (长时间没有响应)

在 :ref:`kind_multi_node` 安装的集群 ``kind-dev`` 可以从 ``~/.kube/config`` 获得访问配置信息::

   apiVersion: v1
   clusters:
   - cluster:
       certificate-authority-data: ...
       server: https://127.0.0.1:44963
     name: kind-dev
   ...

在 ``docker start dev-external-load-balancer`` 之后可以看到启动的负载均衡 ``haproxy`` 反向代理到apiserver::

   CONTAINER ID   IMAGE                                COMMAND                  CREATED      STATUS        PORTS                       NAMES
   22b5211339aa   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   5 days ago   Up 12 hours   127.0.0.1:40075->6443/tcp   dev-control-plane
   619b562dc7bb   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   5 days ago   Up 12 hours   127.0.0.1:45187->6443/tcp   dev-control-plane3
   2d40652bf4f4   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   5 days ago   Up 12 hours   127.0.0.1:35769->6443/tcp   dev-control-plane2
   ...
   2c84abeb9eeb   kindest/haproxy:v20220607-9a4d8d2a   "haproxy -sf 7 -W -d…"   5 days ago   Up 12 hours   127.0.0.1:44963->6443/tcp   dev-external-load-balancer
   ...

我尝试类似 :ref:`debug_kind_create_fail` 一样采用::

   docker exec -it dev-external-load-balancer /bin/bash

但是这个node的容器镜像没有包含 ``/bin/bash`` 或 ``/bin/sh`` 

排查apiserver
===================

- 登陆到管控节点检查::

   docker ecex -it dev-control-plane /bin/bash

检查日志::

   cd /var/log/containers
   tail -f kube-apiserver-dev-control-plane_kube-system_kube-apiserver-*

- 发现 ``etcd`` 端口访问被拒绝::

   2022-11-21T02:37:42.33512655Z stderr F }. Err: connection error: desc = "transport: Error while dialing dial tcp 127.0.0.1:2379: connect: connection refused"
   2022-11-21T02:37:42.581760776Z stderr F W1121 02:37:42.581626       1 logging.go:59] [core] [Channel #4 SubChannel #6] grpc: addrConn.createTransport failed to connect to {
   2022-11-21T02:37:42.581808901Z stderr F   "Addr": "127.0.0.1:2379",
   2022-11-21T02:37:42.581843735Z stderr F   "ServerName": "127.0.0.1",
   2022-11-21T02:37:42.581857652Z stderr F   "Attributes": null,
   2022-11-21T02:37:42.581870318Z stderr F   "BalancerAttributes": null,
   2022-11-21T02:37:42.581883235Z stderr F   "Type": 0,
   2022-11-21T02:37:42.58189511Z stderr F   "Metadata": null
   2022-11-21T02:37:42.581909235Z stderr F }. Err: connection error: desc = "transport: Error while dialing dial tcp 127.0.0.1:2379: connect: connection refused"
   2022-11-21T02:37:45.120168047Z stderr F E1121 02:37:45.120069       1 run.go:74] "command failed" err="context deadline exceeded"

- 检查 ``etcd`` 日志::

   2022-11-21T02:50:52.546140586Z stderr F {"level":"warn","ts":"2022-11-21T02:50:52.546Z","caller":"etcdserver/server.go:2063","msg":"failed to publish local member to cluster through raft","local-member-id":"ac5a143a5c9bfc26","local-member-attributes":"{Name:dev-control-plane ClientURLs:[https://172.18.0.5:2379]}","request-path":"/0/members/ac5a143a5c9bfc26/attributes","publish-timeout":"7s","error":"etcdserver: request timed out"}
   2022-11-21T02:50:53.90545154Z stderr F {"level":"info","ts":"2022-11-21T02:50:53.905Z","logger":"raft","caller":"etcdserver/zap_raft.go:77","msg":"ac5a143a5c9bfc26 is starting a new election at term 5"}
   2022-11-21T02:50:53.905552332Z stderr F {"level":"info","ts":"2022-11-21T02:50:53.905Z","logger":"raft","caller":"etcdserver/zap_raft.go:77","msg":"ac5a143a5c9bfc26 became pre-candidate at term 5"}
   2022-11-21T02:50:53.905583207Z stderr F {"level":"info","ts":"2022-11-21T02:50:53.905Z","logger":"raft","caller":"etcdserver/zap_raft.go:77","msg":"ac5a143a5c9bfc26 received MsgPreVoteResp from ac5a143a5c9bfc26 at term 5"}
   2022-11-21T02:50:53.905610624Z stderr F {"level":"info","ts":"2022-11-21T02:50:53.905Z","logger":"raft","caller":"etcdserver/zap_raft.go:77","msg":"ac5a143a5c9bfc26 [logterm: 5, index: 907545] sent MsgPreVote request to 139a0544ee9f6038 at term 5"}
   2022-11-21T02:50:53.905664082Z stderr F {"level":"info","ts":"2022-11-21T02:50:53.905Z","logger":"raft","caller":"etcdserver/zap_raft.go:77","msg":"ac5a143a5c9bfc26 [logterm: 5, index: 907545] sent MsgPreVote request to af9abd7ce32e9fb0 at term 5"}
   2022-11-21T02:50:54.547259349Z stderr F {"level":"warn","ts":"2022-11-21T02:50:54.547Z","caller":"rafthttp/probing_status.go:68","msg":"prober detected unhealthy status","round-tripper-name":"ROUND_TRIPPER_SNAPSHOT","remote-peer-id":"139a0544ee9f6038","rtt":"0s","error":"dial tcp 172.18.0.8:2380: connect: connection refused"}
   2022-11-21T02:50:54.547321057Z stderr F {"level":"warn","ts":"2022-11-21T02:50:54.547Z","caller":"rafthttp/probing_status.go:68","msg":"prober detected unhealthy status","round-tripper-name":"ROUND_TRIPPER_RAFT_MESSAGE","remote-peer-id":"139a0544ee9f6038","rtt":"0s","error":"dial tcp 172.18.0.8:2380: connect: connection refused"}
   2022-11-21T02:50:54.552412074Z stderr F {"level":"warn","ts":"2022-11-21T02:50:54.552Z","caller":"rafthttp/probing_status.go:68","msg":"prober detected unhealthy status","round-tripper-name":"ROUND_TRIPPER_SNAPSHOT","remote-peer-id":"af9abd7ce32e9fb0","rtt":"0s","error":"dial tcp 172.18.0.4:2380: connect: connection refused"}
   2022-11-21T02:50:54.552458491Z stderr F {"level":"warn","ts":"2022-11-21T02:50:54.552Z","caller":"rafthttp/probing_status.go:68","msg":"prober detected unhealthy status","round-tripper-name":"ROUND_TRIPPER_RAFT_MESSAGE","remote-peer-id":"af9abd7ce32e9fb0","rtt":"0s","error":"dial tcp 172.18.0.4:2380: connect: connection refused"}
   2022-11-21T02:50:55.054307958Z stderr F {"level":"warn","ts":"2022-11-21T02:50:55.054Z","caller":"etcdhttp/metrics.go:173","msg":"serving /health false; no leader"}
   2022-11-21T02:50:55.054357666Z stderr F {"level":"warn","ts":"2022-11-21T02:50:55.054Z","caller":"etcdhttp/metrics.go:86","msg":"/health error","output":"{\"health\":\"false\",\"reason\":\"RAFT NO LEADER\"}","status-code":503}

可以看到 ``etcd`` 在 Raft publish时候出现超时
