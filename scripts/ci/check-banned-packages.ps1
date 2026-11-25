<#
.SYNOPSIS
  D1 : echoue si un paquet interdit sans ADR apparait dans les manifestes du depot.
.DESCRIPTION
  ADR 0001 (regle 7) et ADR 0010 : AutoMapper, MediatR, FluentAssertions, MassTransit, SixLabors (ImageSharp), Oracle.*
  Fichiers examines (hors node_modules, bin, obj, build, .dart_tool, .nx, .git) :
    - .NET : Directory.Packages.props, *.csproj, *.props, *.targets (PackageVersion / PackageReference / GlobalPackageReference)
    - web  : package.json (dependencies, devDependencies, peerDependencies, optionalDependencies) et package-lock.json (transitifs)
    - mobile : pubspec.yaml et pubspec.lock (transitifs)
    - -IncludeRestoredAssets : obj/project.assets.json (transitifs .NET, apres `dotnet restore`)
  Exception : une ligne `NomDuPaquet  # ADR NNNN` dans le fichier d'exceptions (-AllowFile). Une ligne sans reference ADR est refusee.
  Compatible Windows PowerShell 5.1 et PowerShell 7 (agent Ubuntu).
.PARAMETER Root
  Racine du depot (par defaut : dossier parent de scripts/).
.PARAMETER AllowFile
  Fichier d'exceptions (par defaut : scripts/ci/banned-packages.allow, facultatif).
.PARAMETER IncludeRestoredAssets
  Examine aussi obj/project.assets.json (a lancer apres `dotnet restore`).
.EXAMPLE
  pwsh -File scripts/ci/check-banned-packages.ps1
#>
[CmdletBinding()]
param(
    [string]$Root,
    [string]$AllowFile,
    [switch]$IncludeRestoredAssets
)

$ErrorActionPreference = 'Stop'

$here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $Root) { $Root = Split-Path -Parent (Split-Path -Parent $here) }
if (-not $AllowFile) { $AllowFile = Join-Path $here 'banned-packages.allow' }
$Root = (Resolve-Path -LiteralPath $Root).Path.TrimEnd([char[]]@([char]92, [char]47))

# Prefixe interdit : le nom est egal au prefixe ou commence par prefixe + separateur (. - _ /). `oracle` : tout nom commencant par oracle.
$bannedPrefixes = @('automapper', 'mediatr', 'fluentassertions', 'masstransit', 'sixlabors')
$bannedAnyStart = @('oracle')

$excludedSegments = @('node_modules', 'bin', 'obj', 'build', '.dart_tool', '.nx', '.git', 'dist', 'out-tsc', '.pub-cache')

function Test-Banned {
    param([string]$Name)
    $n = $Name.Trim().ToLowerInvariant()
    # Retire la portee npm (@scope/nom) en gardant aussi le nom de portee a tester.
    $candidates = @($n)
    if ($n.StartsWith('@') -and $n.Contains('/')) {
        $candidates += $n.Substring(1).Split('/')[0]
        $candidates += $n.Split('/', 2)[1]
    }
    foreach ($c in $candidates) {
        foreach ($p in $bannedPrefixes) {
            if ($c -eq $p -or $c.StartsWith($p + '.') -or $c.StartsWith($p + '-') -or $c.StartsWith($p + '_') -or $c.StartsWith($p + '/')) { return $true }
        }
        foreach ($p in $bannedAnyStart) {
            if ($c.StartsWith($p)) { return $true }
        }
    }
    return $false
}

