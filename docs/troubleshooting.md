# Troubleshooting

## Upload does not start

Check:

- Internet connection
- PowerShell execution policy
- Folder permissions

---

## Authentication failed

Verify:

- Username
- Password
- WebDAV URL

---

## Upload interrupted

Restart uploader.

```bat
restart-upload.bat
```

---

## Watchdog not running

Reinstall.

```bat
install-watchdog.bat
```

---

## Nextcloud unavailable

Check:

- Server status
- HTTPS
- VPN connection
- WebDAV endpoint

---

## Logs

Review PowerShell output and upload logs to identify failed uploads.
