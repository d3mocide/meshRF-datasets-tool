# MeshRF Dataset Setup

This toolkit allows you to download and configure 10m resolution terrain data (NED/3DEP) for **any region** in the US, including the Pacific Northwest.

## Quick Start (PNW Region)

If you just want the standard Washington/Oregon dataset:

1.  Run `.\scripts\1_download_guide.ps1` and select **Option 1**.
2.  Download the files & move them to a folder.
3.  Run `.\scripts\2_process_data.ps1 -SourceZipDir "path/to/downloads"`.
4.  Run `.\scripts\3_auto_configure.ps1`.

## Custom Region Guide

To set up MeshRF for your own area (e.g., Texas, California, etc.):

### 1. Download Data

Run:

```powershell
.\scripts\1_download_guide.ps1
```

- Select **Option 2 (Custom Area)**.
- Use the map tool in the browser to draw a box around your area.
- **Tip**: Keep the selection reasonable (e.g., a few counties or a state) to avoid massive downloads.
- Download all the ZIP files.

### 2. Process Files

Run:

```powershell
.\scripts\2_process_data.ps1 -SourceZipDir "C:\Path\To\Your\Downloads"
```

- This extracts the USGS data and renames it to the format MeshRF needs.
- It automatically handles any coordinate (North/South/East/West).

### 3. Generate Config

Run:

```powershell
.\scripts\3_auto_configure.ps1
```

- This script **scans your processed files** to find the exact latitude/longitude bounds.
- It updates (or creates) `data/config.yaml` automatically.
- It prints the environment variables you need to check in `docker-compose.yml`.

### 4. Verify

Run:

```powershell
.\scripts\4_validate_setup.ps1
```

## Directory Info

- `scripts/`: The automation scripts.
- `./data/ned10m`: The destination folder where verified data is stored.
