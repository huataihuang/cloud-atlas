.. _podman_compose_ollama_nvidia_a2:

==========================================
Podman compose组合运行Ollama(NVIDIA A2)
==========================================

之前在 :ref:`ollama_nvidia_a2_gpu_docker` 通过多个Docker容器运行来实现 :ref:`tesla_a2` 支持Ollama以及对应的 :ref:`ollama_webui` 以及 :ref:`grafana` / :ref:`prometheus` 组合。

现在我再参考 :ref:`docker_compose_ollama` 的部署来重新通过 :ref:`podman` 优化上述组合，以便能够使用统一的一条命令运行容器组合，并维护容器。

准备工作
=============

- 物理主机已经完成 :ref:`ubuntu_podman`

- 物理主机已经完成 :ref:`nvidia_container_toolkit`

Podman compose
=================


