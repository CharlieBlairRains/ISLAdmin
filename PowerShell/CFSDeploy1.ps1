# Define the users to exclude from being disabled
#test
$excludedUsers = @("CFS", "isladmin")

# Get all local users
$users = Get-LocalUser

# Loop through each user and disable if not in the excluded list
foreach ($user in $users) {
    if ($excludedUsers -notcontains $user.Name -and $user.Enabled -eq $true) {
        Disable-LocalUser -Name $user.Name
        Write-Output "Disabled user: $($user.Name)"
    } else {
        Write-Output "Skipped user: $($user.Name)"
    }
}
# Define user details
$user = "CFS"
# Check if user already exists
if (-not (Get-LocalUser -Name $user -ErrorAction SilentlyContinue)) {
    # Create the local user
    New-LocalUser -Name $user -NoPassword -FullName $user
    Set-LocalUser -Name $user -PasswordNeverExpires $true
    # Add the user to local groups
    Add-LocalGroupMember -Group "Administrators" -Member $user
    Add-LocalGroupMember -Group "Users" -Member $user
}

function Set-RegistryString {
    param (
        [string]$RegistryPath,
        [string]$ValueName,
        [string]$Value
    )

    # Check if the registry key exists
    if (-not (Test-Path $RegistryPath)) {
        # Create the registry key if it does not exist
        New-Item -Path $RegistryPath -Force
    }

    # Set the string value
    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $Value -Type String -Force

    Write-Output "Registry value '$ValueName' has been set to '$Value' in $RegistryPath"
}

# Set autologin parameters
$autologinSettings = @(
    @{
        RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        ValueName    = "DefaultUserName"
        Value        = "CFS"
    },
    @{
        RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        ValueName    = "DefaultPassword"
        Value        = ""
    },
    @{
        RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        ValueName    = "AutoAdminLogon"
        Value        = "1"
    }
)

# Apply each autologin setting
foreach ($setting in $autologinSettings) {
    Set-RegistryString -RegistryPath $setting.RegistryPath -ValueName $setting.ValueName -Value $setting.Value
}

Write-Output "Auto-login has been configured for user 'CFS'."

#Restart PC
Restart-Computer