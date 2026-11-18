#!/usr/bin/env python3
"""
ops_check.py — 本地校验配置 → SSH 远程采集 → 本地解析 → 写结构化日志

依赖:
    pip install paramiko pyyaml
"""

import json
import logging
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path
from typing import Optional

import paramiko
import yaml

# ═══════════════════════════════════════════════════════════════
#  日志配置（本地写文件）
# ═══════════════════════════════════════════════════════════════
LOG_DIR = Path("logs")
LOG_DIR.mkdir(exist_ok=True)
LOG_FILE = LOG_DIR / f"check_{datetime.now():%Y%m%d}.jsonl"

# 日志文件: JSON Lines 格式
file_handler = logging.FileHandler(LOG_FILE, encoding="utf-8")
file_handler.setFormatter(logging.Formatter("%(message)s"))

# 控制台日志
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setFormatter(
    logging.Formatter("%(asctime)s [%(levelname)s] %(message)s", datefmt="%H:%M:%S")
)
logger = logging.getLogger("ops_check")
logger.setLevel(logging.DEBUG)
logger.addHandler(file_handler)
logger.addHandler(console_handler)


def log_json(level: int, event: dict):
    """写一条 JSON 结构化日志到文件，同时在控制台输出摘要"""
    event["timestamp"] = datetime.now().isoformat()
    logger.log(level, json.dumps(event, ensure_ascii=False))


# ═══════════════════════════════════════════════════════════════
#  数据结构
# ═══════════════════════════════════════════════════════════════
@dataclass
class ServerMetrics:
    host: str
    name: str
    reachable: bool = False
    disk_percent: Optional[int] = None
    mem_percent: Optional[int] = None
    load_1m: Optional[float] = None
    cpu_cores: int = 0
    services: dict = field(default_factory=dict)  # {"nginx": True, ...}
    alerts: list = field(default_factory=list)
    error: str = ""


# ═══════════════════════════════════════════════════════════════
#  第一步：本地 subprocess 校验
# ═══════════════════════════════════════════════════════════════
def local_precheck(config_path: str) -> dict:
    """
    使用 subprocess 在本地做前置检查:
      - 用 python -c 验证 YAML 语法
      - 用 which 确认 ssh 二进制存在（paramiko 虽不依赖，但做环境自检）
      - 确认私钥文件存在且权限正确
    返回解析后的 config dict。
    """
    logger.info("-- 本地前置检查 --")
    # 用 subprocess 调 python 验证 YAML 合法性
    check_cmd = [
        sys.executable,
        "-c",
        f"import yaml,sys; yaml.safe_load(open('{config_path}')); print('OK')",
    ]
    result = subprocess.run(check_cmd, capture_output=True, text=True, timeout=10)
    if result.returncode != 0:
        log_json(
            logging.ERROR,
            {
                "event": "preecheck_failed",
                "stage": "yaml_syntax",
                "detail": result.stderr.strip(),
            },
        )
        sys.ext(1)
    logger.info("  ✓ YAML 语法合法")
    # 检查 ssh 二进制（环境自检，非必须）
    which_result = subprocess.run(["which", "ssh"], capture_output=True, text=True)
    if which_result.returncode == 0:
        logger.info("  ✓ ssh 可用: %s", which_result.stdout.strip())
    else:
        logger.warning("  ⚠ 未找到 ssh 二进制（paramiko 不受影响）")

    # 检查私钥文件
    key_file = os.path.expanduser(config["ssh"]["key_file"])
    key_result = subprocess.run(
        ["stat", "-c", "%a", key_file], capture_output=True, text=True
    )
    if key_result.returncode != 0:
        log_json(
            logging.ERROR,
            {
                "event": "precheck_failed",
                "stage": "key_file",
                "detail": f"私钥文件不存在: {key_file}",
            },
        )
        sys.exit(1)

    perms = key_result.stdout.strip()
    if int(perms) & 0o077:
        logger.warning("  ⚠ 私钥权限过宽 (%s)，建议 chmod 600", perms)
    else:
        logger.info("  ✓ 私钥文件就绪: %s (perms=%s)", key_file, perms)

    logger.info("── 本地前置检查通过 ──")
    return config


# ═══════════════════════════════════════════════════════════════
#  第二步：SSH 远程执行命令
# ═══════════════════════════════════════════════════════════════
def ssh_exec(
    client: paramiko.SSHClient, command: str, timeout: int = 15
) -> tuple[str, str, int]:
    """在已连接的 SSH 客户端上执行命令，返回 (stdout, stderr, exit_code)"""
    try:
        _, stdout, stderr = client.exec_command(command, timeout=timeout)
        out = stdout.read().decode("utf-8", errors="replace")
        err = stderr.read().decode("utf-8", errors="replace")
        code = stdout.channel.recv_exit_status()
        return out.strip(), err.strip(), code
    except Exception as e:
        return "", str(e), -1


