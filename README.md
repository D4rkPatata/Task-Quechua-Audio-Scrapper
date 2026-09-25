# Task-Quechua — Grabador de Radio Onda Azul

Graba automáticamente la transmisión en vivo de **Radio Onda Azul (Puno)** en archivos de 1 hora y los copia a Google Drive.

## Requisitos

- Windows 10/11 con PowerShell 5.1
- **ffmpeg**: `winget install Gyan.FFmpeg`
- **Google Drive para escritorio** (solo para la subida): `winget install Google.GoogleDrive`, e iniciar sesión

## Instalación

1. Copia la carpeta a `D:\Task-Quechua`. Si usas otra ruta, cambia los valores por defecto de `$Salida` y `$Origen` en los scripts.
2. Clic derecho sobre `instalar_tareas.ps1` > **Ejecutar con PowerShell** (solo una vez).

Esto crea dos tareas en el Programador de tareas de Windows:

| Tarea | Cuándo corre | Qué hace |
|---|---|---|
| `OndaAzul - Grabar` | Diario a las 02:55 y al iniciar sesión | Ejecuta `grabar_ondaazul.ps1` |
| `OndaAzul - Subir Drive` | Diario a las 10:00, 16:00 y 23:00 | Ejecuta `subir_drive.ps1` |

Las dos tareas son independientes: si la subida falla, la grabación sigue.

## Scripts

### `grabar_ondaazul.ps1`

- Graba el stream `https://stream.zeno.fm/z4xkhcavfu4uv` con ffmpeg sin recodificar.
- Guarda archivos de 1 hora en `raw\AAAAMMDD_HHMMSS.aac`.
- Graba desde que arranca hasta las **22:05**. Si el stream se cae, reintenta.
- Solo permite una grabación a la vez y evita que el equipo se suspenda mientras graba.

Uso manual:

```powershell
powershell -ExecutionPolicy Bypass -File .\grabar_ondaazul.ps1 [-Salida D:\ruta] [-HoraFin 22:05]
```

### `subir_drive.ps1`

No usa la API de Google. **Copia** los `.aac` terminados a la carpeta que sincroniza Google Drive para escritorio, y esa app los sube a la nube.

- Busca `Mi unidad` o `My Drive` en todas las unidades y copia a `<Drive>\OndaAzul\raw`.
- Se salta el archivo que se está grabando (modificado hace menos de 5 minutos).
- No vuelve a copiar archivos que ya existen en el destino con el mismo tamaño.
- **No borra** los archivos locales.

Uso manual:

```powershell
powershell -ExecutionPolicy Bypass -File .\subir_drive.ps1 [-Origen D:\ruta\raw] [-Destino "G:\Mi unidad\OndaAzul\raw"]
```

### `instalar_tareas.ps1`

Registra (o vuelve a registrar) las dos tareas programadas. Se puede ejecutar de nuevo sin problema; sobrescribe las tareas existentes.

## Archivos generados

| Ruta | Contenido |
|---|---|
| `raw\*.aac` | Audios grabados, uno por hora |
| `grabar.log` | Registro de la grabación |
| `subir.log` | Registro de los archivos copiados a Drive |

## Notas

- **Espacio en disco:** cada hora pesa ~60–70 MB, o sea ~1.2 GB por día. Nada borra los audios locales; límpialos a mano cuando ya estén en Drive.
- **Si no se sube nada:** revisa que Google Drive para escritorio esté instalado y con sesión iniciada. Si la carpeta de Drive está en otra ruta, agrega `-Destino "..."` a la tarea `OndaAzul - Subir Drive`.
- **Ver el estado de las tareas:**

  ```powershell
  Get-ScheduledTask -TaskName 'OndaAzul*' | Select-Object TaskName, State
  ```
