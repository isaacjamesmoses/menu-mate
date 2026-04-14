$ErrorActionPreference = "Stop"

$ANDROID_HOME = "C:\src\android-sdk"
$CMDLINE_TOOLS_URL = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$CMDLINE_ZIP = "C:\src\cmdline-tools.zip"

Write-Host "=== Phase 2: Android SDK Setup ==="

# Create directory
New-Item -ItemType Directory -Force -Path "$ANDROID_HOME\cmdline-tools" | Out-Null

# Download command-line tools with retry logic
Write-Host "[1/5] Downloading Android command-line tools..."
$MaxRetries = 3
$RetryCount = 0
$Success = $false

while (-not $Success -and $RetryCount -lt $MaxRetries) {
    try {
        Invoke-WebRequest -Uri $CMDLINE_TOOLS_URL -OutFile $CMDLINE_ZIP
        $Success = $true
    } catch {
        $RetryCount++
        Write-Host "Download failed. Retry $RetryCount of $MaxRetries..."
        Start-Sleep -Seconds 5
    }
}

if (-not $Success) { throw "Failed to download Android command-line tools after $MaxRetries attempts." }

# Extract
Write-Host "[2/5] Extracting command-line tools..."
Expand-Archive -Path $CMDLINE_ZIP -DestinationPath "$ANDROID_HOME\cmdline-tools" -Force
# Rename to 'latest' as required by sdkmanager
if (Test-Path "$ANDROID_HOME\cmdline-tools\latest") {
    Remove-Item "$ANDROID_HOME\cmdline-tools\latest" -Recurse -Force
}
Rename-Item "$ANDROID_HOME\cmdline-tools\cmdline-tools" "$ANDROID_HOME\cmdline-tools\latest"
Remove-Item $CMDLINE_ZIP -Force

# Set environment variables
Write-Host "[3/5] Configuring environment..."
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $ANDROID_HOME, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $ANDROID_HOME, "User")
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$sdkPaths = "$ANDROID_HOME\cmdline-tools\latest\bin;$ANDROID_HOME\platform-tools"
if ($userPath -notmatch "android-sdk") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$sdkPaths", "User")
}

$env:ANDROID_HOME = $ANDROID_HOME
$env:ANDROID_SDK_ROOT = $ANDROID_HOME
$env:Path = "$ANDROID_HOME\cmdline-tools\latest\bin;$ANDROID_HOME\platform-tools;$env:Path"

# Install SDK components
Write-Host "[4/5] Installing Android SDK platform and build tools..."
Write-Host "y" | & "$ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --install "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Accept licenses non-interactively  
Write-Host "[5/5] Accepting Android licenses..."
$yeses = "y`ny`ny`ny`ny`ny`ny`ny`ny`ny`n"
$yeses | & "$ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --licenses

Write-Host "=== Android SDK setup complete! ==="
