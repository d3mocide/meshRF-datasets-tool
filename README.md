# MeshRF Dataset Setup

This toolkit allows you to download and configure 10m resolution terrain data (NED/3DEP) for **any region** in the US, including the Pacific Northwest as an example.

## Quick Start (PNW Region)

If you just want the standard Washington/Oregon dataset:

1.  Download the PNW data following the steps in [DOWNLOAD_GUIDE.md](./DOWNLOAD_GUIDE.md) (Step 4 details the PNW coords).
2.  Download the files & move them to a folder.
3.  Run `.\scripts\2_process_data.ps1 -SourceZipDir "path/to/downloads"`.
4.  Run `.\scripts\3_auto_configure.ps1`.

## Custom Region Guide

To set up MeshRF for your own area (e.g., Texas, California, etc.):

### 1. Download Data

1.  Open [DOWNLOAD_GUIDE.md](./DOWNLOAD_GUIDE.md) to see how to target your specific area.
2.  Download the ZIP files as instructed.

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
