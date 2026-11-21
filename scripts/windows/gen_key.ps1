$ErrorActionPreference = 'Stop'
$keyPath = 'C:\Users\akant\.ssh\cubie_a5e'
if (-not (Test-Path $keyPath)) {
    & ssh-keygen -t ed25519 -N '""' -C 'cubie-a5e' -f $keyPath | Out-Null
}
Get-Content ($keyPath + '.pub')
