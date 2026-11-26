<#
.SYNOPSIS
  Demarrage local de l'environnement de developpement Chantier (D0 base, D2 API + web + mobile).
.DESCRIPTION
  Sans option : demarre seulement la base SQL Server 2022 (conteneur) et attend qu'elle soit saine.
  -Api     base + API (http://localhost:8195, Seed:Demo=true : comptes de demonstration *.dev).
  -Web     base + API + back-office web (http://localhost:3600).
  -All     equivalent de -Web.
  -Mobile  base + API, puis lance l'application Flutter au premier plan sur l'emulateur ou le telephone.
  -Phone   avec -Mobile : telephone reel (adb reverse tcp:8195, API_BASE_URL=http://localhost:8195/api/v1).
  -Status  affiche l'etat de la base, de l'API et du web, sans rien demarrer.
  -Down    arrete le web, l'API (processus lances par ce script) et la base (le volume de donnees est conserve).
  -Reset   arrete la base ET supprime le volume (perte des donnees locales) : demande une confirmation.
  Secrets : .env (mot de passe SA, genere aleatoirement, jamais affiche) ; cle JWT de developpement creee dans les
  user-secrets du projet WebApi si elle n'y est pas deja. La chaine de connexion est passee au processus API par variable
  d'environnement (jamais ecrite dans un fichier). Journaux et PID : .dev/ (ignore par git).
.PARAMETER DeviceId
  Identifiant de l'appareil pour `flutter run -d` (liste : `flutter devices`). Sans valeur : Flutter choisit.
.EXAMPLE
  powershell -File scripts/dev.ps1 -All
.EXAMPLE
  powershell -File scripts/dev.ps1 -Mobile -Phone
#>
[CmdletBinding()]
param(
    [switch]$Api,
    [switch]$Web,
    [switch]$All,
    [switch]$Mobile,
    [switch]$Phone,
    [switch]$Status,
    [switch]$Down,
    [switch]$Reset,
    [string]$DeviceId
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$compose = Join-Path $root 'docker-compose.dev.yml'
$envFile = Join-Path $root '.env'
$devDir = Join-Path $root '.dev'
$apiProject = Join-Path $root 'chantier-backend\WebApi\Chantier.WebApi'
$webDir = Join-Path $root 'chantier-frontend'
$mobileDir = Join-Path $root 'chantier-mobile'
$apiPort = 8195
$webPort = 3600

function Invoke-Compose {
    param([string[]]$ComposeArgs)
    & docker compose -f $compose --project-directory $root @ComposeArgs
    if ($LASTEXITCODE -ne 0) { throw "docker compose a echoue (code $LASTEXITCODE)." }
}

function Get-EnvValue {
    param([string]$Name)
    if (-not (Test-Path $envFile)) { return $null }
    $m = Select-String -Path $envFile -Pattern ("^" + [regex]::Escape($Name) + "=(.*)$") | Select-Object -First 1
    if ($m) { return $m.Matches[0].Groups[1].Value.Trim() }
    return $null
}

function Test-Url {
    param([string]$Url)
    try {
        $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3
        return ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500)
    } catch {
        # Un 4xx/5xx prouve que le serveur repond ; seule l'absence de reponse compte.
        if ($_.Exception.Response) { return $true }
        return $false
    }
}

function Wait-Url {
    param([string]$Url, [int]$TimeoutSeconds, [string]$Label, [string]$LogFile)
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-Url $Url) { return }
        Start-Sleep -Seconds 2
    }
    throw "$Label ne repond pas apres $TimeoutSeconds s ($Url). Journal : $LogFile"
}

function Stop-Tracked {
    param([string]$Name)
    $pidFile = Join-Path $devDir "$Name.pid"
    if (-not (Test-Path $pidFile)) { return }
    $procId = (Get-Content $pidFile -Raw).Trim()
    if ($procId -match '^\d+$' -and (Get-Process -Id ([int]$procId) -ErrorAction SilentlyContinue)) {
        # /T : arrete aussi les processus enfants (dotnet run, npx -> node).
        & taskkill /PID $procId /T /F | Out-Null
        Write-Host "$Name arrete (PID $procId)."
    }
    Remove-Item $pidFile -Force
}

function Get-Adb {
    $cmd = Get-Command adb -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($base in @($env:ANDROID_HOME, $env:ANDROID_SDK_ROOT, (Join-Path $env:LOCALAPPDATA 'Android\Sdk'))) {
        if ($base) {
            $candidate = Join-Path $base 'platform-tools\adb.exe'
            if (Test-Path $candidate) { return $candidate }
        }
    }
    return $null
}

# --- Arret et remise a zero ---------------------------------------------------------------------------------

if ($Reset) {
    $answer = Read-Host 'Supprimer la base locale et son volume ? (oui/non)'
    if ($answer -ne 'oui') { Write-Host 'Annule.'; return }
    Stop-Tracked 'web'
    Stop-Tracked 'api'
    Invoke-Compose @('down', '-v')
    return
}

if ($Down) {
    Stop-Tracked 'web'
    Stop-Tracked 'api'
    Invoke-Compose @('down')
    return
}

if ($Status) {
    $db = (& docker inspect --format '{{.State.Health.Status}}' chantier-dev-db 2>$null)
    if (-not $db) { $db = 'arretee' }
    Write-Host "Base  : $db"
    Write-Host ("API   : " + $(if (Test-Url "http://localhost:$apiPort/health/live") { "en ligne (http://localhost:$apiPort)" } else { 'arretee' }))
    Write-Host ("Web   : " + $(if (Test-Url "http://localhost:$webPort") { "en ligne (http://localhost:$webPort)" } else { 'arrete' }))
    return
}

# --- Base de donnees (D0) -----------------------------------------------------------------------------------

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker est introuvable. Installer Docker Desktop (ou utiliser MSSQLLocalDB, voir README).'
}

