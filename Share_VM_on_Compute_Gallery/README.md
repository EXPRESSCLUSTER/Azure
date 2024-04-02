# Making VM to be shared on Azure Compute Gallery

```ps1
# Install Azure CLI (requires Administrator right)
$ProgressPreference = 'SilentlyContinue';Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
Remove-Item .\AzureCLI.msi

# Crete Resource Group
az group create --name exampleRG --location westus2

# Create Compute Gallery
az sig create --resource-group exampleRG --gallery-name exampleGallery

# Create VM
az deployment group create --resource-group exampleRG --template-file main.bicep --parameters adminUsername='kaz' adminPassword='Nec01@clp-admin'
az vm stop --resource-group exampleRG --name simple-vm
az vm deallocate --resource-group exampleRG --name simple-vm
```

Capture the VM on the portal (Generalized image)

  <https://learn.microsoft.com/ja-jp/azure/virtual-machines/capture-image-portal>

"VM Image definition" and "VM Image version" are made in the Gallery.

Add the user who is accessible to the VM Image in the Gallery.

  <https://learn.microsoft.com/ja-jp/azure/virtual-machines/share-gallery?tabs=portal>

