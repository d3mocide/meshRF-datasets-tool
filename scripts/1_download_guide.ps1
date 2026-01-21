<#
.SYNOPSIS
    Interactive guide to download NED 10m data for any region.
.DESCRIPTION
    Provides a menu to select a preset region (PNW) or a custom region.
    Opens the USGS Downloader and provides instructions or coordinates.
#>

$Url = "https://apps.nationalmap.gov/downloader/"

function Show-Header {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "      MeshRF Dataset Download Assistant       " -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
}

Show-Header
Write-Host "Select your region:"
Write-Host "1. Pacific Northwest (WA/OR) - Recommended for Tutorial"
Write-Host "2. Custom Area (Guide me)"
Write-Host ""
$choice = Read-Host "Enter selection (1 or 2)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "--- PNW PRESET SELECTED ---" -ForegroundColor Yellow
    Write-Host "1. The browser will open to: $Url"
    Write-Host "2. Select 'Elevation Products (3DEP)' > '1/3 arc-second DEM' > 'GeoTIFF'."
    Write-Host "3. Use 'Box/Point' tool > 'Enter Coordinates' and paste these:"
    Write-Host ""
    Write-Host "   North:  49.0" -ForegroundColor Green
    Write-Host "   South:  41.75" -ForegroundColor Green
    Write-Host "   East:  -116.0" -ForegroundColor Green
    Write-Host "   West:  -125.5" -ForegroundColor Green
    Write-Host ""
    Write-Host "4. Download all resulting files (~48 files)."
}
else {
    Write-Host ""
    Write-Host "--- CUSTOM AREA SELECTED ---" -ForegroundColor Yellow
    Write-Host "1. The browser will open to: $Url"
    Write-Host "2. Select 'Elevation Products (3DEP)' > '1/3 arc-second DEM' > 'GeoTIFF'."
    Write-Host "3. Use the 'Box/Point' tool to draw a box around your area of interest."
    Write-Host "4. Click 'Search Products'."
    Write-Host "5. Download all resulting ZIP files."
    Write-Host ""
    Write-Host "TIP: Don't make the area too huge (e.g. entire US) or you'll have 1000s of files."
    Write-Host "     Start with a city or county size first."
}

Write-Host ""
Write-Host "ACTION REQUIRED: Save/Move all downloaded ZIP files to a temporary folder."
Write-Host "Example: 'Downloads/MeshRF_Data'"
Write-Host ""
Write-Host "Press any key to open browser..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Process $Url

Write-Host "Browser opened." -ForegroundColor Cyan
Write-Host "When downloads are finished, run '2_process_data.ps1'." -ForegroundColor Green
