$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -Command "Start-Process powershell -ArgumentList ''-NoProfile -Command `"& {w32tm /resync}`"` -WindowStyle Hidden"'
$trigger = New-ScheduledTaskTrigger -AtLogon
$task = New-ScheduledTask -Action $action -Trigger $trigger
$principal = New-ScheduledTaskPrincipal -UserID "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$task.Principal = $principal
Register-ScheduledTask -TaskName "SyncDateTimeTask" -InputObject $task -User "SYSTEM" -TaskPath "\ISL"