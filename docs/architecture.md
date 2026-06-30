# Architecture

## Overview

This project automates uploading recordings from a Windows workstation to a self-hosted Nextcloud server.

The uploader continuously monitors a local directory, detects completed recordings and uploads them to Nextcloud using WebDAV.

A watchdog service ensures the uploader is always running and automatically restarts it if the process stops unexpectedly.

---

## Workflow

```text
Recording Software
        │
        ▼
 Local Folder
        │
        ▼
upload-recordings.ps1
        │
        ▼
   WebDAV Upload
        │
        ▼
 Nextcloud Server
        │
        ▼
 Stored in Cloud

        ▲
        │
 Watchdog Service
```

---

## Components

| Component | Purpose |
|-----------|---------|
| upload-recordings.ps1 | Upload recordings |
| install-watchdog.bat | Install watchdog |
| start-upload.bat | Start uploader |
| stop-upload.bat | Stop uploader |
| restart-upload.bat | Restart uploader |
| Nextcloud | File storage |
| WebDAV | Upload protocol |

---

## Automation Flow

1. Monitor recording folder.
2. Detect completed files.
3. Upload files to Nextcloud.
4. Verify upload.
5. Log result.
6. Continue monitoring.
