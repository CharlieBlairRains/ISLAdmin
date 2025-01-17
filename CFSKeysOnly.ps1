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
        },
        @{
            #Disable start button left click
            RegistryPath = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
            DWORDName = "DisableCAD"
            DWORDValue = 1
        }
    )

    # Apply each registry modification
    foreach ($modification in $registryModifications) {
        Set-RegistryDWORD -RegistryPath $modification.RegistryPath -DWORDName $modification.DWORDName -DWORDValue $modification.DWORDValue
    }

    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Force -Recurse -ErrorAction SilentlyContinue

    # Remove local admin
    Remove-LocalGroupMember -Group "Administrators" -Member "CFS"

    #Restart the PC
    #Restart-Computer

    #Disable Administrator