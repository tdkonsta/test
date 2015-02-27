#!/usr/bin/env python

import os 
import BaseHTTPServer
import SimpleHTTPServer
import CGIHTTPServer
import cgitb; cgitb.enable()  ## This line enables CGI error reporting
 

server = BaseHTTPServer.HTTPServer
handler = CGIHTTPServer.CGIHTTPRequestHandler
server_address = (os.environ['OPENSHIFT_COLLECTD_PRIVATE_HTTP_IP'],int(os.environ['OPENSHIFT_COLLECTD_PRIVATE_HTTP_PORT']))
handler.cgi_directories = ["","/cgi"]


 
httpd = server(server_address, handler)
httpd.serve_forever()
