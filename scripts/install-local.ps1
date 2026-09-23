<#
.SYNOPSIS
  Copies the addon folders from this repo into the WoW AddOns folder (for testing local changes).
.PARAMETER AddOnsPath
  Path to Interface\AddOns. Defaults to the retail install used on this machine.
#>
param(
  [string]$AddOnsPath = "C:\Games\Battle.net\Games\World of Warcraft\_retail_\Interface\AddOns"
)
$repo = Split-Path -Parent $PSScriptRoot
foreach ($name in "TipTac", "TipTacOptions") {
  # /MIR makes the installed folder an exact mirror (removes files deleted from the repo); only touches these two folders.
  robocopy (Join-Path $repo $name) (Join-Path $AddOnsPath $name) /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "robocopy failed for $name (exit $LASTEXITCODE)" }
  Write-Host "installed $name"
}
Write-Host "Done. In game: /reload"
