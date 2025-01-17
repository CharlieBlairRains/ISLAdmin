# Run the net localgroup Administrators command and capture its output
$administratorsOutput = net localgroup Administrators

# Extract the member names from the output
$administrators = ($administratorsOutput -split "`r`n" | Select-Object -Skip 6 | Where-Object { $_ -and $_ -notmatch 'The command completed successfully.' })

# Loop through the list and disable users who are not named "isladmin" or have "Domain Admins" in the name.
foreach ($user in $administrators) {
    $user = $user.Trim()
    if ($user -ne "isladmin") {
        Write-Host "Disabling user $user..."
        Disable-LocalUser -Name $user
        Write-Host "User $user has been disabled."
    }
}