function Get-RepoFiles {
    param([string[]]$Filters)
    foreach ($filter in $Filters) {
        Get-ChildItem -Path $Root -Recurse -File -Filter $filter -Force -ErrorAction SilentlyContinue |
            Where-Object {
                $relative = $_.FullName.Substring($Root.Length).TrimStart('\', '/')
                $segments = $relative -split '[\\/]'
                # Le dernier segment est le nom du fichier : on ne teste que les dossiers.
                $folders = if ($segments.Length -gt 1) { $segments[0..($segments.Length - 2)] } else { @() }
                -not ($folders | Where-Object { $excludedSegments -contains $_ })
            }
    }
}

# Exceptions autorisees par ADR.
$allowed = @{}
$errors = New-Object System.Collections.Generic.List[string]
if (Test-Path -LiteralPath $AllowFile) {
    foreach ($line in Get-Content -LiteralPath $AllowFile) {
        $text = $line.Trim()
        if ($text -eq '' -or $text.StartsWith('#')) { continue }
        if ($text -match '^(?<name>[^\s#]+)\s*#\s*ADR\s*(?<num>\d{4})') {
            $allowed[$Matches['name'].ToLowerInvariant()] = $Matches['num']
        } else {
            $errors.Add("Exception invalide dans $AllowFile (reference 'ADR NNNN' obligatoire) : $text")
        }
    }
}

$findings = New-Object System.Collections.Generic.List[string]
$scanned = 0

function Add-Finding {
    param([string]$Name, [string]$File, [string]$Kind)
    if (-not (Test-Banned $Name)) { return }
    if ($allowed.ContainsKey($Name.ToLowerInvariant())) { return }
    $relative = $File.Substring($Root.Length).TrimStart('\', '/')
    $findings.Add("$Name  ($Kind)  dans $relative")
}

# --- .NET : manifestes XML
foreach ($file in Get-RepoFiles @('*.csproj', '*.props', '*.targets')) {
    $scanned++
    [xml]$xml = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($node in $xml.SelectNodes('//PackageVersion | //PackageReference | //GlobalPackageReference | //PackageDownload')) {
        $name = $node.GetAttribute('Include')
        if (-not $name) { $name = $node.GetAttribute('Update') }
        if ($name) { Add-Finding $name $file.FullName '.NET' }
    }
}

# --- Web : package.json (dependances directes) et package-lock.json (transitifs)
foreach ($file in Get-RepoFiles @('package.json')) {
    $scanned++
    $json = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    foreach ($section in 'dependencies', 'devDependencies', 'peerDependencies', 'optionalDependencies') {
        $block = $json.PSObject.Properties[$section]
        if ($null -eq $block -or $null -eq $block.Value) { continue }
        foreach ($property in $block.Value.PSObject.Properties) { Add-Finding $property.Name $file.FullName 'npm' }
    }
}
foreach ($file in Get-RepoFiles @('package-lock.json')) {
    $scanned++
    $text = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($m in [regex]::Matches($text, '"node_modules/((?:@[^/"]+/)?[^/"]+)"')) {
        Add-Finding $m.Groups[1].Value $file.FullName 'npm transitif'
    }
}

# --- Mobile : pubspec.yaml (directs) et pubspec.lock (transitifs)
foreach ($file in Get-RepoFiles @('pubspec.yaml')) {
    $scanned++
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        if ($line -match '^\s{2}(?<name>[A-Za-z0-9_]+)\s*:') { Add-Finding $Matches['name'] $file.FullName 'pub' }
    }
}
foreach ($file in Get-RepoFiles @('pubspec.lock')) {
    $scanned++
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        if ($line -match '^\s{2}(?<name>[A-Za-z0-9_]+):\s*$') { Add-Finding $Matches['name'] $file.FullName 'pub transitif' }
    }
}

# --- .NET transitifs apres restore (obj est exclu des autres recherches)
if ($IncludeRestoredAssets) {
    $assets = Get-ChildItem -Path $Root -Recurse -File -Filter 'project.assets.json' -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' }
    foreach ($file in $assets) {
        $scanned++
        $text = Get-Content -LiteralPath $file.FullName -Raw
        foreach ($m in [regex]::Matches($text, '"(?<id>[A-Za-z0-9_.\-]+)/\d[^"]*"\s*:\s*\{')) {
            Add-Finding $m.Groups['id'].Value $file.FullName '.NET transitif'
        }
    }
}

if ($scanned -eq 0) { throw "Aucun manifeste trouve sous $Root : verifier -Root." }

foreach ($e in $errors) { Write-Host "ERREUR : $e" }
$unique = $findings | Sort-Object -Unique
foreach ($f in $unique) { Write-Host "INTERDIT : $f" }

if ($errors.Count -gt 0 -or @($unique).Count -gt 0) {
    Write-Host ''
    Write-Host 'Paquets interdits sans ADR (ADR 0001 regle 7, ADR 0010). Retirer le paquet, ou ecrire un ADR puis ajouter'
    Write-Host "'NomDuPaquet  # ADR NNNN' dans scripts/ci/banned-packages.allow."
    exit 1
}

Write-Host "Aucun paquet interdit ($scanned manifestes examines)."
exit 0
