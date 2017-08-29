import os
import sys
import base64
import urllib2
import urlparse
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

rc4_key = ""

class RC4:

	def __init__(self, plaintext, key):
		self.output = ""
		key = [ord(c) for c in key]
		S = self.KSA(key)
		keystream = self.PRGA(S)
		for c in plaintext:
			self.output = self.output + chr(ord(c) ^ keystream.next())
		
	def KSA(self, key):
		keylength = len(key)
		S = range(256)
		j = 0
		for i in range(256):
			j = (j + S[i] + key[i % keylength]) % 256
			S[i], S[j] = S[j], S[i]

		return S

	def PRGA(self, S):
		i = 0
		j = 0
		while True:
			i = (i + 1) % 256
			j = (j + S[i]) % 256
			S[i], S[j] = S[j], S[i] 

			K = S[(S[i] + S[j]) % 256]
			yield K
			
	def get_data(self):
		return self.output
		
class ProxyRequest(BaseHTTPRequestHandler):

	def set_http_headers(self):
		self.send_response(200)
		self.send_header('Content-type', 'text/html')
		self.end_headers()
		
	def do_GET(self):
		path = ""
		try:
			path = self.path.split('?', 1)[1]
		except:
			pass
			
		rc4 = RC4(base64.b64decode(path), rc4_key)
		path = rc4.get_data()
		print "Fetching %s" % path
		request = urllib2.Request(path)
		
		buffer = ""
		try:
			buffer = urllib2.urlopen(request).read()
		except:
			pass
		
		rc4 = None
		rc4 = RC4(buffer, rc4_key)
		
		self.set_http_headers()
		self.wfile.write("%s" % rc4.get_data())

def run(server_class=HTTPServer, handler_class=ProxyRequest, ip="", port=80):
	server_address = (ip, port)
	proxy = server_class(server_address, handler_class)
	print 'Starting URL proxy on port %d' % port
	proxy.serve_forever()
		
if __name__ == "__main__":
	
	if len(sys.argv) < 3:
		print "Usage: %s ip port key" % sys.argv[0]
		exit(0)

	rc4_key = sys.argv[3]
	run(ip=sys.argv[1], port=int(sys.argv[2]))
