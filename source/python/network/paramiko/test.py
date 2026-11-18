python3 -c "
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(5)
try:
    s.connect(('192.168.6.200', 22))
    print('TCP 连接成功')
    s.close()
except Exception as e:
    print(f'TCP 连接失败: {e!r}')
"
