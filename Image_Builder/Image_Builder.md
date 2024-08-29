<h1 align="center">
🚧🚧Under  Construction🚧🚧
</h1>

# Azure VM Image Builder\Image Templates
Azure Image templates create a pipeline that fully automates the building of a custom VM image with ExpressCluster installed. The image can be distributed directly to an Azure Compute Gallery, ready for publishing to the Azure Marketplace. You can use ARM JSON templates for a command line experience (Azure VM Image Builder) or use the Azure Portal option (Image templates) for a GUI experience.
This guide is based off of a Microsoft article titled “[Use custom image templates to create custom images in Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-custom-image-templates)”.    
## Image Template Creation Overview
1.	Create and configure a template (including customization steps).
2.	Build the image.
3.	Create a VM from the image.
## Prerequisites
1.	Required features registered on the subscription
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
6.	ExpressCluster license files and [installation script](Scripts/install-ecx.ps1)
## Prepare prerequisites
1.	Register required features on the subscription.    
&nbsp;  
Method 1, **PowerShell**    
Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages, Microsoft.Network, Microsoft.ManagedIdentity |
 Where-Object RegistrationState -ne Registered | Register-AzResourceProvider    
&nbsp;  
Method 2, **Azure CLI**    
az provider register -n Microsoft.Compute    
az provider register -n Microsoft.KeyVault    
az provider register -n Microsoft.Storage    
az provider register -n Microsoft.VirtualMachineImages    
az provider register -n Microsoft.Network    
az provider register -n Microsoft.ManagedIdentity    

2.	Create a **Resource Group** using the Azure Portal (search for Resource groups).
3.	Create an **Azure compute gallery** (search for Azure compute galleries).
4.	Add a **VM Image definition** in the Azure compute gallery (OS type, VM generation, VM architecture, description, etc.).
5.	Create a user assigned **Managed Identity** using the Azure Portal (search for Managed Identities).    
\*Be sure to put the Managed Identity in the same Resource Group just created and in the same Region.
6.	Create a new RBAC role for the Managed Identity so that it can read, write, and delete images in Azure compute galleries. This needs to be done on the Resource Group.    
&nbsp;  
6.1	Open up the resource group and click on **Access control (IAM)**    
6.2	Click **Add > Add custom role**    
&emsp;&ensp;**Name**: _Image Contributor_    
&emsp;&ensp;**Description**: _Allows to read, write, and delete images in Azure Shared Image Gallery_    
&emsp;&ensp;**Baseline permissions**: _Start from scratch_    
&emsp;&ensp;Click **Next**.    
6.3	Click **Add permissions**    
&emsp;&ensp;**Search**: _Compute galleries_, click **Microsoft Compute**    
&emsp;&ensp;**Select**: _Read: Get Gallery_, _Read: Get Gallery Image_,  _Read: Get Gallery Image Version_    
&emsp;&ensp;Click **Add**    
&emsp;&ensp;Click **Add permissions**    
&emsp;&ensp;**Search**: _Compute galleries image versions_, click **Microsoft Compute**    
&emsp;&ensp;**Select**: _Write: Create or Update Gallery Image Version_    
&emsp;&ensp;Click **Add**    
&emsp;&ensp;Click **Add permissions**    
&emsp;&ensp;**Search**: _Compute images, click Microsoft Compute (Microsoft.compute/images)_    
&emsp;&ensp;**Select**: _Read: Get Image, Write: Create or Update Image, Delete: Delete Image_    
&emsp;&ensp;Click **Add**    
&emsp;&ensp;Click **Next**    
&emsp;&ensp;**Assignable scopes** tab    
&emsp;&ensp;If the Subscription is listed, delete it since this only needs to be at the resource group level.    
&emsp;&ensp;If the Resource group is not listed, Click **Add assignable scopes**.    
&emsp;&ensp;**Type**: Resource group    
&emsp;&ensp;**Select**: this resource group    
&emsp;&ensp;Click **Select**    
&emsp;&ensp;Click **Review + create**    
&emsp;&ensp;Click **Create**    
7. Copy ExpressCluster license files and installation script to an Azure storage blob. Copy the links to these files to be used later.    
&nbsp;  
It may be necessary to copy private files, which are needed for software installation, to an image while it is being built. Creating a blob container to house these files in an Azure storage account is a good option if you want to securely access private files during the _Customizations_ phase of the image template. This could be useful for copying license files to a VM from a storage account with a ‘Run a powershell command’ customizer. A script could also be called from a storage account with a ‘Run a powershell script’ command. Anonymous access does not need to be enabled to access these files. These files could also be accessed from a publicly available location, such as GitHub, or a web service.
&nbsp;  
## Additional Roles Needed
- **Managed Identity Operator** & **Virtual Machine Contributor** - needed to assign a user-assigned identity to a VM so that it can access Azure resources such as storage blob containers. These roles need to be added in the resource group IAM.    
- **Storage Blob Data Reader** - needed to access Azure Storage blob container and data. This role needs to be assigned to the managed identity from the storage blob container IAM.
## Create an Image Template
1.	Search for and click on **Image templates**.
2.	Click **Create**.
3.	Most settings on the Basics tab are specific to your environment or preferences. Below are settings that I chose for this template:    
**Source image**: Marketplace    
**Image**: Windows Server 2019 Datacenter – Gen2    
**Distribution targets**: VM image version    
**Managed identity**: the identity created earlier
4.	Click **Next : Customizations**
5.	Below are the settings I chose for the Customizations tab:   
**Build VM managed identity**: select the identity created earlier
6.	Under **Customize with scripts**, click **Add** to configure VM installation options.
**Customizer**: _Run a powershell command_    
**Inline command**:
```
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
cd c:\\
#Remove temporary folder - do not include this next line if troubleshooting
Remove-Item -Path $path_temp -Recurse -Force
```
&emsp;&ensp;**Permissions**: Run as elevated    
&nbsp;  
&emsp;&ensp;*Note – this code will do the following:    
   - Create a temporary directory on the VM    
   - Download _azcopy_ from the web and login to your Azure account    
   - Download ExpressCluster license files and installation script from Azure storage    
   - Run the ExpressCluster installation script with the installation zip file name (e.g.  ecx52w_x64.zip) and temporary directory as parameters.    
