# ╭──────────────────────────────────────────────────────────╮
# │  Prompt PowerShell — Catppuccin Mocha, fait main          │
# │  Aucun outil externe (pas d'Oh My Posh, pas de Starship). │
# │  Chargé depuis le profil PowerShell ($PROFILE).           │
# ╰──────────────────────────────────────────────────────────╯
# Rendu :
#   ~\projets\jeu   main ●   3,2s
#   ❯

# ── Réglages ─────────────────────────────────────────────────
# Vérifier si le dépôt git a des modifications (●). Peut être lent sur
# d'énormes dépôts : mettre à $false pour l'ignorer.
$global:PromptGitDirty = $true
# Durée minimale (secondes) pour afficher le temps de la dernière commande.
$global:PromptMinDuration = 2

# ── Couleurs (Catppuccin Mocha) ──────────────────────────────
function global:_Rgb([string]$hex) {
    $r = [Convert]::ToInt32($hex.Substring(1, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(3, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(5, 2), 16)
    return "$([char]27)[38;2;${r};${g};${b}m"
}
$global:C = @{
    Dir   = _Rgb '#89b4fa'
    Git   = _Rgb '#cba6f7'
    Dirty = _Rgb '#f9e2af'
    Ok    = _Rgb '#a6e3a1'
    Err   = _Rgb '#f38ba8'
    Dim   = _Rgb '#6c7086'
    Admin = _Rgb '#fab387'
    Reset = "$([char]27)[0m"
}

# ── Informations git (branche + état) ────────────────────────
function global:_GitInfo {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return "" }
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if (-not $branch) { return "" }
    if ($branch -eq "HEAD") { $branch = (git rev-parse --short HEAD 2>$null) }
    $out = " $($C.Git) $branch$($C.Reset)"
    if ($global:PromptGitDirty) {
        $status = git status --porcelain --untracked-files=no 2>$null
        if ($status) { $out += " $($C.Dirty)●$($C.Reset)" }
    }
    return $out
}

# ── Chemin raccourci (~ pour le dossier personnel) ───────────
function global:_ShortPath {
    $path = $PWD.ProviderPath
    if ($path.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase)) {
        $path = "~" + $path.Substring($HOME.Length)
    }
    return $path
}

$global:_IsAdmin = $false
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $global:_IsAdmin = (New-Object Security.Principal.WindowsPrincipal $id).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ── Le prompt ────────────────────────────────────────────────
function global:prompt {
    $ok = $?
    $line = ""
    if ($global:_IsAdmin) { $line += "$($C.Admin) admin$($C.Reset) " }
    $line += "$($C.Dir)$(_ShortPath)$($C.Reset)"
    $line += _GitInfo

    $last = Get-History -Count 1
    if ($last) {
        $sec = ($last.EndExecutionTime - $last.StartExecutionTime).TotalSeconds
        if ($sec -ge $global:PromptMinDuration) {
            $line += " $($C.Dim)$('{0:N1}s' -f $sec)$($C.Reset)"
        }
    }

    $arrow = if ($ok) { $C.Ok } else { $C.Err }
    # Indique le dossier courant au terminal (nouvel onglet/split dans le même dossier).
    $esc = [char]27
    $osc = "$esc]9;9;`"$($PWD.ProviderPath)`"$esc\"
    return "$osc`n$line`n$arrow❯$($C.Reset) "
}

# ── Saisie : couleurs et prédictions (PSReadLine) ────────────
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    $psrl = @{
        Colors = @{
            Command          = '#89b4fa'
            Parameter        = '#f5c2e7'
            String           = '#a6e3a1'
            Variable         = '#f5e0dc'
            Number           = '#fab387'
            Operator         = '#94e2d5'
            Comment          = '#6c7086'
            Keyword          = '#cba6f7'
            Type             = '#f9e2af'
            InlinePrediction = '#585b70'
        }
    }
    try {
        Set-PSReadLineOption @psrl
        Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -ErrorAction Stop
    } catch {
        # Anciennes versions de PSReadLine : pas de prédictions, ce n'est pas grave.
    }
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}
