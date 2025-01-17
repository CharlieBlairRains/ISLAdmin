if (Test-Path "$env:CommonProgramFiles\microsoft shared\ClickToRun\OfficeC2RClient.exe") {
    $ErrorActionPreference = 'silentlycontinue'
    # Update logic
    if ((Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Configuration).CDNBaseUrl -ne "http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114") {
        Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Configuration -Name CDNBaseUrl -Value "http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114"
        Remove-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Updates -Name UpdateToVersion
        Write-Host "Logic Updated."
    }
    # Update to the latest build
    & "$env:CommonProgramFiles\microsoft shared\ClickToRun\OfficeC2RClient.exe" /update user
    Write-Host "Office 365 Updated." 
    # Enable updates
    Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Configuration -Name UpdatesEnabled -Value "True"
    Write-Host "Updates Enabled."
} else {
    Write-Host "Please verify Office 365 is installed correctly. Can't find '$env:CommonProgramFiles\microsoft shared\ClickToRun\OfficeC2RClient.exe'" -ForegroundColor Yellow
}