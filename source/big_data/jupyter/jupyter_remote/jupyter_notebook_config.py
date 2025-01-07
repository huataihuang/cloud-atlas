## Set the Access-Control-Allow-Origin header
#  
#          Use '*' to allow any origin to access your server.
#
#          Takes precedence over allow_origin_pat.
#  Default: ''
# c.ServerApp.allow_origin = ''
c.ServerApp.allow_origin = '*'

## The IP address the Jupyter server will listen on.
#  Default: 'localhost'
# c.ServerApp.ip = 'localhost'
c.ServerApp.ip = '0.0.0.0'
