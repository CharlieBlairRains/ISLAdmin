#Create User Details
$user = "isladmin"
$password = ConvertTo-SecureString "umgiG@_bEGXJCBmDa7y!)" -AsPlainText -Force
# Attempt to find the user
$objUser = Get-LocalUser $user -ErrorAction SilentlyContinue  # Try to get the user silently

if (-not $objUser) {
    # If the user was not found, handle it here
    Write-Warning "$User $($user) was not found"
    New-LocalUser -Name "$user" -Password $password -FullName "$user" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member "$user"
    Add-LocalGroupMember -Group "Users" -Member "$user"
}
else {
    # If the user is found
    # Set password to never expire
    Set-LocalUser -Name "$user" -Password $password -FullName "$user" -PasswordNeverExpires $true -AccountNeverExpires
    }


