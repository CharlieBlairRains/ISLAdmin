#define user details
$user = "CFS"
$password = ConvertTo-SecureString "cfs" -AsPlainText -Force
#builds the user
New-LocalUser -Name "$user" -Password $password -FullName "$user"
Add-LocalGroupMember -Group "Administrators" -Member "$user"
Add-LocalGroupMember -Group "Users" -Member "$user"

#logs into powershell as new user

#creates the PSCredential object
$credential = New-Object System.Management.Automation.PSCredential($user, $password)
# Define the script to be executed in the new PowerShell window
$script = {
    #text to test if in right window
    Write-Host "You are now in the new window."

    #define the URL of the file to download and the destination path where the file will be saved and used later in the script
    #$fileUrl = "url_here"
    #$filePath = "filepath_here"
    #$fileName = "filename_here"

    #download the file using Invoke-WebRequest (if you are going to download it to C:\Temp, you can do this before the $script statement)
    #try {
    #Invoke-WebRequest -Uri $fileUrl -OutFile $filePath
    #Write-Host "File downloaded successfully."
    #} 
    #catch {
    #Write-Host "An error occurred while downloading the file."
    #Write-Host "Error message: $($_.Exception.Message)"
    #}

    #start the reg.exe process to import the .reg file
    #try {
    #    Start-Process reg.exe -ArgumentList "import `"$filePath`"" -NoNewWindow -Wait
    #    Write-Host "Registry file imported successfully."
    #} 
    #catch {
    #    Write-Host "An error occurred while importing the registry file."
    #    Write-Host "Error message: $($_.Exception.Message)"
    #}

    function Set-RegistryDWORD {
        param (
            [string]$RegistryPath,
            [string]$DWORDName,
            [int]$DWORDValue
        )
    
        # Check if the registry key exists
        if (-not (Test-Path $RegistryPath)) {
            # Create the registry key if it does not exist
            New-Item -Path $RegistryPath -Force
        }
    
        # Set the DWORD value
        Set-ItemProperty -Path $RegistryPath -Name $DWORDName -Value $DWORDValue -Type DWORD -Force
    
        Write-Output "Registry value '$DWORDName' has been set to $DWORDValue in $RegistryPath"
    }
    
    # Define the registry modifications
    $registryModifications = @(
        @{
            #No pinning on taskbar
            RegistryPath = "HKCU:\Software\Policies\Microsoft\Windows\explorer"
            DWORDName    = "NoPinningToTaskbar"
            DWORDValue   = 1
        },
        @{
            #Remove taskview button
            RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            DWORDName    = "ShowTaskViewButton"
            DWORDValue   = 0
        },
        @{
            #Disable notification centre
            RegistryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
            DWORDName    = "DisableNotificationCenter"
            DWORDValue   = 1
        },
        @{
            #Remove search on taskbar
            RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
            DWORDName    = "SearchboxTaskbarMode"
            DWORDValue   = 0
        },
        @{
            #Remove widgets
            RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            DWORDName    = "TaskbarDA"
            DWORDValue   = 0
        }
    )
    
    # Apply each registry modification
    foreach ($modification in $registryModifications) {
        Set-RegistryDWORD -RegistryPath $modification.RegistryPath -DWORDName $modification.DWORDName -DWORDValue $modification.DWORDValue
    }

    #removes local admin
    Remove-LocalGroupMember -Group "Administrators" -Member "CFS"

    #deletes .reg file
    #$fullPath = Join-Path -Path $filePath -ChildPath $fileName
    #Remove-Item -Path $fullPath -Force

    #restarts the PC
    ##Restart-Computer

}
# Convert the script block to a string
$scriptString = $script.ToString()
# Define the command to start PowerShell as Administrator
$command = "Start-Process powershell.exe -ArgumentList '-NoProfile', '-Command', '$scriptString' -Verb RunAs"

# Start the process with elevated privileges using specified credentials
Start-Process -FilePath powershell.exe -ArgumentList "-NoProfile", "-Command", $command -Credential $credential