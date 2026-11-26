<#
.SYNOPSIS
  Lance l'application Chantier en local : base SQL Server + API + back-office web (+ mobile en option).
.DESCRIPTION
  Raccourci vers scripts/dev.ps1 (la logique reste la-bas).
  Sans option : base + API + web, puis ouvre le navigateur sur http://localhost:3600.
  -Mobile  lance aussi Flutter (emulateur ou telephone) apres l'API.
  -Phone   avec -Mobile : telephone reel branche en USB.
  -Stop    arrete web, API et base (les donnees sont conservees).
  -Status  affiche l'etat sans rien demarrer.
  -NoBrowser  n'ouvre pas le navigateur.
  Prerequis : Docker Desktop demarre, .NET SDK, Node.js, et Flutter pour -Mobile.
  Comptes de demonstration : admin.dev, conducteur.dev, chef.dev, equipe.dev (mot de passe :
  chantier-backend/WebApi/Chantier.WebApi/appsettings.Development.json).
.EXAMPLE
  .\run.ps1
.EXAMPLE
  .\run.ps1 -Mobile -Phone
.EXAMPLE
  .\run.ps1 -Stop
#>
[CmdletBinding()]
param(
    [switch]$Mobile,
    [switch]$Phone,
    [switch]$Stop,
    [switch]$Status,
    [switch]$NoBrowser
)

$ErrorActionPreference = 'Stop'
$dev = Join-Path $PSScriptRoot 'scripts\dev.ps1'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker est introuvable : installe et demarre Docker Desktop."
}

if ($Stop)   { & $dev -Down;   return }
if ($Status) { & $dev -Status; return }

& $dev -All

Write-Host ''
Write-Host 'Web  : http://localhost:3600'
Write-Host 'API  : http://localhost:8195'
Write-Host 'Comptes : admin.dev, conducteur.dev, chef.dev, equipe.dev'
Write-Host 'Arreter : .\run.ps1 -Stop'

if (-not $NoBrowser) { Start-Process 'http://localhost:3600' }

if ($Mobile) {
    # Au premier plan : Ctrl+C pour quitter Flutter (web et API restent actifs).
    if ($Phone) { & $dev -Mobile -Phone } else { & $dev -Mobile }
}
