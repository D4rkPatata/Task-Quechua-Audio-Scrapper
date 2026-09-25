# ============================================================
#  Copia a Google Drive (Drive para escritorio) los .aac ya terminados.
#  Ignora el archivo que se esta grabando (modificado hace < 5 min).
# ============================================================
param(
    [string]$Origen  = "D:\Task-Quechua\raw",
    [string]$Destino = ""
)
if (-not $Destino) {
    $raiz = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        foreach ($n in 'Mi unidad', 'My Drive') { Join-Path $_.Root $n } } |
        Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $raiz) { Write-Host 'No encontre Google Drive para escritorio. Pasa -Destino a mano.'; exit 1 }
    $Destino = Join-Path $raiz 'OndaAzul\raw'
}
New-Item -ItemType Directory -Force -Path $Destino | Out-Null
$limite = (Get-Date).AddMinutes(-5)
Get-ChildItem -Path $Origen -Filter *.aac | Where-Object { $_.LastWriteTime -lt $limite } | ForEach-Object {
    $dst = Join-Path $Destino $_.Name
    if (-not (Test-Path $dst) -or (Get-Item $dst).Length -ne $_.Length) {
        Copy-Item $_.FullName $dst -Force
        "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  subido $($_.Name)" | Add-Content (Join-Path (Split-Path $Origen) 'subir.log')
    }
}
