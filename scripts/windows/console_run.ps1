$ErrorActionPreference = 'Continue'
$port     = 'COM5'
$cmdFile  = 'C:\Users\akant\AppData\Local\Temp\opencode\console_cmds.txt'
$logFile  = 'C:\Users\akant\AppData\Local\Temp\opencode\console_run.log'
$sentinel = '__DONE__'

$sp = New-Object System.IO.Ports.SerialPort($port, 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$sp.DtrEnable = $true
$sp.RtsEnable = $true
$sp.ReadTimeout = 300
$sp.WriteTimeout = 2000
$sp.NewLine = "`r"

function Read-Until([string]$marker, [int]$timeoutSec) {
    $sb = New-Object System.Text.StringBuilder
    $deadline = (Get-Date).AddSeconds($timeoutSec)
    while ((Get-Date) -lt $deadline) {
        try {
            $chunk = $sp.ReadExisting()
        } catch { $chunk = '' }
        if ($chunk.Length -gt 0) {
            [void]$sb.Append($chunk)
            if ($sb.ToString().Contains($marker)) { break }
        } else {
            Start-Sleep -Milliseconds 120
        }
    }
    return $sb.ToString()
}

$log = New-Object System.Text.StringBuilder
function Say([string]$s) { Write-Host $s; [void]$log.AppendLine($s) }

$sp.Open()
Say ("[open] " + $port)
Write-Host ('--- drain: ' + $sp.ReadExisting())

# login
Say '[login] sending user'
$sp.Write("radxa`r")
$r = Read-Until 'assword' 10
Say $r
Say '[login] sending password'
$sp.Write("radxa`r")
$r = Read-Until '~$' 15
Say $r

$cmds = Get-Content $cmdFile | Where-Object { $_.Trim().Length -gt 0 }
foreach ($c in $cmds) {
    $line = $c.Trim()
    Say ("`n>>> " + $line)
    $sp.Write($line + "; echo $sentinel`r")
    $out = Read-Until $sentinel 120
    Say $out
}

$sp.Close()
[System.IO.File]::WriteAllText($logFile, $log.ToString())
Say '[done]'
