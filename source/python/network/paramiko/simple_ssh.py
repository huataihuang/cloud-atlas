import paramiko

client = paramiko.SSHClient()

client.set_missing_host_key_policy(paramiko.AutoAddPolicy)

try:
    client.connect(
            hostname="192.168.6.200",
            port=22,
            username="admin",
            password="PASSWORD"
            )

    stdin, stdout, stderr = client.exec_command("df -h")

    output = stdout.read().decode("utf-8")
    errors = stderr.read().decode("utf-8")

    if output:
        print("Output:\n", output)
    if errors:
        print("Errors:\n", errors)

finally:
    client.close()
