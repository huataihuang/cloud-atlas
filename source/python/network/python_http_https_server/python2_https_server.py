import BaseHTTPServer, SimpleHTTPServer
import ssl

httpd = BaseHTTPServer.HTTPServer(('localhost', 4443),
        SimpleHTTPServer.SimpleHTTPRequestHandler)

httpd.socket = ssl.wrap_socket (httpd.socket,
        keyfile="/Users/huataihuang/bin/key.pem",
        certfile='/Users/huataihuang/bin/cert.pem', server_side=True)

httpd.serve_forever()
