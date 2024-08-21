<# 
     .SYNOPSIS 
         This script silently installs ExpressCluster and opens ports in the firewall for Cluster 5.2
#>

# Note: Copy license files and ExpressCluster installation zip file ahead of time to the temp folder if manually running this script
# Syntax: install-ecx.ps1 <ECX zip file> <temp folder>
# The parameters will default to presets if not indicated

Param (
	[string]$ECX_zip = $null,
        [string]$path_temp = $null
)

# Variables
If ($ECX_zip -eq ""){
  $ECX_zip = "ecx52w_x64.zip"
}
If ($path_temp -eq ""){
  $path_temp = "c:\temp-ecx"
}
$path_install = "$path_temp\install"
$path_bin = "C:\Program Files\EXPRESSCLUSTER\bin"
$ECX_URL = "https://www.nec.com/en/global/prod/expresscluster/en/trial/zip/$ECX_zip"
#Windows 2016 fails with TLS error on Invoke-WebRequest, so need local file
#$ECX_URL = "C:\$ECX_zip"
$logfile = "Install_Log.txt"
$ECXinstalllog = "ECXLog.txt"
$Base_lic = "X5x_Base.key"
$Repl_lic = "X5x_REPL.key"
$Alert_lic = "X5x_ALRT.key"

# Create Folders 
If (!(Test-Path $path_temp)){
  New-Item -ItemType Directory $path_temp | Out-Null
}
If (!(Test-Path $path_install)){
  New-Item -ItemType Directory $path_install | Out-Null
  If ($?){
    Write-Output "Directory $path_install created successfully" | Out-File -FilePath "$path_temp\$logfile"
  }
  Else{
    Write-Output "Unable to create $path_install. Aborting script." | Out-File -FilePath "$path_temp\$logfile"
    Write-Output "Error occurred. View $path_temp\$logfile for details."
    Exit 1
  }
}

# | Out-Null
#  Out-File -FilePath "$path_temp\$logfile"

# Download ExpressCluster 
try {
  Invoke-WebRequest -URI $ECX_URL -OutFile $path_temp\ECX.zip 
  If ($?){
    Write-Output "EXPRESSCLUSTER installation file downloaded successfully." | Out-File -FilePath "$path_temp\$logfile" -Append
  }
}
catch {
    Write-Output "Error downloading EXPRESSCLUSTER installation zip file. Aborting script." | Out-File -FilePath "$path_temp\$logfile" -Append
    Write-Output "Error occurred. View $path_temp\$logfile for details."
    Exit 1
}

try {
  Expand-Archive $path_temp\ECX.zip $path_install
  If ($?){
    Write-Output "Installation files unzipped successfully." | Out-File -FilePath "$path_temp\$logfile" -Append
  }
}
catch {
    Write-Output "Error unpacking zip file. Aborting script." | Out-File -FilePath "$path_temp\$logfile" -Append
    Write-Output "Error occurred. View $path_temp\$logfile for details."
    Exit 1
}

# Find location of ECX silent-install.bat
$path_exe = Get-ChildItem -Path $path_install -Filter silent-install.bat -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -ExpandProperty DirectoryName
If ($path_exe -eq $null){
  Write-Output "Silent install batch file not found. Aborting script." | Out-File -FilePath "$path_temp\$logfile" -Append
  Write-Output "Error occurred. View $path_temp\$logfile for details."
  Exit 1
}

# Change to directory of silent-install.bat
Set-Location -Path $path_exe
Write-Output "Current directory is: $(Get-Location)" | Out-File -FilePath "$path_temp\$logfile" -Append

# Install ECX
Write-Output "Installing EXPRESSCLUSTER." | Out-File -FilePath "$path_temp\$logfile" -Append
     #Start-Process "silent-install.bat" -Wait | Out-File -FilePath "$path_temp\$logfile" -Append
