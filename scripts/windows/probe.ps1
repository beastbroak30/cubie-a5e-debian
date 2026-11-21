param([string]$Exe, [string[]]$PArgs)

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $Exe
$psi.Arguments = ($PArgs -join ' ')
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8"

$p = [System.Diagnostics.Process]::Start($psi)
$req = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}}'
$p.StandardInput.WriteLine($req)
$p.StandardInput.Flush()

$read = $p.StandardOutput.ReadLineAsync()
if ($read.Wait(45000)) {
  $line = $read.Result
  if ($line.Length -gt 900) { $line = $line.Substring(0, 900) }
  Write-Output "OK $Exe :: $line"
} else {
  Write-Output "TIMEOUT $Exe"
}
try { $p.Kill() } catch {}

