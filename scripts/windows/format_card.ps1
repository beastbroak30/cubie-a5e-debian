$ErrorActionPreference = "Stop"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Not elevated. Relaunching with UAC prompt..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath
    exit 0
}

$log = "C:\Users\akant\AppData\Local\Temp\opencode\format_card.log"
try { Start-Transcript -Path $log -Force | Out-Null } catch {}

$diskNo = 2
$disk = Get-Disk -Number $diskNo
Write-Host "=== FORMAT START $(Get-Date -Format o) ==="
$disk | Select-Object Number,FriendlyName,Size,PartitionStyle,IsReadOnly,IsOffline | Format-List

# ---- safety guard: must be the 128 GB card reader ----
if ($disk.FriendlyName -notlike '*xD/SD/M.S.*') {
    Write-Host "ABORT: disk $diskNo is '$($disk.FriendlyName)', not the card reader." -ForegroundColor Red
    Stop-Transcript | Out-Null; Read-Host "Enter to close"; exit 1
}
if ($disk.Size -lt 100GB -or $disk.Size -gt 200GB) {
    Write-Host "ABORT: disk $diskNo size $($disk.Size) is not the 128 GB card." -ForegroundColor Red
    Stop-Transcript | Out-Null; Read-Host "Enter to close"; exit 1
}
Write-Host "Guard passed: card reader, ~$([math]::Round($disk.Size/1GB)) GB" -ForegroundColor Green

try { Set-Disk -Number $diskNo -IsReadOnly $false -ErrorAction SilentlyContinue } catch {}
try { Set-Disk -Number $diskNo -IsOffline $false  -ErrorAction SilentlyContinue } catch {}

Write-Host "Clearing partitions..."
Clear-Disk -Number $diskNo -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4
Update-Disk -Number $diskNo -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "Creating single partition, full size..."
$part = $null
for ($i = 0; $i -lt 6; $i++) {
    try {
        $disk = Get-Disk -Number $diskNo
        if ($disk.IsOffline) { Set-Disk -Number $diskNo -IsOffline $false }
        $part = New-Partition -DiskNumber $diskNo -UseMaximumSize -AssignDriveLetter
        break
    } catch {
        Write-Host "New-Partition attempt $($i+1) failed: $_"
        Start-Sleep -Seconds 5
        Update-Disk -Number $diskNo -ErrorAction SilentlyContinue
    }
}
if (-not $part) { Write-Host "ABORT: could not create partition." -ForegroundColor Red; Stop-Transcript | Out-Null; Read-Host "Enter to close"; exit 1 }

Write-Host "Partition created: $($part.DriveLetter): offset=$($part.Offset) size=$($part.Size)"

Start-Sleep -Seconds 3
$letter = $part.DriveLetter
for ($i = 0; $i -lt 6; $i++) {
    try {
        Format-Volume -DriveLetter $letter -FileSystem exFAT -NewFileSystemLabel "RADXA" -Confirm:$false -Force | Out-Null
        Write-Host "Format OK" -ForegroundColor Green
        break
    } catch {
        Write-Host "Format attempt $($i+1) failed: $_"
        Start-Sleep -Seconds 5
    }
}

Write-Host "=== RESULT ==="
Get-Disk -Number $diskNo | Select-Object Number,FriendlyName,Size,PartitionStyle | Format-List
Get-Partition -DiskNumber $diskNo | Select-Object PartitionNumber,DriveLetter,Offset,Size,Type | Format-Table -AutoSize
Get-Volume -DriveLetter $letter | Select-Object DriveLetter,FileSystemLabel,FileSystem,Size,SizeRemaining | Format-List

Write-Host "=== FORMAT DONE $(Get-Date -Format o) ==="
Stop-Transcript | Out-Null
Write-Host ""
Read-Host "Press Enter to close"
