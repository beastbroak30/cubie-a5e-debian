param([string]$Exe, [string]$PArg)

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $Exe
$psi.Arguments = $PArg
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8"

$p = [System.Diagnostics.Process]::Start($psi)
$body = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}}'
$p.StandardInput.Write("Content-Length: $($body.Length)`r`n`r`n$body")
$p.StandardInput.Flush()

$out = ""
$deadline = (Get-Date).AddSeconds(45)
while ((Get-Date) -lt $deadline) {
  if ($p.StandardOutput.Peek() -ge 0) {
    $ch = [char]$p.StandardOutput.Read()
    $out += $ch
    if ($out.Length -gt 1200) { break }
  } else {
    Start-Sleep -Milliseconds 100
    if ($p.HasExited) { break }
  }
}
Write-Output "LEN=$($out.Length)"
Write-Output $out
try { $p.Kill() } catch {}
