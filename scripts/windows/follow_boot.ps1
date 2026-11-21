$log = 'C:\Users\akant\AppData\Local\Temp\opencode\serial.log'
$posFile = 'C:\Users\akant\AppData\Local\Temp\opencode\serial.pos'
$pos = 0
if (Test-Path $posFile) { $pos = [int64](Get-Content $posFile -Raw) }
if (-not (Test-Path $log)) { Write-Host "waiting for capture start..."; exit }

$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.Elapsed.TotalSeconds -lt 40) {
    $len = (Get-Item $log).Length
    if ($len -gt $pos) {
        $fs = [System.IO.File]::Open($log, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $fs.Seek($pos, 'Begin') | Out-Null
        $count = [int]($len - $pos)
        $buf = New-Object byte[] $count
        $read = $fs.Read($buf, 0, $count)
        $fs.Dispose()
        $pos += $read
        $text = [System.Text.Encoding]::UTF8.GetString($buf, 0, $read)
        Write-Host $text -NoNewline
        Set-Content -Path $posFile -Value $pos -NoNewline
    }
    Start-Sleep -Milliseconds 500
}
