<#
.SYNOPSIS
    Generic extractor for USGS NED data.
.DESCRIPTION
    Extracts ZIP files and renames 1/3 arc-second DEM GeoTIFFs to OpenTopoData format.
    Works for any location (North/South/East/West).
#>

param(
    [string]$SourceZipDir = ".\data", # Default to project data folder
    [string]$TargetDataDir = ".\data\ned10m" # Relative path to project data dir
)

$ErrorActionPreference = "Stop"
$SourceZipDir = Resolve-Path $SourceZipDir
$TargetDataDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetDataDir)

Write-Host "Source: $SourceZipDir"
Write-Host "Target: $TargetDataDir"

if (-not (Test-Path $SourceZipDir)) { Write-Error "Source directory not found!" }
if (-not (Test-Path $TargetDataDir)) { 
    New-Item -ItemType Directory -Force -Path $TargetDataDir | Out-Null
    Write-Host "Created target directory."
}

# 1. Extract
$tempDir = Join-Path $SourceZipDir "mesh_extract_temp"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

$zips = Get-ChildItem -Path $SourceZipDir -Filter "*.zip"
if ($zips.Count -gt 0) {
    Write-Host "Extracting $($zips.Count) ZIP files..." -ForegroundColor Cyan
    foreach ($zip in $zips) {
        Expand-Archive -Path $zip.FullName -DestinationPath $tempDir -Force
    }
}
else {
    Write-Warning "No ZIPs found. Checking for existing TIFs..."
}

# 2. Process TIFs
# Check temp dir first, then source dir
$searchDir = if ((Get-ChildItem $tempDir -Filter "*.tif").Count -gt 0) { $tempDir } else { $SourceZipDir }
$tifs = Get-ChildItem -Path $searchDir -Filter "*.tif" -Recurse

Write-Host "Processing $($tifs.Count) TIFF files..." -ForegroundColor Cyan

foreach ($file in $tifs) {
    $filename = $file.BaseName
    
    # Generic Regex for USGS: nXX_wYYY or nXXwYYY, potentially with s/e
    # Matches: n45_w122, s12_e030, etc.
    if ($filename -match '([ns])(\d+)[_]?([ew])(\d+)') {
        $latDir = $matches[1] # n or s
        $latVal = [int]$matches[2]
        $lonDir = $matches[3] # e or w
        $lonVal = [int]$matches[4]

        # SRTM Naming Logic (Bottom-Left Corner)
        # USGS usually names by Top-Left (NW).
        # Standard: Top Edge -> Bottom Edge = Top - 1.
        
        $latTop = if ($latDir -eq 'n') { $latVal } else { -1 * $latVal }
        $latBottom = $latTop - 1
        
        # Format new Lat part
        $newLatChar = if ($latBottom -ge 0) { 'n' } else { 's' }
        $newLatVal = [math]::Abs($latBottom)
        
        # Format new Lon part
        $newLonChar = $lonDir 
        $newLonVal = $lonVal

        # Construct name: nXXwYYY.tif
        $srtmName = "{0}{1:D2}{2}{3:D3}.tif" -f $newLatChar, $newLatVal, $newLonChar, $newLonVal
        
        $destPath = Join-Path $TargetDataDir $srtmName
        Copy-Item $file.FullName -Destination $destPath -Force
        Write-Host "$($file.Name) -> $srtmName" -ForegroundColor Gray
    }
    else {
        Write-Warning "Skipping non-standard metadata file: $($file.Name)"
    }
}

Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done. Data ready in $TargetDataDir" -ForegroundColor Green
