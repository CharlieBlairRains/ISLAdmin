# Define IP range
$ipRange = "192.168.45.1-254"  # Change this to your IP range
 
# Define Windows client OS version
$windowsClientOsVersions = @(
    "Windows 10",
    "Windows 8",
    "Windows 7"
)
 
# Define if Remote Desktop is enabled
function IsRdpEnabled {
    param([string]$computerName)
    $rdpEnabled = (Get-WmiObject -Class "Win32_TerminalServiceSetting" -Namespace root\cimv2\terminalservices -ComputerName $computerName -ErrorAction SilentlyContinue).AllowTSConnections
    return $rdpEnabled
}
 
# Define if it's a Windows Server OS
function IsWindowsServer {
    param([string]$computerName)
    $osVersion = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName -ErrorAction SilentlyContinue).Caption
    return $osVersion -match "Windows Server"
}
 
# Iterate over each IP in the range
$reachableComputers = @()
1..254 | ForEach-Object {
    $ip = "192.168.1.$_"
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        $computerName = (Test-Connection -ComputerName $ip -Count 1).IPV4Address.IPAddressToString
        $reachableComputers += $computerName
    }
}
 
# Iterate over reachable computers
foreach ($computer in $reachableComputers) {
    if (-not (IsWindowsServer -computerName $computer)) {
        if (-not (IsRdpEnabled -computerName $computer)) {
            Write-Output "Enabling Remote Desktop on $computer..."
            Invoke-Command -ComputerName $computer -ScriptBlock {
                Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Force
                Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
            } -Credential (Get-Credential) -ErrorAction SilentlyContinue
            Write-Output "Remote Desktop has been enabled on $computer."
        } else {
            Write-Output "Remote Desktop is already enabled on $computer."
        }
    } else {
        Write-Output "Remote Desktop is not enabled on $computer as it is a Windows Server OS."
    }
}