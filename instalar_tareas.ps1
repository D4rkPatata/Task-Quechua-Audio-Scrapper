# ============================================================
#  Registra las tareas programadas de Windows (ejecutar UNA vez).
#  Clic derecho sobre este archivo > "Ejecutar con PowerShell"
# ============================================================
$dir = $PSScriptRoot
$ps  = 'powershell.exe'
$set = New-ScheduledTaskSettingsSet -WakeToRun -StartWhenAvailable -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 20) -MultipleInstances IgnoreNew

# 1) Grabar: todos los dias 02:55 + al iniciar sesion (por si la laptop se reinicio en el dia)
$accG = New-ScheduledTaskAction -Execute $ps -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$dir\grabar_ondaazul.ps1`""
$trgG = @( (New-ScheduledTaskTrigger -Daily -At '02:55'), (New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME) )
Register-ScheduledTask -TaskName 'OndaAzul - Grabar' -Action $accG -Trigger $trgG -Settings $set -Force | Out-Null
Write-Host 'OK  Tarea "OndaAzul - Grabar" (02:55 diario + al iniciar sesion)'

# 2) Subir a Drive: 10:00, 16:00 y 23:00 (solo si tienes Google Drive para escritorio)
$accS = New-ScheduledTaskAction -Execute $ps -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$dir\subir_drive.ps1`""
$trgS = @('10:00', '16:00', '23:00' | ForEach-Object { New-ScheduledTaskTrigger -Daily -At $_ })
Register-ScheduledTask -TaskName 'OndaAzul - Subir Drive' -Action $accS -Trigger $trgS -Settings $set -Force | Out-Null
Write-Host 'OK  Tarea "OndaAzul - Subir Drive" (10:00, 16:00, 23:00)'

Write-Host "`nAudios en: $HOME\Documents\OndaAzul\raw   |   Log: $HOME\Documents\OndaAzul\grabar.log"
Read-Host 'Enter para cerrar'
