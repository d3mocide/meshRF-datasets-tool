# MeshRF Dataset Setup

This toolkit allows you to download and configure 10m resolution terrain data (NED/3DEP) for **any region** in the US, including the Pacific Northwest as an example.

## Quick Start (PNW Region)

If you just want the standard Washington/Oregon dataset:

1.  Download the PNW data following the steps in [DOWNLOAD_GUIDE.md](./DOWNLOAD_GUIDE.md) (Step 4 details the PNW coords).
2.  Move the downloaded ZIP files to the `data/` folder.
3.  Run `.\scripts\2_process_data.ps1`.
4.  (Optional) Run `.\scripts\3_compress_data.ps1` to save disk space.
5.  Run `.\scripts\4_auto_configure.ps1`.

## Custom Region Guide

To set up MeshRF for your own area (e.g., Texas, California, etc.):

### 1. Download Data

1.  Open [DOWNLOAD_GUIDE.md](./DOWNLOAD_GUIDE.md) to see how to target your specific area.
2.  Download the ZIP files as instructed.

### 2. Process Files

1.  Move all downloaded ZIP files to the `data/` folder in this repository.
2.  Run:

```powershell
.\scripts\2_process_data.ps1
```

- This extracts the USGS data and renames it to the format MeshRF needs.
- It automatically handles any coordinate (North/South/East/West).

### 3. Compress Data (Optional)

Run:

```powershell
.\scripts\3_compress_data.ps1
```

- This step compresses the huge GeoTIFF files using LZW (lossless).
- It typically reduces the dataset size by **50% or more**.
- Requires **GDAL** installed (the script will tell you if you need it).

### 4. Generate Config

Run:

```powershell
.\scripts\4_auto_configure.ps1
```

- This script **scans your processed files** to find the exact latitude/longitude bounds.
- It updates (or creates) `data/config.yaml` automatically.
- It prints the environment variables you need to check in `docker-compose.yml`.

### 5. Verify

Run:

```powershell
.\scripts\5_validate_setup.ps1
```

## Directory Info

- `scripts/`: The automation scripts.
- `./data/ned10m`: The destination folder where verified data is stored.
