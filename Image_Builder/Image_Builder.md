==Under Construction==

# Azure VM Image Builder\Image Templates
Azure Image templates create a pipeline that fully automates the building of a custom VM image with ExpressCluster installed. The image can be distributed directly to an Azure Compute Gallery, ready for publishing to the Azure Marketplace. You can use ARM JSON templates for a command line experience (Azure VM Image Builder) or use the Azure Portal option (Image templates) for a GUI experience.
This guide is based off of a Microsoft article titled “[Use custom image templates to create custom images in Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-custom-image-templates)”.    
## Image Template Creation Overview
1.	Create and configure a template (including customization steps).
2.	Build the image.
3.	Create a VM from the image.
## Prerequisites
1.	Required features need to be registered on the subscription.
    -	Microsoft.Compute
    -	Microsoft.KeyVault
    -	Microsoft.Storage
    -	Microsoft.Network
    -	Microsoft.VirtualMachineImages
    -	Microsoft.ManagedIdentity
2.	Resource Group
3.	Azure compute gallery and VM image definition
4.	User assigned managed identity
5.	New RBAC role for managed identity and other roles
Prepare prerequisites
1.	Register required features on the subscription
Method 1, PowerShell
Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages, Microsoft.Network, Microsoft.ManagedIdentity |
  Where-Object RegistrationState -ne Registered |
    Register-AzResourceProvider

Method 2, Azure CLI
az provider register -n Microsoft.Compute 
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.Storage
az provider register -n Microsoft.VirtualMachineImages
az provider register -n Microsoft.Network
az provider register -n Microsoft.ManagedIdentity

2.	Create a Resource Group using the Azure Portal (search for Resource groups)
3.	Create an Azure compute gallery (search for Azure compute galleries)
4.	Add a VM Image definition in the Azure compute gallery.
5.	Create a user assigned Managed Identity using the Azure Portal (search for Managed Identities).
*Be sure to put the Managed Identity in the same Resource Group just created and in the same Region.
6.	Create a new RBAC role for the Managed Identity so that it can read, write, and delete images in Azure compute galleries. This needs to be done on the Resource Group.
a.	Open up the resource group and click on Access control (IAM)
b.	Click Add > Add custom role
Name: Image Contributor
Description: Allows to read, write, and delete images in Azure Shared Image Gallery
Baseline permissions: Start from scratch
Click Next
c.	Add permissions
Search: Compute galleries, click Microsoft Compute
Select: Read: Get Gallery, Read: Get Gallery Image,  Read: Get Gallery Image Version
Click Add
Click Add permissions
Search: Compute galleries image versions, click Microsoft Compute
Select: Write: Create or Update Gallery Image Version
Add
Addpermissions
Search: Compute images, click Microsoft Compute (Microsoft.compute/images)
Select: Read: Get Image, Write: Create or Update Image, Delete: Delete Image
Click Add
Click Next
Assignable scopes tab
If the Subscription is listed, delete it since this only needs to be at the resource group level
If the Resource group is not listed, Click Add assignable scopes
Type: Resource group
Select: this resource group
Click Review + create
Click Create
It may be necessary to copy private files, which are needed for software installation, to an image while it is being built. Creating a blob container to house these files in an Azure storage account is a good option If you want to securely access private files during the Customizations phase of the image template. This could be useful for copying license files to a VM from a storage account with a ‘Run a powershell command’ customizer. A script could also be called from a storage account with a ‘Run a powershell script’ command. Anonymous access does not need to be enabled to access these files. These files could also be accessed from a publicly available location, such as GitHub, or a web service.
Additional Roles
•	Managed Identity Operator & Virtual Machine Contributor - needed to assign a user-assigned identity to a VM so that it can access Azure resources such as storage blob containers. These roles need to be added in the resource group IAM.
•	Storage Blob Data Reader - needed to access Azure Storage blob container and data. This role needs to be assigned to the managed identity from the storage blob container IAM.
Create an Image Template
1.	Search for and click on Image templates.
2.	Click Create.
3.	Most settings on the Basics tab are specific to your environment or preferences. Below are settings that I chose for this template:
Source image: Marketplace
Image: Windows Server 2019 Datacenter – Gen2
Distribution targets: VM image version
Managed identity: the identity created earlier
4.	Click Next : Customizations
5.	Below are the settings I chose for the Customizations tab:
Build VM managed identity: the identity created earlier
6.	Click Add under Customize with scripts to configure VM installation options.
Customizer: Run a powershell command
Inline command: 
$path_temp = 'temp-ecx'
New-Item -Type Directory -Path  'c:\\' -Name $path_temp
invoke-webrequest -uri 'https://aka.ms/downloadazcopy-v10-windows' -OutFile c:\\$path_temp\\azcopy.zip
Expand-Archive c:\\$path_temp\\azcopy.zip c:\\$path_temp
copy-item C:\\$path_temp\\azcopy_windows_amd64_*\\azcopy.exe\\ -Destination c:\\$path_temp
cd c:\\$path_temp
.\azcopy login --login-type=MSI
.\azcopy copy 'https://<storage name>.blob.core.windows.net/<blob container name>/X5x_ALRT.key' C:\\$path_temp\\X5x_ALRT.key
.\azcopy copy 'https:// <storage name>.blob.core.windows.net/<blob container name>/X5x_Base.key' C:\\$path_temp\\X5x_Base.key
.\azcopy copy 'https:// <storage name>.blob.core.windows.net/<blob container name>/X5x_REPL.key' C:\\$path_temp\\X5x_REPL.key
.\azcopy copy 'https:// <storage name>.blob.core.windows.net/<blob container name>/install-ecx.ps1' C:\\$path_temp\\install-ecx.ps1
powershell -executionpolicy bypass -File .\install-ecx.ps1 ecx52w_x64.zip c:\$path_temp

