.. _intro_kcp:

===========================
KCP低延迟安全网络堆栈简介
===========================

KCP官网介绍
==============

KCP是一个快速可靠协议，能以比 TCP浪费10%-20%的带宽的代价，换取平均延迟降低 30%-40%，且最大延迟降低三倍的传输效果。纯算法实现，并不负责底层协议（如UDP）的收发，需要使用者自己定义下层数据包的发送方式，以 callback的方式提供给 KCP。 连时钟都需要外部传递进来，内部不会有任何一次系统调用。

整个协议只有 ikcp.h, ikcp.c两个源文件，可以方便的集成到用户自己的协议栈中。也许你实现了一个P2P，或者某个基于 UDP的协议，而缺乏一套完善的ARQ可靠协议实现，那么简单的拷贝这两个文件到现有项目中，稍微编写两行代码，即可使用。

.. note::

   待学习和了解，可能在 :ref:`live_streaming` 中会有特定场景加速效果

.. note::

   参考 Quora 上 `How is KCP doing awesome on performance compared to TCP? <https://www.quora.com/How-is-KCP-doing-awesome-on-performance-compared-to-TCP>`_ 对KCP是否性能比TCP更优有以下观点可以参考:

   - 在无损网络上，KCP 和 TCP 在性能上基本相当； 一旦建立连接，同一底层网络上的连接延迟基本上是相同的，并且 TCP 实际上在数据量方面比 KCP 实现了更好的整体吞吐量，因为 TCP 避免在链路上发送任何潜在的冗余信息。
   - 在有损链路上，KCP 比 TCP 更好地从单个丢失的数据包中恢复，因为它不会像 TCP 那样将窗口一直切到一半。 然而，当当前拥塞窗口内有多个随机间隔的丢失数据包必须重传时，KCP 会损失更多的吞吐量，因为 KCP 仅从接收方向发送方发送 2 个参数； 连续序列中最近成功片段的片段号，以及接收到的最高非连续片段的序列号。 发送方无法知道 ``sn_nxt`` 和 ``sn`` 之间有多少片段 **也** 已经丢失，随后也需要重新传输。
   - KCP 很好地解决了一个特定问题，对于fast-twitch的游戏玩家来说，它可以很好地解决该特定问题。 但它并没有在所有不同类型的底层网络和所有不同类型的数据丢失下都表现得"出色"； 如果目标是批量数据传输，则 KCP 的开销损失确保它在通过链接发送最大数据量的能力方面始终落后于 TCP。

参考
======

- `KCP - A Fast and Reliable ARQ Protocol <https://github.com/skywind3000/kcp>`_ 
- `Introducing KCP: a new low-latency, secure network stack <https://ims.improbable.io/insights/kcp-a-new-low-latency-secure-network-stack>`_
