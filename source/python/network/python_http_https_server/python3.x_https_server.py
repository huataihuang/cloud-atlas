import http.server, ssl, socketserver

context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain("/Users/huataihuang/bin/cert.pem") # PUT YOUR cert.pem HERE
server_address = ("192.168.7.152", 4443) # CHANGE THIS IP & PORT
handler = http.server.SimpleHTTPRequestHandler
with socketserver.TCPServer(server_address, handler) as httpd:
    httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

httpd.serve_forever()
