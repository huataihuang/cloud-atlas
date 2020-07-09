.. _arbiter_volume_quorum:

==============================================
Gluster仲裁卷(arbiter volume)和投票(quorum)
==============================================

在GlusterFS分布式存储中， ``arbiter volume`` (仲裁卷) 是一个replica卷的特殊子集。冲裁卷是用来避免脑裂和提供和常规的3副本卷(replica 3 volume)相同的稳定性保证，但是却不需要消耗3倍的存储空间。

.. note::

   参考 :ref:`gluster_split_brain_deal`

参考
=======

- `Arbiter volumes and quorum options in gluster <https://gluster.readthedocs.io/en/latest/Administrator%20Guide/arbiter-volumes-and-quorum/>`_
