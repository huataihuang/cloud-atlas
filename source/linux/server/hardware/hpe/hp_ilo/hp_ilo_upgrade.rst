.. _hp_ilo_upgrade:

=======================
HP iLO升级
=======================

我在 :ref:`hp_ilo_startup` 实践中，尝试更新过 :ref:`hpe_dl360_gen9` 的iLO版本，现在服务器更换成 :ref:`hpe_dl380_gen9` ，也需要更新最新的 iLO 以便获得更为稳定的系统监控和管理。

DL360 和 DL380 的 gen9 代服务器的iLO实际上是相同的，可以采用相同的 iLO 更新包更新，在 `HPE Supprt Cent <https://support.hpe.com/>`_ 搜索 ``iLO 4`` : 可以看到最新版本 2023-03-02 发布的 iLO 2.82

- `Online ROM Flash Component for Linux - HPE Integrated Lights-Out 4 <https://support.hpe.com/connect/s/softwaredetails?language=en_US&collectionId=MTX-d8701885e8a84180&tab=revisionHistory>`_ 提供了rpm 和 ``.scexe`` 格式文件，其中 ``.scexe`` 可以直接执行提取出 ``.bin`` 文件，即iLO二进制文件，可直接通过iLO web上传升级:

.. literalinclude:: hp_ilo_upgrade/scexe
   :caption: 从 ``.scexe`` 问价值那种提取出 ``.bin`` 文件


