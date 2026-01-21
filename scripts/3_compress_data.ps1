<#
.SYNOPSIS
    Compresses GeoTIFF files using LZW compression via GDAL.
.DESCRIPTION
    Scans the data directory, compresses each .tif file to a temporary file,
    and replaces the original if successful. drasticallly reduces file size.
    Requires GDAL (gdal_translate) to be in the system PATH.
#>

param(
    [string]$DataDir
)

if (-not $DataDir) {
    $DataDir = Join-Path $PSScriptRoot "..\data\ned10m"
}

$DataDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DataDir)

Write-Host "Checking for GDAL..." -ForegroundColor Cyan

$GdalPath = "gdal_translate"
if (-not (Get-Command "gdal_translate" -ErrorAction SilentlyContinue)) {
    # Check common install location
    $CommonPath = "C:\Program Files\GDAL\gdal_translate.exe"
    if (Test-Path $CommonPath) {
        $GdalPath = $CommonPath
        
        # Set environment variables for GDAL data to prevent warnings
        if (-not $env:GDAL_DATA) {
            $env:GDAL_DATA = "C:\Program Files\GDAL\gdal-data"
        }
        if (-not $env:PROJ_LIB) {
            $env:PROJ_LIB = "C:\Program Files\GDAL\projlib"
        }
        
        Write-Host "GDAL found at $CommonPath" -ForegroundColor Green
    }
    else {
        Write-Error "GDAL is not installed or not in your PATH."
        Write-Host "To install on Windows:" -ForegroundColor Yellow
        Write-Host "  https://www.gisinternals.com/release.php" -ForegroundColor Yellow
        Write-Host "  (You may need to restart your terminal after install)"
        exit 1
    }
}
else {
    Write-Host "GDAL found in PATH. Starting compression..." -ForegroundColor Green
}

if (-not (Test-Path $DataDir)) {
    Write-Error "Data directory not found."
}

$files = Get-ChildItem $DataDir -Filter "*.tif"
if ($files.Count -eq 0) {
    Write-Error "No .tif files found to compress."
}

$totalSaved = 0

foreach ($file in $files) {
    $tempFile = "$($file.FullName).tmp.tif"
    
    Write-Host "Compressing $($file.Name)..." -NoNewline
    
    # Run GDAL Translate
    # -co COMPRESS=DEFLATE : Efficient lossless compression for DEMs
    # -co PREDICTOR=3      : Floating point predictor (crucial for DEM compression)
    # -co TILED=YES        : Optimizes for random access reading
    $process = Start-Process -FilePath $GdalPath -ArgumentList "-co", "COMPRESS=DEFLATE", "-co", "PREDICTOR=3", "-co", "TILED=YES", "`"$($file.FullName)`"", "`"$tempFile`"" -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -eq 0 -and (Test-Path $tempFile)) {
        $origSize = $file.Length
        $newSize = (Get-Item $tempFile).Length
        $saved = $origSize - $newSize
        $totalSaved += $saved
        
        # Replace original
        Remove-Item $file.FullName -Force
        Rename-Item $tempFile $file.Name
        
        $percent = [math]::Round(($saved / $origSize) * 100, 1)
        Write-Host " Done. Saved ${percent}%." -ForegroundColor Green
    }
    else {
        Write-Host " Failed!" -ForegroundColor Red
        if (Test-Path $tempFile) { Remove-Item $tempFile }
    }
}

$mbSaved = [math]::Round($totalSaved / 1MB, 2)
Write-Host ""
Write-Host "Compression Complete!" -ForegroundColor Cyan
Write-Host "Total space saved: $mbSaved MB" -ForegroundColor Green
Write-Host "Next Step: Run '4_auto_configure.ps1'"