def collect_from_server(
    host: str,
    name: str,
    ssh_cfg: dict,
    cmd_templates: dict,
    services: list[str],
) -> ServerMetrics:
    """连接一台服务器，执行所有采集命令，返回原始指标"""
    metrics = ServerMetrics(host=host, name=name)

    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        # 建立连接
        client.connect(
            hostname=host,
            port=ssh_cfg.get("port", 22),
            username=ssh_cfg["user"],
            key_filename=os.path.expanduser(ssh_cfg["key_file"]),
            timeout=ssh_cfg.get("timeout", 10),
            allow_agent=False,
            look_for_keys=False,
        )
        metrics.reachable = True

        # --- 磁盘 (根分区) ---
        out, err, code = ssh_exec(client, cmd_templates["disk"].format(mount="/"))
        if code == 0:
            # 输出示例: /dev/sda1  102564544  73846520  28718024  72%  /
            fields = out.split()
            metrics.disk_percent = int(fields[4].rstrip("%"))

        # --- 内存 ---
        out, err, code = ssh_exec(client, cmd_template["mem"])
        if code == 0:
            # 输出示例: 12345678 32109876  (used_kb total_kb)
            parts = out.split()
            if len(parts) >= 2:
                used, total = int(parts[0]), int(parts[1])
                metrics.mem_percent = round(used / total * 100) if total else 0

        # --- 负载 ---
        out, err, code = ssh_exec(client, cmd_templates["load"])
        if code == 0:
            # /proc/loadavg: 0.52 0.48 0.45 1/234 56789
            metrics.load_1m = float(out.split()[0])

        # --- CPU 核数 ---
        out, err, code = ssh_exec(client, cmd_templates["cpu_cores"])
        if code == 0:
            metrics.cpu_cores = int(out)

        # --- 服务状态 ---
        for svc in services:
            out, err, code = ssh_exec(
                client, cmd_templates["service"].format(service=svc), timeout=10
            )
            metrics.services[svc] = out == "active" and code == 0

    except paramiko.SSHException as e:
        metrics.error = f"SSH: {e}"
    except Exception as e:
        metrics.error = str(e)
    finally:
        client.close()

    return metrics


# ═══════════════════════════════════════════════════════════════
#  第三步：本地解析 & 告警判断
# ═══════════════════════════════════════════════════════════════
def evaluate(metrics: ServerMetrics, thresholds: dict) -> list[str]:
    """根据阈值判断是否触发告警，返回告警列表"""
    alerts = []

    if (
        metrics.disk_percent is not None
        and metrics.disk_percent >= thresholds["disk_percent"]
    ):
        alerts.append(
            f"磁盘使用率 {metrics.disk_percent}% >= 阈值 {thresholds['disk_percent']}%"
        )

    if (
        metrics.mem_percent is not None
        and metrics.mem_percent >= thresholds["mem_percent"]
    ):
        alerts.append(
            f"内存使用率 {metrics.mem_percent}% >= 阀值 {thresholds['mem_percent']}"
        )

    if metrics.load_1m is not None and metrics.cpu_cores > 0:
        load_per_core = metrics.load_1m / metrics.cpu_cores
        if load_per_core >= thresholds["load_per_core"]:
            alerts.append(
                f"负载 {metrics.load_1m} (每核 {load_per_core:.2f}) "
                f">= 阈值 {thresholds['load_per_core']}"
            )

    for svc, active in metrics.services.items():
        if not active:
            alerts.append(f"服务 {svc} 未运行")

    return alerts


# ═══════════════════════════════════════════════════════════════
#  第四步：写结构化日志
# ═══════════════════════════════════════════════════════════════
def write_report(metrics: ServerMetrics):
    """将单台服务器结果写入 JSON Lines 日志"""
    level = logging.WARNING if metrics.alerts else logging.INFO
    log_json(level, {"event": "server_check", **asdict(metrics)})

    # 控制台友好输出
    icon = "🔴" if metrics.alerts else "🟢"
    print(
        f"  {icon} {metrics.name:<16} "
        f"disk={metrics.disk_percent or '-':>3}%  "
        f"mem={metrics.mem_percent or '-':>3}%  "
        f"load={metrics.load_1m or '-':>5}  "
        f"svc={metrics.services}"
    )
    for a in metrics.alerts:
        print(f"       ⚠ {a}")


# ═══════════════════════════════════════════════════════════════
#  主流程
# ═══════════════════════════════════════════════════════════════
def main():
    config_path = sys.argv[1] if len(sys.argv) > 1 else "config.yaml"

    # ── 本地: subprocess 前置检查 ──
    config = local_precheck(config_path)

    ssh_cfg = config["ssh"]
    thresholds = config["thresholds"]
    cmd_templates = config["commands"]
    services = config.get("services", [])
    servers = config["servers"]

    print(f"\n目标服务器: {len(servers)} 台\n")

    # ── 远程: paramiko SSH 采集 ──
    results: list[ServerMetrics] = []
    for srv in servers:
        print(f"  → 连接 {srv['host']} ({srv['name']}) ...")
        m = collect_from_server(
            host=srv["host"],
            name=srv["name"],
            ssh_cfg=ssh_cfg,
            cmd_templates=cmd_templates,
            services=services,
        )
        results.append(m)

    # ── 本地: 解析 + 告警 + 写日志 ──
    print(f"\n{'=' * 50}")
    print(f"  检查结果  {datetime.now():%Y-%m-%d %H:%M:%S}")
    print(f"{'=' * 50}\n")

    total_alerts = 0
    for m in results:
        if not m.reachable:
            m.alerts.append(f"无法连接: {m.error}")
        else:
            m.alerts = evaluate(m, thresholds)
        total_alerts += len(m.alerts)
        write_report(m)

    # 汇总日志
    log_json(
        logging.INFO,
        {
            "event": "summary",
            "total_servers": len(results),
            "unreachable": sum(1 for m in results if not m.reachable),
            "total_alerts": total_alerts,
            "alert_hosts": [m.host for m in results if m.alerts],
        },
    )

    print(f"\n  汇总: {len(results)} 台, 告警 {total_alerts} 条")
    print(f"  日志: {LOG_FILE.resolve()}\n")

    # 退出码：有告警返回 1（方便 cron / CI 集成）
    sys.exit(1 if total_alerts > 0 else 0)


if __name__ == "__main__":
    main()

