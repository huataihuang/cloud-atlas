.. _systemd_env:

=================
Systemd环境变量
=================

当需要向systemd传递环境变量参数时，例如，我在 :ref:`ollama_gpu` 实践中，需要向 ``ollama`` 服务进程传递环境变量:

.. literalinclude:: ../../../machine_learning/llm/ollama/ollama_gpu/ollama.service
   :caption: ``/etc/systemd/system/ollama.service`` 设置 ``ollama`` 服务运行环境变量
   :emphasize-lines: 12-13

上述配置 ``/etc/systemd/system/ollama.service`` 我增加了两个环境变量，分别用来指定大模型文件存储位置以及运行时将推理计算在 :ref:`nvidia_gpu` 上运行

参考
======

- `How to set environment variable in systemd service? <https://serverfault.com/questions/413397/how-to-set-environment-variable-in-systemd-service>`_