Start-Process ".\silent-install.bat" -RedirectStandardOutput "$path_temp\$ECXinstalllog" -Wait -WindowStyle Hidden
# Write silent-install.bat output from temp file to main log file
# Note that redirecting the batch file output to the main log file will overwrite the contents. There doesn't seem to be a way to append it.
Get-Content "$path_temp\$ECXinstalllog" | Out-File -FilePath "$path_temp\$logfile" -Append
# Abort script if installation failed
If ((Get-Content "$path_temp\$ECXinstalllog" | Select-String -Pattern 'failed' -Quiet) -eq 'True') {
  Write-Output "EXPRESSCLUSTER installation failed. Aborting script." | Out-File -FilePath "$path_temp\$logfile" -Append
  Write-Output "Error occurred. View $path_temp\$logfile for details."
  Exit 1
}

#$PRODUCTNAME = (Get-Service clpstartup).DisplayName
$DISP_PRODUCTNAME = Get-Service clpstartup | Select-Object Displayname
$PRODUCTNAME = $DISP_PRODUCTNAME.DisplayName

Write-Output "Opening EXPRESSCLUSTER ports through firewall." | Out-File -FilePath "$path_temp\$logfile" -Append

# Firewall 
 # Server to Server
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Internal Communication" dir=in protocol=TCP localport=29001 action=allow *> $null
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Data Forwarding" dir=in protocol=TCP localport=29002 action=allow *> $null
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Alert Synchronization" dir=in protocol=UDP localport=29003 action=allow *> $null
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Disk Agents Communication" dir=in protocol=TCP localport=29004 action=allow *> $null
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Mirror Drivers Communication" dir=in protocol=TCP localport=29005 action=allow *> $null
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Information Base Communication" dir=in protocol=TCP localport=29008 action=allow *> $null
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Restful API Communication" dir=in protocol=TCP localport=29010 action=allow *> $null
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Heartbeat" dir=in protocol=UDP localport=29106 action=allow *> $null

 # Client to Server
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER Restful API Client Communication" dir=in protocol=TCP localport=29009 action=allow *> $null

 # Cluster WebUI to Server
# netsh advfirewall firewall add rule name="EXPRESSCLUSTER HTTP Connection" dir=in protocol=TCP localport=29003 action=allow *> $null

  Set-Location -Path $path_bin
  Write-Output "Current directory is: $(Get-Location)" | Out-File -FilePath "$path_temp\$logfile" -Append

  #Register license files
  #Start-Process -FilePath .\clplcnsc.exe -ArgumentList "-i C:\*.key" -Wait
   Start-Process -FilePath .\clplcnsc.exe -ArgumentList "-i $path_temp\*.key" -Wait

  #Open ports
  Start-Process -FilePath .\clpfwctrl.bat -ArgumentList "--add" -Wait

  # Check license registration
  $Licenses = .\clplcnsc.exe -l
  Write-Output "Licenses registered:" | Out-File -FilePath "$path_temp\$logfile" -Append 
  Write-Output $Licenses | Select-String -Pattern "cluster" | Out-File -FilePath "$path_temp\$logfile" -Append

 # Check status of ECX ports
 $Ports = Get-NetFirewallRule -DisplayName $PRODUCTNAME* | Format-Table -AutoSize -Property DisplayName,
 @{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
 @{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
 Enabled

Write-Output $Ports | Out-File -FilePath "$path_temp\$logfile" -Append
If ($Ports -eq $null){
    Write-Output "Error occurred opening ports. View $path_temp\$logfile for details." | Out-File -FilePath "$path_temp\$logfile" -Append
}

Write-Output "Script complete." | Out-File -FilePath "$path_temp\$logfile" -Append
Write-Output "ExpressCluster installation and configuration script complete."

#Clean up needs to be performed outside of this script, but only if there is no need to troubleshoot problems
#Remove-Item -Path $path_temp -Recurse -Force

# Restart Computer
# $confirmation = Read-Host "Script complete. Reboot computer [y/n]?"
# If ($confirmation -eq 'y') {
    # proceed
#    Write-Output "Rebooting computer." | Out-File -FilePath "$path_temp\$logfile" -Append
#    Restart-Computer
# }
# Else{
#    Write-Output "Reboot aborted." | Out-File -FilePath "$path_temp\$logfile" -Append
# }
