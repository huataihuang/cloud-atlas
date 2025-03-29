.. _xfs_tunning:

===============
XFS性能优化
===============

在 :ref:`lvm_xfs_in_studio` 初步实现了模拟环境的XFS文件系统构建，实际上在生产环境中，需要根据底层硬件(RAID)以及其他系统因素对XFS进行性能调优和测试。

目前我还没有环境和条件进行相关测试，仅汇总相关资料，有待后续实践：

- `Recommended XFS settings for MarkLogic Server <https://help.marklogic.com/Knowledgebase/Article/View/505/0/recommended-xfs-settings-for-marklogic-server>`_
- `Tips and Recommendations for Storage Server Tuning <https://www.beegfs.io/wiki/StorageServerTuning>`_
- `How to calculate the correct sunit,swidth values for optimal performance <http://xfs.org/index.php/XFS_FAQ#Q:_How_to_calculate_the_correct_sunit.2Cswidth_values_for_optimal_performance>`_
