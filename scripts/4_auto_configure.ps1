<#
.SYNOPSIS
    Auto-detects coverage bounds and generates config.
.DESCRIPTION
    Scans the data directory for nXXwYYY files, calculates the full bounding box,
    and updates config.yaml and docker-compose.yml instructions.
#>

param(
    [string]$DataDir
)

if (-not $DataDir) {
    $DataDir = Join-Path $PSScriptRoot "..\data\ned10m"
}

$DataDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DataDir)

Write-Host "Scanning $DataDir for elevation tiles..." -ForegroundColor Cyan

if (-not (Test-Path $DataDir)) {
    Write-Error "Data directory not found. Run '2_process_data.ps1' first."
}

$files = Get-ChildItem $DataDir -Filter "*.tif"
if ($files.Count -eq 0) {
    Write-Error "No .tif files found."
}

# Bounds initialization
$minLat = 90
$maxLat = -90
$minLon = 180
$maxLon = -180

foreach ($f in $files) {
    if ($f.Name -match '([ns])(\d+)([ew])(\d+)') {
        $latDir = $matches[1]
        $latVal = [int]$matches[2]
        $lonDir = $matches[3]
        $lonVal = [int]$matches[4]
        
        # Parse SRTM name (Bottom-Left corner)
        $lat = if ($latDir -eq 'n') { $latVal } else { -1 * $latVal }
        $lon = if ($lonDir -eq 'e') { $lonVal } else { -1 * $lonVal }
        
        # Update bounds
        # Tile covers Lat to Lat+1, Lon to Lon+1
        if ($lat -lt $minLat) { $minLat = $lat }
        if (($lat + 1) -gt $maxLat) { $maxLat = $lat + 1 }
        
        if ($lon -lt $minLon) { $minLon = $lon }
        if (($lon + 1) -gt $maxLon) { $maxLon = $lon + 1 }
    }
}

Write-Host "Detected Coverage:" -ForegroundColor Yellow
Write-Host "  Lat: $minLat to $maxLat"
Write-Host "  Lon: $minLon to $maxLon"

# Config Generation
$configContent = @"
datasets:
  - name: ned10m
    path: /app/data/ned10m/
    filename_epsg: 4269
    filename_tile_size: 1
    wgs84_bounds:
      left: $minLon
      right: $maxLon
      bottom: $minLat
      top: $maxLat
"@

Write-Host ""
Write-Host "File created: config.yaml" -ForegroundColor Green
$ConfigPath = Join-Path $PSScriptRoot "..\data\config.yaml"
Set-Content -Path $ConfigPath -Value $configContent -Force

Write-Host ""
Write-Host "Update your docker-compose.yml with:" -ForegroundColor Cyan
Write-Host "------------------------------------------------"
Write-Host "services:"
Write-Host "  rf-engine:"
Write-Host "    environment:"
Write-Host "      - ELEVATION_DATASET=ned10m"
Write-Host "------------------------------------------------"
