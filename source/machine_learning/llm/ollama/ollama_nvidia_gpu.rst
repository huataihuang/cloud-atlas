.. _ollama_nvidia_gpu:

=================================
Ollama使用NVIDIA GPU运行大模型
=================================

安装
========

- 安装 ``ollama`` 执行程序:

.. literalinclude:: install_ollama/install_manual
   :caption: 手工本地安装

- 安装CUDA驱动( :ref:`gpu_passthrough_in_qemu_install_nvidia_cuda` )

.. literalinclude:: ../../../kvm/qemu/gpu_passthrough_in_qemu_install_nvidia_cuda/cuda_toolkit_debian_repo
   :caption: 在 :ref:`debian` 12操作系统添加NVIDIA官方软件仓库配

配置
=======

当完成 :ref:`ollama_run_deepseek` 后，我发现默认情况下 ``Ollama`` 是使用CPU进行推理的:

- CPU跑满了一个core，但是 ``nvidia-smi`` 显示GPU "纹丝不动"

简单参考 `ollama/docs/gpu.md <https://github.com/ollama/ollama/blob/main/docs/gpu.md>`_ 就可以看到 ``Ollama`` 是通过环境变量 ``CUDA_VISIBLE_DEVICES`` 来使用 :ref:`nvidia_gpu` 的，也就是说需要给 ``ollama`` 服务进程传递这个环境变量。

由于 :ref:`ollama_run_deepseek` 使用了 :ref:`systemd` 来运行 ``ollama`` 服务，所以需要配置 :ref:`systemd_env` 

- 找出GPU的id，对于 :ref:`nvidia_gpu` 使用 ``nvidia-smi`` 命令:

.. literalinclude:: ollama_gpu/nvidia-smi
   :caption: 通过 ``nvidia-smi`` 命令获取GPU的id

输出显示:

.. literalinclude:: ollama_gpu/nvidia-smi_output
   :caption: 通过 ``nvidia-smi`` 命令获取GPU的id

- 修订 ``/etc/systemd/system/ollama.service`` 添加环境变量:

.. literalinclude:: ollama_gpu/ollama.service
   :caption: ``/etc/systemd/system/ollama.service`` 设置 ``ollama`` 服务运行环境变量
   :emphasize-lines: 13

- 重新加载 ``ollama.service`` 配置以及重启服务:

.. literalinclude:: ollama_gpu/restart_ollama.service
   :caption: 重启 ``ollama`` 服务

- 现在再次使用ollama进行推理的时候，就会看到GPU满负荷运行，证明已经将推理由GPU完成(不过 ``ollama`` 的CPU也是满负荷，有点吃惊)

.. literalinclude:: ollama_gpu/nvidia-smi_run_output
   :caption: 指定GPU之后运行 ``ollama`` 推理就可以看到 ``nvidia-smi`` 输出显示GPU满负荷工作
   :emphasize-lines: 12,21

参考
=======

- `ollama/docs/gpu.md <https://github.com/ollama/ollama/blob/main/docs/gpu.md>`_
