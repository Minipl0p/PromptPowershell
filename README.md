# Prompt PowerShell — Catppuccin Mocha

Un prompt PowerShell fait main, sans Oh My Posh ni Starship : un seul fichier, aucune dépendance.

![Aperçu du prompt](docs/apercu.png) <!-- capture d'écran à ajouter -->

```
~\projets\jeu   main ●   3,2s
❯
```

## Ce qu'il affiche

- Le dossier courant, raccourci avec `~` pour le dossier personnel.
- La branche git, et `●` s'il y a des modifications non commitées.
- La durée de la dernière commande si elle dépasse 2 secondes.
- Une flèche verte si la dernière commande a réussi, rouge sinon.
- ` admin` quand le terminal est lancé en administrateur.
- Coloration de la saisie et suggestions tirées de l'historique (PSReadLine), complétion `Tab` en menu.

Le prompt indique aussi le dossier courant au terminal (séquence OSC 9;9), ce qui permet à WezTerm ou Windows Terminal d'ouvrir un nouveau panneau dans le même dossier.

## Installation

PowerShell 7 est recommandé (`winget install Microsoft.PowerShell`), mais Windows PowerShell 5.1 fonctionne aussi. Une police Nerd Font est nécessaire pour l'icône de branche (par exemple `winget install DEVCOM.JetBrainsMonoNerdFont`).

```powershell
git clone <url-du-repo> $HOME\powershell-prompt
cd $HOME\powershell-prompt
pwsh -File .\install.ps1
```

Le script ajoute une seule ligne à ton profil (`$PROFILE`) qui charge `prompt.ps1`. Pour désinstaller, supprime cette ligne.

Si PowerShell refuse d'exécuter le script, autorise les scripts locaux une fois :

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## Réglages

En haut de `prompt.ps1` :

| Variable | Par défaut | Effet |
| --- | --- | --- |
| `$PromptGitDirty` | `$true` | Affiche `●` si le dépôt a des modifications. À couper sur les très gros dépôts si le prompt devient lent. |
| `$PromptMinDuration` | `2` | Durée minimale (secondes) pour afficher le temps de la dernière commande. |

Les couleurs sont dans le tableau `$C` (codes hexadécimaux de la palette Catppuccin Mocha).
