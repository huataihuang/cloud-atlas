# pip install huggingface_hub hf_transfer
# import os # Optional for faster downloading
# os.environ["HF_HUB_ENABLE_HF_TRANSFER"] = "1"

from huggingface_hub import snapshot_download
snapshot_download(
  repo_id = "unsloth/DeepSeek-R1-GGUF",
  local_dir = "DeepSeek-R1-GGUF",
  #allow_patterns = ["*UD-IQ1_S*"], # Select quant type UD-IQ1_S for 1.58bit
  allow_patterns = ["*-R1-Q8_0"], # Select quant type R1-Q8_9 for 8bit
)
