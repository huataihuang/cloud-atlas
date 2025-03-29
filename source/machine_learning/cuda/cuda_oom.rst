.. _cuda_oom:

====================================
``CUDA out of memory`` 排查和优化
====================================

在做大模型训练时，即使调度到 :ref:`nvidia_a100` 这样的超强硬件也是有显存限制的(80GB)，超大模型单卡依然会出现 ``CUDA out of memory`` ::

   torch.cuda.OutOfMemoryError: CUDA out of memory. Tried to allocate 80.00 MiB (GPU 0; 79.35 GiB total capacity; 76.70 GiB already allocated; 37.19 MiB free; 77.79 GiB reserved in total by PyTorch) If reserved memory is >> allocated memory try setting max_split_size_mb to avoid fragmentation.  See documentation for Memory Management and PYTORCH_CUDA_ALLOC_CONF
   main process return code: 1

GPT的答复
==========

先问问GPT 3.5给出的答案，至少有一个大致方向:

- 减小batch size。可以通过减小batch size来降低GPU内存的占用。
- 减小模型的复杂度。如果模型比较大，可以尝试减小模型的深度或宽度，来降低GPU内存的占用。
- 使用更多的GPU。如果有多个GPU可以使用，可以尝试在多个GPU上并行运行模型，从而减少每个GPU的内存占用。
- 使用FP16数据类型。使用FP16数据类型可以减少GPU内存的占用。
- 调整PyTorch的内存分配策略。可以通过设置max_split_size_mb参数来避免内存碎片，从而减少内存占用。

参考方案(待验证)
==================

参考 `Solving the “RuntimeError: CUDA Out of memory” error <https://medium.com/@snk.nitin/how-to-solve-cuda-out-of-memory-error-850bb247cfb2>`_ 执行以下步骤

- ``pip3`` 执行安装模块:

.. literalinclude:: cuda_oom/pip_install_gputil_torch
   :language: bash
   :caption: pip安装gputil和torch

- 检查内存使用:

.. literalinclude:: cuda_oom/gpu_usage.py
   :language: python
   :caption: 获取GPU使用率

输出显示:

.. literalinclude:: cuda_oom/gpu_usage_output
   :caption: 获取GPU使用率输出显示

- 使用以下代码清理缓存:

.. literalinclude:: cuda_oom/empty_cache.py
   :language: python
   :caption: 清理CUDA缓存

.. literalinclude:: cuda_oom/empty_cache_1.py
   :language: python
   :caption: 清理CUDA缓存(另一种方法)

.. literalinclude:: cuda_oom/empty_cache_2.py
   :language: python
   :caption: 清理CUDA缓存(另一种方法)

完整的代码可以参考如下:

.. literalinclude:: cuda_oom/empty_cache_full.py
   :language: python
   :caption: 清理CUDA缓存完整代码参考

.. note::

   缓存清理方法可能不能适应持续运行的任务，有些任务可能就是需要使用大量缓存，清理也可能带来效率下降或者依然会不断加载缓存

降低batch大小
=================

另一种比较简单的方法是尝试降低 ``batch size`` ，也就是运行参数 ``--bs X --eval_bs Y``

举例，将运行命令::

   CUDA_VISIBLE_DEVICES=0 python main.py \
       --model allenai/unifiedqa-t5-base \
       --user_msg rationale --img_type detr \
       --bs 8 --eval_bs 4 --eval_acc 10 --output_len 512 \
       --final_eval --prompt_format QCM-LE

参数 ``--bs 8 --eval_bs 4`` 可以尝试修改成更低的值   

降低精度
===================

如果在使用 Pytorch-Lighting ，可以尝试将精度改为 ``float16`` 。这样可能会带来预期的双精度和Float tensor之间不匹配，但是这个设置能够提升内存效率并且性能上有非常小的折衷，所以是一种可行的选择。

待实践...

多GPU
==========

在多GPU系统中，可以使用 ``CUDA_VISIBLE_DEVICES`` 环境变量来选择使用的GPU:

.. literalinclude:: cuda_oom/cuda_visible_env
   :language: bash
   :caption: 设置 ``CUDA_VISIBLE_DEVICES`` 环境变量可以决定使用的GPU设备

也可以在 :ref:`python` 代码中设置:

.. literalinclude:: cuda_oom/cuda_visible.py
   :language: bash
   :caption: Python代码中设置 ``CUDA_VISIBLE_DEVICES`` 环境变量可以决定使用的GPU设备


参考
=======

- `Solving the “RuntimeError: CUDA Out of memory” error <https://medium.com/@snk.nitin/how-to-solve-cuda-out-of-memory-error-850bb247cfb2>`_ 比较详细的解析
- `torch.cuda.OutOfMemoryError: CUDA out of memory. #19 <https://github.com/amazon-science/mm-cot/issues/19>`_ 降低batch参数方法
- `How to fix this strange error: "RuntimeError: CUDA error: out of memory" <https://stackoverflow.com/questions/54374935/how-to-fix-this-strange-error-runtimeerror-cuda-error-out-of-memory>`_ 可以尝试release cache
- `Solving "CUDA out of memory" Error <https://www.kaggle.com/getting-started/140636>`_
- `PyTorch FREQUENTLY ASKED QUESTIONS <https://pytorch.org/docs/stable/notes/faq.html>`_ 官方FAQ解释