if (-not (Test-Path $envFile)) {
    $chars = (48..57) + (65..90) + (97..122) | ForEach-Object { [char]$_ }
    $random = -join (1..24 | ForEach-Object { $chars | Get-Random })
    # Prefixe/suffixe garantissent majuscule, minuscule, chiffre et symbole (regle SQL Server).
    $password = "Aa1!$random"
    $template = Get-Content (Join-Path $root '.env.example') -Raw
    $content = $template -replace 'MSSQL_SA_PASSWORD=.*', "MSSQL_SA_PASSWORD=$password"
    [System.IO.File]::WriteAllText($envFile, $content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host '.env cree avec un mot de passe aleatoire (non affiche).'
}

Invoke-Compose @('up', '-d')

Write-Host 'Attente de la base (healthcheck)...'
$deadline = (Get-Date).AddMinutes(3)
do {
    Start-Sleep -Seconds 5
    $dbHealth = (& docker inspect --format '{{.State.Health.Status}}' chantier-dev-db 2>$null)
    if ($dbHealth -eq 'healthy') { break }
} while ((Get-Date) -lt $deadline)

if ($dbHealth -ne 'healthy') {
    throw "La base n'est pas saine (etat : $dbHealth). Voir : docker logs chantier-dev-db"
}

$port = 14335
$m = Select-String -Path $envFile -Pattern '^MSSQL_PORT=(\d+)' | Select-Object -First 1
if ($m) { $port = $m.Matches[0].Groups[1].Value }
Write-Host "Base prete : 127.0.0.1,$port (utilisateur sa, mot de passe dans .env)."

$startApi = $Api -or $Web -or $All -or $Mobile
$startWeb = $Web -or $All
if (-not $startApi) {
    Write-Host "Chaine de connexion : definir ConnectionStrings__ChantierDb (user-secrets ou variable d'environnement), voir README."
    Write-Host 'Pour tout demarrer : scripts/dev.ps1 -All (base, API, web) ou -Mobile.'
    return
}

New-Item -ItemType Directory -Force -Path $devDir | Out-Null

# --- API (Seed:Demo=true) -----------------------------------------------------------------------------------

if (Test-Url "http://localhost:$apiPort/health/live") {
    Write-Host "API deja en ligne sur http://localhost:$apiPort (non relancee). -Down puis relancer pour la redemarrer."
} else {
    $saPassword = Get-EnvValue 'MSSQL_SA_PASSWORD'
    if (-not $saPassword) { throw 'MSSQL_SA_PASSWORD absent de .env.' }

    # Cle JWT de developpement : creee une fois dans les user-secrets (jamais affichee), sauf si deja fournie.
    if (-not $env:JwtSettings__Key) {
        $secrets = (& dotnet user-secrets list --project $apiProject 2>$null) -join "`n"
        if ($secrets -notmatch '(?m)^JwtSettings:Key\s*=') {
            $bytes = New-Object byte[] 48
            [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
            & dotnet user-secrets set 'JwtSettings:Key' ([Convert]::ToBase64String($bytes)) --project $apiProject | Out-Null
            Write-Host 'Cle JWT de developpement creee dans les user-secrets (non affichee).'
        }
    }

    $env:ASPNETCORE_ENVIRONMENT = 'Development'
    $env:Seed__Demo = 'true'
    $env:ConnectionStrings__ChantierDb = "Server=127.0.0.1,$port;Database=ChantierDev;User Id=sa;Password=$saPassword;TrustServerCertificate=True"

    Write-Host 'Compilation et demarrage de l API...'
    $apiLog = Join-Path $devDir 'api.log'
    $apiProc = Start-Process -FilePath 'dotnet' -PassThru -WindowStyle Hidden `
        -ArgumentList @('run', '--project', "`"$apiProject`"", '--no-launch-profile', '--urls', "http://localhost:$apiPort") `
        -RedirectStandardOutput $apiLog -RedirectStandardError (Join-Path $devDir 'api.err.log')
    Set-Content -Path (Join-Path $devDir 'api.pid') -Value $apiProc.Id

    # Variables retirees de ce processus : elles ne servaient qu'a l'enfant.
    Remove-Item Env:\Seed__Demo, Env:\ConnectionStrings__ChantierDb -ErrorAction SilentlyContinue

    Wait-Url "http://localhost:$apiPort/health/ready" 180 'API' $apiLog
    Write-Host "API prete : http://localhost:$apiPort (Scalar : /scalar/v1). Journaux : .dev/api.log"
}

# --- Web ----------------------------------------------------------------------------------------------------

if ($startWeb) {
    if (Test-Url "http://localhost:$webPort") {
        Write-Host "Web deja en ligne sur http://localhost:$webPort (non relance)."
    } else {
        if (-not (Test-Path (Join-Path $webDir 'node_modules'))) {
            Write-Host 'Installation des dependances web (npm ci)...'
            Push-Location $webDir
            try { & npm ci; if ($LASTEXITCODE -ne 0) { throw "npm ci a echoue (code $LASTEXITCODE)." } } finally { Pop-Location }
        }
        $webLog = Join-Path $devDir 'web.log'
        $webProc = Start-Process -FilePath 'cmd.exe' -PassThru -WindowStyle Hidden -WorkingDirectory $webDir `
            -ArgumentList @('/c', 'npx nx serve chantier-back-office') `
            -RedirectStandardOutput $webLog -RedirectStandardError (Join-Path $devDir 'web.err.log')
        Set-Content -Path (Join-Path $devDir 'web.pid') -Value $webProc.Id
        Wait-Url "http://localhost:$webPort" 120 'Web' $webLog
        Write-Host "Web pret : http://localhost:$webPort. Journaux : .dev/web.log"
    }
}

# --- Mobile (au premier plan) -------------------------------------------------------------------------------

if ($Mobile) {
    $baseUrl = 'http://10.0.2.2:8195/api/v1'
    if ($Phone) {
        $adb = Get-Adb
        if (-not $adb) { throw 'adb introuvable (installer les outils de plateforme Android ou definir ANDROID_HOME).' }
        & $adb reverse "tcp:$apiPort" "tcp:$apiPort"
        if ($LASTEXITCODE -ne 0) { throw 'adb reverse a echoue : telephone branche, debogage USB active et autorise ?' }
        $baseUrl = "http://localhost:$apiPort/api/v1"
    }
    $flutterArgs = @('run', "--dart-define=API_BASE_URL=$baseUrl")
    if ($DeviceId) { $flutterArgs += @('-d', $DeviceId) }
    Write-Host "Lancement de l'application : flutter $($flutterArgs -join ' ')"
    Push-Location $mobileDir
    try { & flutter @flutterArgs } finally { Pop-Location }
}

Write-Host ''
Write-Host 'Comptes de demonstration : voir docs/exploitation/demarrage-local.md (mot de passe : Seed:DemoPassword).'
