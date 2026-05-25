param(
    [Parameter(Mandatory=$true)]
    [string]$State
)
$file = "$env:USERPROFILE\.claude\status.json"
$dir = Split-Path $file -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$data = @{ state = $State; timestamp = [int64]((Get-Date).ToUniversalTime() - (Get-Date "1970-01-01")).TotalSeconds }
$data | ConvertTo-Json -Compress | Set-Content $file -Encoding UTF8
