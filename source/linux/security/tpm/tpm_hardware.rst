.. _tpm_hardware:

====================================
Trusted Platform Module(TPM)硬件
====================================

实际上PC主板上很早就已经集成了TPM芯片，但是很长时间并没有实际得到主流欢迎，原因是很少有软件使用TPM。不过，现在TPM越来越受到关注，原因是Windows和Linux都开始支持和使用TPM(应该也是因为苹果公司T1/T2安全芯片带来的市场竞争)。

.. note::

   我在构建 :ref:`private_cloud` 采用二手 :ref:`hpe_dl360_gen9` ，服务器需要安装一个 ``HP Trusted Platform Module 2.0 Kit 745823-B21`` 模块才能提供TPM支持。这个模块需要到ebay上从美国卖家这里购买，价格大约是300元。从部件手册看还有一个 ``HP Trusted Platform Module Option 488069-B21`` 不知道差异。

TPM功能和原理
==============

早期的PC设计中没有考虑到安全，所以今年来工程上正在逐步改进这个初始设计错误，也就是尝试结合PC硬件来解决安全问题，并组建了 ``可信计算工作组`` (Trusted Computing Group, TCC)，目前正在持续该机TPM设计，TPM相关信息可以从 `TGC官网 <https://trustedcomputinggroup.org/>`_ 获取。

TPM(Truted Platform Module, 可信平台模块)是一个安全加密处理器部件，允许我们通过集成的加密密钥来增强安全性的硬件。通常是一个28 pin芯片

参考
=========

- `Hardware: TPM module <https://paolozaino.wordpress.com/2018/06/15/tpm-module/>`_
