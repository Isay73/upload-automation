# Nextcloud Upload Automation

## Overview

This project automates uploading recordings from Windows to a self-hosted Nextcloud server.

The solution monitors a local folder and uploads completed files to a predefined Nextcloud directory using WebDAV.

To ensure reliability, a watchdog process automatically restarts the uploader if it stops unexpectedly.

---

## Technologies

- PowerShell
- Windows Task Scheduler
- WebDAV
- Nextcloud
- Batch Scripts

---

## Features

- Automatic upload
- Folder monitoring
- Automatic restart
- Logging
- WebDAV authentication
- Recursive folder creation

---

## Project Structure

```text
scripts/
├── upload-recordings.ps1
├── install-watchdog.bat
├── start-upload.bat
├── stop-upload.bat
└── restart-upload.bat
```

---

## Workflow

```text
Recorder Folder
       │
PowerShell Script
       │
 WebDAV Upload
       │
 Nextcloud Server
```

---

## What I Built

I created a fully automated upload workflow for transferring recordings from Windows workstations to a self-hosted Nextcloud server.

The solution includes automatic startup, monitoring, logging and recovery using Windows Task Scheduler and PowerShell.

---

## Security

Passwords, domains and credentials have been removed from this repository.
