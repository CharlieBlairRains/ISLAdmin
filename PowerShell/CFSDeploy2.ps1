$checkUser = $env:USERNAME

if ($checkUser -eq "CFS"){

function Set-RegistryDWORD {
    param (
        [string]$RegistryPath,
        [string]$DWORDName,
        [object]$DWORDValue
    )

    # Check if the registry key exists
    if (-not (Test-Path $RegistryPath)) {
        # Create the registry key if it does not exist
        New-Item -Path $RegistryPath -Force
    }

    # Convert DWORDValue to integer if it's a hexadecimal string
    if ($DWORDValue -is [string] -and $DWORDValue -match '^0x[0-9A-Fa-f]+$') {
        $DWORDValue = [convert]::ToInt32($DWORDValue, 16)
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
    },
    @{
        #disable control panel
        RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        DWORDName    = "nocontrolpanel"
        DWORDValue   = 1
    },
    @{
        #disable task manager
        RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\system"
        DWORDName    = "disabletaskmgr"
        DWORDValue   = 1
    },
    @{
        #hide drive letters
        RegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        DWORDName    = "nodrives"
        DWORDValue   = 0x03ffffff
    },
    @{
        #disable copilot
        RegistryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
        DWORDName    = "turnoffwindowscopilot"
        DWORDValue   = 1
    },
    @{
        #Start menu adjustmants
        RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        DWORDName    = "nostartmenumoreprograms"
        DWORDValue   = 1
    },
    @{
        #disable key shortcuts
        RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies"
        DWORDName    = "NoWinKeys"
        DWORDValue   = 1
    },
    @{
        #disable start searchbar
        RegistryPath = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch"
        DWORDName    = "value"
        DWORDValue   = 1
    },
    @{
        #right click context menu removal
        RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        DWORDName    = "NoTrayContextMenu"
        DWORDValue   = 1
    },
    @{
        #remove all apps icon
        RegistryPath = "HKCU:\SOFTWARE\Microsoft\ Windows\CurrentVersion\Policies\Explorer"
        DWORDName    = "NoStartMenuMorePrograms"
        DWORDValue   = 1
    },
    @{
        #Disable Context Menu
        RegistryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\"
        DWORDName    = "DisableContextMenuInStart"
        DWORDValue   = 1
    },
    @{
        #Disable current context menu
        RegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"
        DWORDName    = "ShellFeedsTaskbarViewMode"
        DWORDValue   = 2
    }
)

# Apply each registry modification
foreach ($modification in $registryModifications) {
    Set-RegistryDWORD -RegistryPath $modification.RegistryPath -DWORDName $modification.DWORDName -DWORDValue $modification.DWORDValue
}

#Remove taskband
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Force -Recurse -ErrorAction SilentlyContinue

#Disable start menu options
$FileExplorerAndSettings = "02,00,00,00,d4,ca,e9,80,d4,bb,d4,01,00,00,00,00,43,42,01,00,c2,3c,01,c2,46,01,c5,5a,01,00"
$Key = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.unifiedtile.startglobalproperties\Current"
$BinaryData = [byte[]](($FileExplorerAndSettings.Split(',')) | % { "0x$_" })
Set-ItemProperty -Path $Key.PSPath -Name "Data" -Type Binary -Value $BinaryData

#Delete WinX items
$foldersToDelete = @(
    "C:\Users\CFS\AppData\Local\Microsoft\Windows\WinX\Group1",
    "C:\Users\CFS\AppData\Local\Microsoft\Windows\WinX\Group2",
    "C:\Users\CFS\AppData\Local\Microsoft\Windows\WinX\Group3"
)

# Loop through each folder path and delete it
foreach ($folder in $foldersToDelete) {
# Check if the folder exists before attempting to delete
    if (Test-Path $folder -PathType Container) {
        # Delete the folder and all its contents recursively
        Remove-Item -Path $folder -Recurse -Force
        Write-Output "Deleted folder: $folder"
    } else {
        Write-Output "Folder does not exist: $folder"
    }
}

#hide recycle bin
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$RecycleBinValue = "{645FF040-5081-101B-9F08-00AA002F954E}"
Set-ItemProperty -Path $RegistryPath -Name $RecycleBinValue -Value 1

#remove desktop items
$desktopPath = "C:\Users\CFS\Desktop"
Get-ChildItem -Path $DesktopPath -File -Recurse | Remove-Item -Force
Get-ChildItem -Path $DesktopPath -Directory -Recurse | Remove-Item -Force -Recurse

function pinnedMenu {
    $START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

$layoutFile="C:\Windows\StartMenuLayout.xml"

#Delete layout file if it already exists
If(Test-Path $layoutFile)
{
    Remove-Item $layoutFile
}

#Creates the blank layout file
$START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

$regAliases = @("HKLM", "HKCU")

#Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer"
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
}

#Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
Stop-Process -name explorer
Start-Sleep -s 5
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
Start-Sleep -s 5

#Enable the ability to pin items again by disabling "LockedStartLayout"
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}

#Restart Explorer and delete the layout file
Stop-Process -name explorer

# Uncomment the next line to make clean start menu default for all new users
#Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

Remove-Item $layoutFile
}

pinnedMenu

#remove windows search
cd $env:windir\SystemApps
taskkill /f /im SearchApp.exe
move Microsoft.Windows.Search_cw5n1h2txyewy Microsoft.Windows.Search_cw5n1h2txyewy.old

# Remove local admin
Remove-LocalGroupMember -Group "Administrators" -Member "CFS"

#Restart the PC
Restart-Computer
}