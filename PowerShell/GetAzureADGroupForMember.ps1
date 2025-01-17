# Install AzureAD module if not already installed
if (-not (Get-Module -Name "AzureAD" -ErrorAction SilentlyContinue)) {
    Install-Module -Name "AzureAD" -Scope CurrentUser -Force
}
#Connect to Azure AD
#Connect-AzureAD
#Get Azure AD groups YOU CAN CHANGE WHAT GROUPS YOU WANT HERE

Get-AzureADUser -SearchString james.gardner@johncullenlighting.com | 
Get-AzureADUserMembership | 
% {Get-AzureADObjectByObjectId -ObjectId $_.ObjectId | 
select DisplayName,ObjectType,MailEnabled,SecurityEnabled,ObjectId} | ft