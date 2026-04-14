$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notmatch "C:\\src\\git\\cmd") { $userPath += ";C:\src\git\cmd;C:\src\git\bin" }
if ($userPath -notmatch "C:\\src\\flutter\\bin") { $userPath += ";C:\src\flutter\bin" }
[Environment]::SetEnvironmentVariable("Path", $userPath, "User")
Write-Host "PATH updated successfully!"
