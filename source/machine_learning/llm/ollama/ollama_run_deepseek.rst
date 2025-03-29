.. _ollama_run_deepseek:

===========================
使用Ollama运行DeepSeek R1
===========================

Ollama官方提供了极为简便的运行大模型方法，例如运行DeepSeek-R1模型，则在 `Ollama Library > deepseek-r1 <https://ollama.com/library/deepseek-r1>`_ 使用页面提供的导引找到运行命令。在完成了 :ref:`install_ollama` 之后，就可以选择适合你主机环境的模型版本:

- 主要根据主机的GPU显存或者内存来确定要下载的模型参数
- 如果主机没有GPU，则自动切换在CPU上运行(速度大减)

由于我的主机使用了 :ref:`tesla_p10` ，具备24G显存，所以我这里案例是使用 ``32b`` 规格模型:

.. literalinclude:: ollama_run_deepseek/32b
   :caption: 运行32b的DeepSeek-R1

``Ollama`` 会自动下载大模型文件并运行等待访问:

.. literalinclude:: ollama_run_deepseek/32b_output
   :caption: 运行32b的DeepSeek-R1自动下载模型并启动

思考过程有模有样，推导出的脚本是可行的(使用通配符 ``*`` ):

.. literalinclude:: ollama_run_deepseek/compare_str.sh
   :caption: deepseek给出的比较字符串包含的bash脚本

而且给出了详细的解释，看来 ``32b`` 的版本比之前测试的 ``7b`` 参数好了很多，至少给出了正确的编码结果( ``7b`` 是错误的)

.. note::

   如果没有指定 :ref:`ollama_nvidia_gpu` ，那么ollama可能完全是CPU模式运行的，所以如果主机已经安装了 :ref:`nvidia_gpu` 或 :ref:`amd_gpu` ，那么需要调整配置实现 :ref:`ollama_nvidia_gpu` 或 :ref:`ollama_amd_gpu`

.. _open-webui:

open-webui
============

.. note::

   ``open-webui`` 通过 ``pip`` 安装会依赖很多软件，不过我发现类似的 ``LibreChat`` ( `Install LibreChat Locally <https://www.librechat.ai/docs/local>`_ )更为复杂，手工安装还需要部署非常沉重的依赖，如 `MeiliSearch <https://github.com/meilisearch/meilisearch>`_ 。这种复杂的软件堆栈看起来是为了一种商业模式而建，对于个人使用非常不友好。

   对于桌面应用，看起来 `chatbox <https://github.com/Bin-Huang/chatbox>`_ 社区版本已经非常合适。不过，我可能还需要继续寻找合适的轻量级WEB UI。

`GitHub: open-webui/open-webui <https://github.com/open-webui/open-webui>`_ 是一个非常易于使用的AI交互界面，支持多种API，例如 Ollama 或者 OpenAI兼容 API。这是一个 :ref:`python` 程序，所以通过 :ref:`virtualenv` 以及 ``pip`` 非常容易安装运行:

.. literalinclude:: ollama_run_deepseek/install_open-webui
   :caption: 安装 open-webui( :ref:`virtualenv` )

- 运行 ``open-webui`` :

.. literalinclude:: ollama_run_deepseek/run_open-webui
   :caption: 运行 open-webui( :ref:`virtualenv` )

.. note::

   ``open-webui`` 只支持 ``OpenAI`` 和 ``Ollama`` 两种API，所以如果直接部署 :ref:`deploy_deepseek-r1_locally_cpu_arch` 使用 ``llama.cpp`` ，则无法直接使用 ``open-webui`` 。解决方法目前看有3种:

   - 通过 ``Ollama`` 来运行 ``llama.cpp`` 模型，但是怎么解决自定义运行需要找到方法
   - `GitHub: mpazdzioch/llamacpp-webui-glue <https://github.com/mpazdzioch/llamacpp-webui-glue>`_ ( `Llamacpp + WebUI with automatic model switching <https://www.reddit.com/r/LocalLLaMA/comments/1eb1sq0/llamacpp_webui_with_automatic_model_switching/>`_ ) 采用了一种巧妙的方法，在 ``open-webui`` 和 ``llama.cpp`` 之间部署 :ref:`openresty` ，通过 ``openresty`` 的内置 :ref:`lua` 定制一个OpenAI API转换层，来直接调用 ``llama.cpp`` 的API接口。值得学习借鉴
   - ``llama.cpp`` 项目提供了一个 ``llama-server`` ，能够使用 ``OpenAI`` 兼容API方式提供调用，也就是说，完全可以去除 ``ollama`` 直接对接 ``open-webui`` ，不过现在可能还没有很好的文档指导。我在 :ref:`deploy_deepseek-r1_locally_cpu_arch` 中目前使用 ``llama-server`` 来提供服务，具体对接 ``OpenAI`` 兼容API的方法待实践

使用GPU
=========

发现一个问题，虽然我的主机安装了24GB显存的 :ref:`tesla_p10` ，但是 ``Ollama`` 却用CPU完成推理，在 ``nvidia-smi`` 完全看不到GPU在工作。我可是特意选择了能够用20GB运行的 ``32b`` 参数大模型。

解决方法是 :ref:`ollama_nvidia_gpu`

参考
======

- `Ollama Library > deepseek-r1 <https://ollama.com/library/deepseek-r1>`_
