# ============================================================
#  Graba Radio Onda Azul (Puno) en archivos de 1 hora (.aac)
#  Desde que se lanza hasta las 22:05. Si el stream se cae, reintenta.
#  Uso manual:  powershell -ExecutionPolicy Bypass -File .\grabar_ondaazul.ps1
# ============================================================
param(
    [string]$Salida  = "D:\Task-Quechua\raw",
    [string]$HoraFin = "22:05"
)

$Stream = 'https://stream.zeno.fm/z4xkhcavfu4uv'
New-Item -ItemType Directory -Force -Path $Salida | Out-Null
$Log = Join-Path (Split-Path $Salida) 'grabar.log'
function Log($m) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $m" | Add-Content -Path $Log }

# --- Una sola grabacion a la vez ---
$mutex = New-Object System.Threading.Mutex($false, 'Local\OndaAzulGrabador')
if (-not $mutex.WaitOne(0)) { Log 'Ya hay una grabacion corriendo, salgo.'; exit }

# --- Buscar ffmpeg ---
$ffmpeg = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source
if (-not $ffmpeg) { $ffmpeg = "$env:LOCALAPPDATA\Microsoft\WinGet\Links\ffmpeg.exe" }
if (-not (Test-Path $ffmpeg)) { Log "No encuentro ffmpeg. Instala con: winget install Gyan.FFmpeg"; exit 1 }

# --- Evitar que la laptop se suspenda mientras graba ---
Add-Type -Namespace Win -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);'
[Win.Power]::SetThreadExecutionState([uint32]0x80000001) | Out-Null   # CONTINUOUS | SYSTEM_REQUIRED

$fin = [datetime]::Today.Add([timespan]::Parse($HoraFin))
if ((Get-Date) -ge $fin) { Log "Ya paso la hora de fin ($HoraFin), no grabo."; exit }

Log "Inicio de grabacion hasta $HoraFin -> $Salida"
while ((Get-Date) -lt $fin) {
    $resta = [int][math]::Floor(($fin - (Get-Date)).TotalSeconds)
    if ($resta -lt 30) { break }
    Log "Lanzando ffmpeg por $resta s"
    $patron = Join-Path $Salida '%Y%m%d_%H%M%S.aac'
    & $ffmpeg -nostdin -hide_banner -loglevel error `
        -reconnect 1 -reconnect_streamed 1 -reconnect_at_eof 1 -reconnect_delay_max 60 `
        -i $Stream -t $resta -c copy `
        -f segment -segment_time 3600 -strftime 1 $patron 2>&1 | ForEach-Object { Log "ffmpeg: $_" }
    Log "ffmpeg termino (codigo $LASTEXITCODE)"
    Start-Sleep -Seconds 10
}

[Win.Power]::SetThreadExecutionState([uint32]0x80000000) | Out-Null
$mutex.ReleaseMutex()
Log 'Fin de grabacion del dia.'
