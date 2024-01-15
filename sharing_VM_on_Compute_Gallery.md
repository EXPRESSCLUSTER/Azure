# Making VM to be shared on Azure Compute Gallery

```ps1
$ProgressPreference = 'SilentlyContinue';Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
Remove-Item .\AzureCLI.msi

# Resource Group を作る
az group create --name exampleRG --location westus2

# Compute Gallery を作る
az sig create --resource-group exampleRG --gallery-name exampleGallery

# VM を作る
az deployment group create --resource-group exampleRG --template-file main.bicep --parameters adminUsername='kaz' adminPassword='Nec01@clp-admin'
az vm stop --resource-group exampleRG --name simple-vm
az vm deallocate --resource-group exampleRG --name simple-vm

# ポータルでVMをキャプチャする (Generalized image)
# https://learn.microsoft.com/ja-jp/azure/virtual-machines/capture-image-portal
# Gallery に VM Image definition と VM Image version ができあがる。

# Gallery の VM Image へアクセス可能なユーザを追加する
# https://learn.microsoft.com/ja-jp/azure/virtual-machines/share-gallery?tabs=portal
```
