# set proxy config via profie.d - should apply for all users
# http/https/ftp/no_proxy
export http_proxy="http://192.168.6.200:3128/"
export https_proxy="http://192.168.6.200:3128/"
export ftp_proxy="http://192.168.6.200:3128/"
export no_proxy="127.0.0.1,localhost"

# For curl
export HTTP_PROXY="http://192.168.6.200:3128/"
export HTTPS_PROXY="http://192.168.6.200:3128/"
export FTP_PROXY="http://192.168.6.200:3128/"
export NO_PROXY="127.0.0.1,localhost"
