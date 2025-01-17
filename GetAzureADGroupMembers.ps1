# Install AzureAD module if not already installed
if (-not (Get-Module -Name "AzureAD" -ErrorAction SilentlyContinue)) {
    Install-Module -Name "AzureAD" -Scope CurrentUser -Force
}
#Connect to Azure AD
Connect-AzureAD
#Get Azure AD groups YOU CAN CHANGE WHAT GROUPS YOU WANT HERE
$groups = Get-AzureADGroup -Filter "DisplayName eq 'All Users'"

# Iterate through each group
foreach ($group in $groups) {
    # Get all users for the current group using -All to get more than the default 100 users
    $users = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true | Where-Object { $_.ObjectType -eq "User" }

    # Create an array to store user data for this group
    $usersData = @()

    # Iterate through each user in the group
    foreach ($user in $users) {
        # Get license information for the user
        $licenseInfo = Get-AzureADUserLicenseDetail -ObjectId $user.ObjectId | Select-Object -ExpandProperty SkuPartNumber | Sort-Object
        # Replace "SPB" with "Microsoft 365 Business Premium"
        $licenseInfo = $licenseInfo -replace 'SPB', 'Microsoft 365 Business Premium'
        # Replace "DYN365_BUSCENTRAL_ESSENTIAL2" with "Dynamics 365 Business Central Essentials"
        $licenseInfo = $licenseInfo -replace 'DYN365_BUSCENTRAL_ESSENTIAL', 'Dynamics 365 Business Central Essentials'
        # Replace "INTUNE_A_D" with "Microsoft Intune Plan 1 Device"
        $licenseInfo = $licenseInfo -replace 'INTUNE_A_D', 'Microsoft Intune Plan 1 Device'
        # Replace "EXCHANGESTANDARD" with "Exchange Online (Plan 1)"
        $licenseInfo = $licenseInfo -replace 'EXCHANGESTANDARD', 'Exchange Online (Plan 1)'
        # Replace "EXCHANGEENTERPRISE" with "Exchange Online (Plan 2)"
        $licenseInfo = $licenseInfo -replace 'EXCHANGEENTERPRISE', 'Exchange Online (Plan 2)'
        # Replace "Microsoft_Teams_Exploratory_Dept" with "Microsoft Teams Exploratory"
        $licenseInfo = $licenseInfo -replace 'Microsoft_Teams_Exploratory_Dept', 'Microsoft Teams Exploratory'
        # Replace "FLOW_FREE" with ""
        $licenseInfo = $licenseInfo -replace 'FLOW_FREE', ''
        # Filter and keep only licenses that match the specified ones
        $licenseInfo = $licenseInfo | Where-Object {$_ -eq 'Microsoft 365 Business Premium' -or $_ -eq 'Dynamics 365 Business Central Essentials'}

        #if ($licenseInfo){
            $userData = [PSCustomObject]@{
            "GroupName" = $group.DisplayName
            "UserDisplayName" = $user.DisplayName
            "UserEmail" = $user.Mail
            "License" = $licenseInfo -join ', '  # Combine license information into a comma-separated string
        }
        # Add user data to the array
        $usersData += $userData
        #}
        # Extract user data
        
    }

    # Generate CSV file name based on the group name
    $csvFileName = $group.DisplayName -replace "[^\w\s]", "" -replace "\s+", "_" -replace "_+", "_"
    $csvFileName += "_VolCG.csv"

    # Export user data to CSV file to your filepath
    $filePath = "C:\Users\CharlieBlairRains\Documents\$csvFileName"
    $usersData | Export-Csv -Path $filePath -NoTypeInformation
}