<#
.SYNOPSIS
    Validates that data and config are ready.
.DESCRIPTION
    Checks for the existence of TIF files in the data directory and 
    verifies that config.yaml exists.
#>

param(
    [string]$DataDir = "..\data\ned10m"
)

$DataDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DataDir)
$AllGood = $true

Write-Host "Validating setup in: $DataDir" -ForegroundColor Cyan

if (-not (Test-Path $DataDir)) {
    Write-Error "Data directory not found!"
    $AllGood = $false
}
else {
    $files = Get-ChildItem $DataDir -Filter "*.tif"
    if ($files.Count -eq 0) {
        Write-Warning "No .tif files found in data directory."
        $AllGood = $false
    }
    else {
        Write-Host "✓ Found $($files.Count) .tif files." -ForegroundColor Green
        
        # Spot check strict naming
        $sample = $files[0].Name
        if ($sample -match "^[nNsS]\d{2}[wWeE]\d{3}\.tif$") {
            Write-Host "✓ File naming looks correct (e.g. $sample)" -ForegroundColor Green
        }
        else {
            Write-Warning "Naming might be non-standard ($sample). Standard is nXXwYYY.tif."
        }
    }
}

# Config check
$configPath = Resolve-Path "..\data\config.yaml" -ErrorAction SilentlyContinue
if ($configPath) {
    Write-Host "✓ config.yaml detected." -ForegroundColor Green
}
else {
    Write-Warning "config.yaml not found in data/ directory."
    $AllGood = $false
}

if ($AllGood) {
    Write-Host "`nSETUP COMPLETE!" -ForegroundColor Green -BackgroundColor Black
    Write-Host "You are ready to use MeshRF with your custom terrain data."
}