Permissions: Run as elevated
*Note – this code will do the following:
•	create a temporary directory on the VM
•	download azcopy from the web and login to your Azure account
•	download ExpressCluster license files and installation script from Azure storage
•	run the ExpressCluster installation script with the installation zip file name (e.g.  ecx52w_x64.zip) and temporary directory as parameters.
7.	Click OK to add this Customizer.
8.	Click Add to add another customization option.
9.	Customizer: Perform Windows restart
10.	Click OK to add this Customizer.
11.	Click Next : Validations
12.	Add a Validator, if needed, and click Next : Tags.
13.	Add any Tags to categorize resources as needed and click Review + create.
14.	Click Create.
15.	Once the Image template has been created, change to the Image template overview page and click Start build to launch the VM creation process. This may take awhile to complete.
The new VM image will be created in your Azure compute gallery.

Addendum
Use SAS tokens to access Azure storage blob files
If you would prefer to use SAS tokens to access the files to be copied during VM creation, the code is here:
$path_temp = 'temp-ecx'
New-Item -Type Directory -Path  'c:\\' -Name $path_temp
invoke-webrequest -uri 'https:// <storage name>.blob.core.windows.net/<blob container name>/X5x_ALRT.key?<SAS token>' -OutFile c:\\$path_temp\\X5x_ALRT.key
invoke-webrequest -uri 'https:// <storage name>.blob.core.windows.net/<blob container name>/X5x_Base.key? <SAS token>' -OutFile c:\\$path_temp\\X5x_Base.key
invoke-webrequest -uri 'https:// <storage name>.blob.core.windows.net/<blob container name>/X5x_REPL.key? <SAS token>' -OutFile c:\\$path_temp\\X5x_REPL.key
invoke-webrequest -uri 'https:// <storage name>.blob.core.windows.net/<blob container name>/install-ecx.ps1? <SAS token>' -OutFile c:\\$path_temp\\install-ecx.ps1
cd c:\\$path_temp
powershell -executionpolicy bypass -File .\install-ecx.ps1 ecx52w_x64.zip c:\$path_temp
Why not use the Run a powershell script customizer to execute the script file from the storage blob?
I couldn’t figure out a way to pass arguments to the script with this method.
Need to troubleshoot?
If you need to troubleshoot the creation of the VM from the Image template, find the Resource Group which includes the name of the Resource Group the VM was created under plus the Image template name (IT_<resource group created under>_<Image template name>_<long string>). There is a storage account which contains a Container blob named packerlogs with a folder which has a log file called customization.log.
Image template distribution target options
The distribution target can be a VM image version (which will be sent to an Azure Compute Gallery), a Managed Image (which will be saved in a resource group), or a Storage Blob VHD (which will be created in a Storage Account inside the staging Resource Group that's automatically created by Azure VM Image Builder). One or more of these can be selected.
No longer need the Image template?
If you no longer need the Image template , delete it. This will also remove the temporary resource group (IT_<resource group created under>_<Image template name>_<long string>), the storage account, and log file.
ExpressCluster automated installation script
What the script does:
1.	Creates a temporary folder (if not already created).
2.	Downloads and unzips the designated ExpressCluster installation zip file from the ExpressCluster website.
3.	Silently installs ExpressCluster.
4.	Opens the ports needed by ExpressCluster through the firewall.
5.	Registers license files (which should already have been copied to the temporary folder).
6.	Runs code to check if the licenses are registered and ports are open.
7.	Deletes the temporary folder. This line can be commented out to aid in troubleshooting.
Why not use the File customizer to download the ExpressCluster installation script, since it is less than 20 MB?
If it was the only file that I needed, I might. It is just easier to download all of the files I need in one code segment instead of adding a File customizer for each file.

