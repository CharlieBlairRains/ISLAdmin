# Ensure you're logged in to Microsoft 365 with appropriate permissions
Connect-MgGraph -DeviceCode

# Prompt for source user details
$sourceFirstName = Read-Host -Prompt "Enter the user's first name you'd like to copy"
$sourceLastName = Read-Host -Prompt "Enter the user's last name you'd like to copy"

# Find the source user by first name and last name
$sourceUser = Get-MgUser -All | Where-Object { $_.GivenName -eq $sourceFirstName -and $_.Surname -eq $sourceLastName }

# Check if the source user was found
if (!$sourceUser) {
    Write-Output "No user found with the first name '$sourceFirstName' and last name '$sourceLastName'. Exiting Script."
    return
}

# Prompt for new user details
$newFirstName = Read-Host -Prompt "Enter the new user's first name"
$newLastName = Read-Host -Prompt "Enter the new user's last name"
$newPassword = Read-Host -Prompt "Enter the new user's password"

# Generate the UPN for the new user
$newUserPrincipalName = "$($newFirstName).$($newLastName)@inter-test.co.uk"

# Check if a user with that UPN already exists
$newUserCheck = Get-MgUser -All | Where-Object { $_.UserPrincipalName -eq $newUserPrincipalName }
if ($newUserCheck) {
    Write-Output "A user with the UPN '$newUserPrincipalName' already exists: $($newUserCheck.DisplayName) ($newUserCheck.UserPrincipalName). Exiting script."
    return
}

# Get all groups the source user is a member of
$groups = Get-MgUserMemberOf -UserId $sourceUser.Id

# Create the new user data
$params = @{
    displayName = "$newFirstName $newLastName"
    GivenName = $newFirstName
    Surname = $newLastName
    PasswordProfile = @{Password = $newPassword}
    UserPrincipalName = $newUserPrincipalName
    mailNickname = "test"
    AccountEnabled = $true
}

# Build the new user with the data
New-MgUser -BodyParameter $params

# Get the details of the newly created user
$newUser = Get-MgUser -All | Where-Object { $_.UserPrincipalName -eq $newUserPrincipalName }

# Add the new user to each of the source user's groups
foreach ($group in $groups) {
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $newUser.Id
}

# Get the licenses assigned to the source user and apply them to the new user
$licenses = Get-MgUserLicenseDetail -UserId $sourceUser.Id
foreach ($license in $licenses) {
    Set-MgUserLicense -UserId $newUser.Id -AddLicenses $license.SkuId
}

Write-Output "New user $newUserPrincipalName has been created, added to the same groups, and assigned the same licenses as $sourceUserPrincipalName."