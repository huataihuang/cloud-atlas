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

使用GPU
=========

发现一个问题，虽然我的主机安装了24GB显存的 :ref:`tesla_p10` ，但是 ``Ollama`` 却用CPU完成推理，在 ``nvidia-smi`` 完全看不到GPU在工作。我可是特意选择了能够用20GB运行的 ``32b`` 参数大模型。


参考
======

- `Ollama Library > deepseek-r1 <https://ollama.com/library/deepseek-r1>`_
