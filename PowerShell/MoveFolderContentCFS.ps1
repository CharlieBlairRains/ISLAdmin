#wrap it as a script
$script = {
#Create Global Variables
$RealPCName = hostname.exe
$OTEDestination = "z:\OTE"
$ATEDestination = "z:\ATE"
$PDFDestination = "z:\PDF"
function folderTransfer{
    #Load paramaters
    param (
        [string]$PCName,
        [string]$OTESource,
        [string]$ATESource,
        [string]$PDFSource
    )
    #
    # Move files from $OTESource to $OTEDestination
    try {
        Get-ChildItem -Path $OTESource -Recurse -File | Move-Item -Destination $OTEDestination -ErrorAction Stop
        Write-Host "Files moved successfully from $OTESource to $OTEDestination."
    } catch {
        Write-Host "Error moving files from $OTESource to $OTEDestination :$_"
    }

    # Move files from $ATESource to $ATEDestination
    try {
        Get-ChildItem -Path $ATESource -Recurse -File | Move-Item -Destination $ATEDestination -ErrorAction Stop
        Write-Host "Files moved successfully from $ATESource to $ATEDestination."
    } catch {
        Write-Host "Error moving files from $ATESource to $ATEDestination :$_"
    }

    # Move files from $PDFSource to $PDFDestination
    try {
        Get-ChildItem -Path $PDFSource -Recurse -File | Move-Item -Destination $PDFDestination -ErrorAction Stop
        Write-Host "Files moved successfully from $PDFSource to $PDFDestination."
    } catch {
        Write-Host "Error moving files from $PDFSource to $PDFDestination :$_"
    }
}
#Create File Location Objects
$fileLocations = @(
    @{
        PCName = "Nidek"
        OTESource = "c:\users\public\desktop\Zyoptix Landing\OTE"
        ATESource = "c:\users\public\desktop\Zyoptix Landing\ATE"
        PDFSource = "c:\users\public\desktop\Zyoptix Landing\PDF"
    },
    @{
        PCName = "PENTACAMCAPTURE"
        OTESource = "C:\Users\Oculus\Desktop\ZYOPTIX LANDING\OTE"
        ATESource = "C:\Users\Oculus\Desktop\ZYOPTIX LANDING\ATE"
        PDFSource = "C:\Users\Oculus\Desktop\ZYOPTIX LANDING\PDF"
    },
    @{
        PCName = "CFSQAS02"
        OTESource = "c:\users\public\desktop\ZYOPTIX LANDING\OTE"
        ATESource = "c:\users\public\desktop\ZYOPTIX LANDING\ATE"
        PDFSource = "c:\users\public\desktop\ZYOPTIX LANDING\PDF"
    }
)
#Run the function for each Object and find which PC this is on and then run the command based on what is received
foreach ($i in $fileLocations) {
    if ($i.PCName -eq $RealPCName){
        folderTransfer -PCName $i.PCName -OTESource $i.OTESource -ATESource $i.ATESource -PDFSource $i.PDFSource
    }
    else {
        Write-Output ($i.PCName + " did not match")
    }
}
}
#Convert the script
$encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script.ToString()))
# Choose which script to run and how
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -EncodedCommand $encodedScript"
# Choose when you want it to run (every 5 minutes) starting at 12:00 PM
$taskTrigger = New-ScheduledTaskTrigger -Once -At "12:00PM" -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 10000)
# Choose what user you want to run it as
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
# Define the task name and folder
$taskName = "FileTransfer"
$taskPath = "\ISL\" 
# Create the scheduled task with the variables created
Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal