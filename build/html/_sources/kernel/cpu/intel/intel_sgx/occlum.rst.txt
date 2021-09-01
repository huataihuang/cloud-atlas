.. _occlum:

=================
Occlum LibOS
=================

Occlum (英文意为 ``阻塞`` ) 是蚂蚁金服开源的基于 :ref:`intel_sgx_arch` 开发的 ``可信执行环境`` (Trusted Execution Environments, TEE) LibOS。开源官方网站是 `occlum.io <https://occlum.io/>`_ ， `GitHub项目occlum <https://github.com/occlum/occlum>`_ 。

.. note::

   我初步浏览Occlum技术，感觉是基于Intel SGX打包的容器镜像，实现在容器中即成Intel SGX driver，实现一个快速开发Intel SGX的应用，方便实现 开发、镜像化、部署 完整的持续集成。

   具体分析待继续

参考
========

- `人人都可以“机密计算”：Occlum 使用入门和技术揭秘 <https://www.sofastack.tech/blog/sofa-channel-18-retrospect/>`_