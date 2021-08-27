.. _intro_tpm:

===========================================
Trusted Platform Module(TPM)技术简介
===========================================

Trusted Platform Module(TPM)是 可信计算工作组(Trust Computing Group, TCG) 设计的 ``OS不可知`` (OS agnostic) 的一系列规范:

- 规范设计了一个 `Secure cryptoprocessor <https://en.wikipedia.org/wiki/Secure_cryptoprocessor>`_ （安全隐蔽处理器) 从硬件或者软件上实现
- 这个隐蔽处理器的功能是加密一个平台(硬件或者软件，如软件是通过VM)来使用加密密钥和加密操作

通过TPM芯片提供以下功能:

- 加密哈希函素( `Cryptographic hash functions <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_ )
- 支持数据加密(同步或异步)，主要是在硬件上实现TPM
- 


参考
==========

- `Linux: What can I do with a Trusted Platform Module (TPM)? <https://paolozaino.wordpress.com/2021/06/27/linux-what-can-i-do-with-a-trusted-platform-module-tpm/>`_