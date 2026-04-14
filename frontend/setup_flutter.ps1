$ErrorActionPreference = "Stop"

# Kill hanging installers to free UI
Get-Process | Where-Object { $_.Name -match "winget|Git" } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Creating C:\src environment..."
New-Item -ItemType Directory -Force -Path C:\src | Out-Null

Write-Host "Downloading Portable Git..."
$gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/PortableGit-2.44.0-64-bit.7z.exe"
Invoke-WebRequest -Uri $gitUrl -OutFile "C:\src\PortableGit.exe"

Write-Host "Extracting Portable Git without Admin prompts..."
Start-Process -FilePath "C:\src\PortableGit.exe" -ArgumentList "-y", "-o`"C:\src\git`"" -Wait -NoNewWindow
# Clean up installer
Remove-Item "C:\src\PortableGit.exe" -Force

Write-Host "Downloading Flutter SDK..."
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip"
Invoke-WebRequest -Uri $flutterUrl -OutFile "C:\src\flutter.zip"

Write-Host "Extracting Flutter SDK (this may take a few minutes)..."
Expand-Archive -Path "C:\src\flutter.zip" -DestinationPath "C:\src" -Force
Remove-Item "C:\src\flutter.zip" -Force

Write-Host "Configuring Local System PATH..."
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notmatch "C:\\src\\git\\cmd") { $userPath += ";C:\src\git\cmd;C:\src\git\bin" }
if ($userPath -notmatch "C:\\src\\flutter\\bin") { $userPath += ";C:\src\flutter\bin" }
[Environment]::SetEnvironmentVariable("Path", $userPath, "User")

Write-Host "Setup Completed successfully!"
