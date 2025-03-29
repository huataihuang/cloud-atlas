.. _think_best_practices_for_gluster:

===============================
Gluster存储最佳实践的思考
===============================

最近 :ref:`deploy_centos7_suse15_suse12_gluster11` 沿用了我之前的部署方案，但是在 :ref:`add_centos7_gluster11_server` 突然触发我意识到直接使用裸盘的利弊，特别是阅读了 `Gluster Storage for Oracle Linux: Best Practices and Sizing Guideline <https://www.oracle.com/a/ocom/docs/linux/gluster-storage-linux-best-practices.pdf>`_ 之后，我觉得需要进一步梳理方案，对比和分析以总结 :ref:`best_practices_for_gluster` ，实现技术上的迭代进步。

参考
=====

- `Gluster Storage for Oracle Linux: Best Practices and Sizing Guideline <https://www.oracle.com/a/ocom/docs/linux/gluster-storage-linux-best-practices.pdf>`_ Oracle Linux提供的这个最佳实践撰写得比较清晰
