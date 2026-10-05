# Installe le prompt : ajoute une ligne au profil PowerShell qui charge prompt.ps1.
# Usage : depuis le dossier du repo,  pwsh -File .\install.ps1
$ErrorActionPreference = "Stop"
$promptFile = Join-Path $PSScriptRoot "prompt.ps1"
$line = ". `"$promptFile`""

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
$content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($content -and $content.Contains($promptFile)) {
    Write-Host "Le prompt est déjà chargé par $PROFILE"
} else {
    Add-Content -Path $PROFILE -Value "`n# Prompt Catppuccin`n$line"
    Write-Host "Ajouté à $PROFILE. Ouvre un nouveau terminal pour voir le prompt."
}
