function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Error "Please reopen the PowerShell as Administrator and run the script again."
    exit
}

$url = "https://www.python.org/downloads/"
$pageContent = Invoke-WebRequest -Uri $url
$regex = [regex]::new('https:\/\/www\.python\.org\/ftp\/python\/([\d\.]+)\/python-[\d\.]+-amd64\.exe')
$matches = $regex.Matches($pageContent.Content)
if ($matches.Count -gt 0) {
    $latestVersion = $matches[0].Groups[1].Value
    Write-Output "The latest version of Python is $latestVersion"
    $installerUri = "https://www.python.org/ftp/python/$latestVersion/python-$latestVersion-amd64.exe"
    $installerPath = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri $installerUri -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    Remove-Item -Force $installerPath
    $pythonPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python$($latestVersion.Replace('.', ''))"
    [System.Environment]::SetEnvironmentVariable('Path', [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ";$pythonPath;$pythonPath\Scripts", 'Machine')

    Write-Output "Python $latestVersion installed successfully and PATH updated."
} else {
    Write-Output "Could not find the latest version of Python."
}
