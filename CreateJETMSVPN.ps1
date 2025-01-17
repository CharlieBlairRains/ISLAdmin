# Define VPN connection parameters
$vpnConnectionName = "JETMS VPN"
$vpnServerAddress = "h510-wired-phqprzqpzt.dynamic-m.com"
$preSharedKey = 'f3MskMM~x2I*>.@71^'
$authenticationMethod = "PAP"

# Create VPN connection for the current user only
$vpnConnection = Add-VpnConnection -Name $vpnConnectionName -ServerAddress $vpnServerAddress -TunnelType "L2tp" -L2tpPsk $preSharedKey -EncryptionLevel "Optional" -AuthenticationMethod $authenticationMethod -SplitTunneling $true -RememberCredential -PassThru