7.	Click **OK** to add this **Customizer**.
8.	Click **Add** to add another customization option.    
	**Customizer**: Perform Windows restart
9.	Click **OK** to add this Customizer.
10.	Click **Next : Validations**
11.	**Add** a **Validator**, if needed, and click **Next : Tags**.
12.	**Add** any **Tags** to categorize resources as needed and click **Review + create**.
13.	Click **Create**.
14.	Once the Image template has been created, change to the Image template overview page and click **Start build** to launch the VM creation process. This may take a while to complete.
The new VM image will be created in your Azure compute gallery.

## Addendum
### Use SAS tokens to access Azure storage blob files
If you would prefer to use SAS tokens to access the files to be copied during VM creation, the code is here:    
```
$path_temp = 'temp-ecx'
New-Item -Type Directory -Path  'c:\\' -Name $path_temp
invoke-webrequest -uri 'https://<storage name>.blob.core.windows.net/<blob container name>/X5x_ALRT.key?<SAS token>' -OutFile c:\\$path_temp\\X5x_ALRT.key
invoke-webrequest -uri 'https://<storage name>.blob.core.windows.net/<blob container name>/X5x_Base.key? <SAS token>' -OutFile c:\\$path_temp\\X5x_Base.key
invoke-webrequest -uri 'https://<storage name>.blob.core.windows.net/<blob container name>/X5x_REPL.key? <SAS token>' -OutFile c:\\$path_temp\\X5x_REPL.key
invoke-webrequest -uri 'https://<storage name>.blob.core.windows.net/<blob container name>/install-ecx.ps1? <SAS token>' -OutFile c:\\$path_temp\\install-ecx.ps1
cd c:\\$path_temp
powershell -executionpolicy bypass -File .\install-ecx.ps1 ecx52w_x64.zip c:\$path_temp
cd c:\\
#Remove temporary folder - do not include this next line if troubleshooting
Remove-Item -Path $path_temp -Recurse -Force
```
### Why not use the Run a powershell script customizer to execute the script file from the storage blob?
I couldn’t figure out a way to pass arguments to the script with this method.
### Need to troubleshoot?
If you need to troubleshoot the creation of the VM from the Image template, find the **Resource Group** which includes the name of the Resource Group the VM was created under plus the Image template name \(e.g. IT\_\<resource group created under\>\_\<Image template name\>\_\<long string\>\). There is a storage account under this resource group which contains a **Container blob** named _packerlogs_ with a folder which has a log file called _customization.log_.
### Image template distribution target options
The distribution target can be a **VM image version** (which will be sent to an Azure Compute Gallery), a **Managed image** (which will be saved in a resource group), or a **Storage Blob VHD** \(which will be created in a Storage Account inside the staging Resource Group that's automatically created by Azure VM Image Builder\). One or more of these options can be selected.
### No longer need the Image template?
If you no longer need the Image template , delete it. This will also remove the temporary resource group \(IT\_\<resource group created under\>\_\<Image template name\>\_\<long string\>\), the storage account, and log file.
### ExpressCluster automated installation script
What the script does:
1.	Creates a temporary folder (if not already created).
2.	Downloads and unzips the designated ExpressCluster installation zip file from the ExpressCluster website.
3.	Silently installs ExpressCluster.
4.	Opens the ports needed by ExpressCluster through the firewall.
5.	Registers license files (which should already have been copied to the temporary folder).
6.	Runs code to check if the licenses are registered and ports are open.
7.	Deletes the temporary folder. This line can be commented out to aid in troubleshooting.
### Why not use the _File customizer_ to download the ExpressCluster installation script, since it is less than 20 MB?
If it was the only file that I needed, I might. It is just easier to download all of the files I need in one code segment instead of adding a **File customizer** for each file.
### Linux bash scripts
Bash code to dowload license files from Azure blob storage using azcopy, download and install ExpressCluster from the NEC ExpressCluster website, and register license files is included below for both Red Hat Linux and Ubuntu Linux.
#### Red Hat script
```
instdir=/tmp/ecxinstall
mkdir $instdir
wget -O $instdir/azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux
tar -xvzf $instdir/azcopy_v10.tar.gz -C $instdir/ --strip-components=1
$instdir/azcopy login --login-type=MSI
$instdir/azcopy copy 'https://<storage name>.blob.core.windows.net/<blob container name>/X5_Alrt_Lin.key' $instdir
$instdir/azcopy copy 'https://<storage name>.blob.core.windows.net/<blob container name>/X5_Base_Lin.key' $instdir
$instdir/azcopy copy 'https://<storage name>.blob.core.windows.net/<blob container name>/X5_Repl_Lin.key' $instdir
curl -A '' -o $instdir/ecx5.zip  https://www.nec.com/en/global/prod/expresscluster/en/trial/zip/ecx52l_x64.zip
unzip $instdir/ecx5.zip -d $instdir
name=$(find $instdir/ -name "*.rpm" )
sudo rpm -i $name
sudo clplcnsc -i $instdir/*.key
# Check fireall
# Open ports through firewall
sudo clpfwctrl.sh --add
# Disable SELinux
sudo sed -i -e 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
# Disable caching of repositories
sudo systemctl disable dnf-makecache.timer

rm -rfv $instdir/
```
\*Note that Red Hat seems to have firewall-d enabled by default. If not, add the following code to check for it and install if missing    
```
FW=firewall-cmd
which $FW > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "'$FW' is not installed"
  #exit ${FWCTRL_ERR_CMDNOTFOUND}
  echo "Installing firewalld"
  sudo yum -y install firewalld
  sudo systemctl start firewalld
  sudo firewall-cmd --state
  sudo systemctl enable firewalld
  echo "Open ports"
else
  echo "'$FW' is installed."
  echo "Open ports"
fi
```
#### Ubuntu script
```
instdir=/tmp/ecxinstall,
mkdir $instdir,
wget -O $instdir/azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux,
tar -xvzf $instdir/azcopy_v10.tar.gz -C $instdir/ --strip-components=1,
$instdir/azcopy login --login-type=MSI,
$instdir/azcopy copy 'https://<storage name>.blob.core.windows.net/<blob container name>/X5_Alrt_Lin.key' $instdir,
$instdir/azcopy copy 'https://<storage name>.blob.core.windows.net/<blob container name>/X5_Base_Lin.key' $instdir,
$instdir/azcopy copy 'https://<storage name>.blob.core.windows.net/<blob container name>/X5_Repl_Lin.key' $instdir,
curl -A '' -o $instdir/ecx5.zip  https://www.nec.com/en/global/prod/expresscluster/en/trial/zip/ecx52l_amd64.zip,
python3 -m zipfile -e $instdir/ecx5.zip $instdir,
name=$(find $instdir/ -name "*.deb" ),
sudo dpkg -i $name,
sudo clplcnsc -i $instdir/*.key,
rm -rfv $instdir/
```
