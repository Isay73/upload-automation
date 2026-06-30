# ================================
# Recorder Upload Script
# Edit only these settings per PC
# ================================

$SourceFolder = "C:\Users\pc\Desktop\WA"

$NextcloudUser = "upload-bot"
$NextcloudPassword = "Password"

# Example:
# "user/1/001"
# "user/1/002"
$RemoteFolder = "user/1/001"

$BaseUrl = "https://your-domain.example/remote.php/dav/files/$NextcloudUser"
$WorkDir = "C:\RecorderUpload"
$LogFile = "$WorkDir\upload.log"

if (!(Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
}

function Write-Log($msg) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg"
    $old = @()
    if (Test-Path $LogFile) {
        $old = Get-Content $LogFile -Tail 99 -ErrorAction SilentlyContinue
    }
    @($old + $line) | Set-Content $LogFile -Encoding UTF8
}

function Get-AuthHeader {
    $pair = "$($NextcloudUser):$($NextcloudPassword)"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
    $base64 = [Convert]::ToBase64String($bytes)
    return "Basic $base64"
}

function Test-FileUnlocked($path) {
    try {
        $stream = [System.IO.File]::Open($path, 'Open', 'ReadWrite', 'None')
        $stream.Close()
        return $true
    } catch {
        return $false
    }
}

function Invoke-MKCOL($url, $label) {
    try {
        $req = [System.Net.WebRequest]::Create($url)
        $req.Method = "MKCOL"
        $req.Headers.Add("Authorization", (Get-AuthHeader))
        $res = $req.GetResponse()
        $res.Close()
        Write-Log "MKCOL OK $label"
        return $true
    } catch {
        $code = $null
        if ($_.Exception.Response) {
            $code = $_.Exception.Response.StatusCode.value__
        }

        if ($code -eq 405) {
            Write-Log "MKCOL EXISTS $label"
            return $true
        }

        Write-Log "MKCOL FAILED $label $($_.Exception.Message)"
        return $false
    }
}

function Ensure-RemoteFolder($folder) {
    $parts = $folder -split "/"
    $current = ""

    foreach ($part in $parts) {
        if ([string]::IsNullOrWhiteSpace($part)) { continue }

        if ($current -eq "") {
            $current = [uri]::EscapeDataString($part)
        } else {
            $current = "$current/$([uri]::EscapeDataString($part))"
        }

        $url = "$BaseUrl/$current"
        Invoke-MKCOL $url $current | Out-Null
    }
}

function Remote-Exists($url) {
    try {
        Invoke-WebRequest `
            -Uri $url `
            -Method Head `
            -Headers @{ Authorization = (Get-AuthHeader) } `
            -UseBasicParsing `
            -TimeoutSec 60 | Out-Null

        return $true
    } catch {
        $code = $null
        if ($_.Exception.Response) {
            $code = $_.Exception.Response.StatusCode.value__
        }

        if ($code -eq 404) { return $false }

        Write-Log "REMOTE CHECK ERROR $($_.Exception.Message)"
        return $false
    }
}

Write-Log "SCRIPT START"
Write-Log "SOURCE $SourceFolder"
Write-Log "REMOTE $RemoteFolder"

Ensure-RemoteFolder $RemoteFolder
Write-Log "REMOTE READY $RemoteFolder"

while ($true) {
    try {
        if (!(Test-Path $SourceFolder)) {
            Write-Log "SOURCE NOT FOUND $SourceFolder"
            Start-Sleep -Seconds 10
            continue
        }

        $files = Get-ChildItem $SourceFolder -Filter *.mp3 -File -Recurse -ErrorAction SilentlyContinue

        foreach ($item in $files) {
            $file = $item.FullName
            $name = $item.Name

            if (!(Test-Path $file)) { continue }

            if (!(Test-FileUnlocked $file)) {
                Write-Log "WAIT LOCKED $name"
                continue
            }

            $safeFolder = ($RemoteFolder -split "/" | ForEach-Object { [uri]::EscapeDataString($_) }) -join "/"
            $safeName = [uri]::EscapeDataString($name)
            $url = "$BaseUrl/$safeFolder/$safeName"

            if (Remote-Exists $url) {
                Write-Log "REMOTE EXISTS $name"
                Remove-Item $file -Force
                Write-Log "LOCAL DELETE OK $name"
                continue
            }

            try {
                Write-Log "UPLOAD START $name"

                Invoke-WebRequest `
                    -Uri $url `
                    -Method Put `
                    -Headers @{ Authorization = (Get-AuthHeader) } `
                    -InFile $file `
                    -UseBasicParsing `
                    -TimeoutSec 3600 | Out-Null

                Start-Sleep -Seconds 2

                if (Remote-Exists $url) {
                    Write-Log "UPLOAD VERIFIED $name"
                    Remove-Item $file -Force
                    Write-Log "LOCAL DELETE OK $name"
                } else {
                    Write-Log "UPLOAD NOT VERIFIED $name LOCAL NOT DELETED"
                }
            } catch {
                Write-Log "UPLOAD FAILED $name $($_.Exception.Message)"
            }
        }
    } catch {
        Write-Log "LOOP ERROR $($_.Exception.Message)"
    }

    Start-Sleep -Seconds 10
}
