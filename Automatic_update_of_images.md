# Automatic update of images in Azure marketplace
Azure Marketplace is the online store for developers and IT pros looking for technical building blocks to run on Azure.
We sell virtual machined with EXPRESSCLUSTER pre-installed in the Azure Marketplace.
Customers buy VMs with ECX already installed, so they only need to configure ECX.
To make it easier for customers to use, it is recommended to always keep the VM's OS updated to the latest version.

## Windows OS release on Azure Marketplace update history
You can find updates for Windows Server and Windows images in Azure Marketplace.
- https://support.microsoft.com/en-us/help/4497947/
- https://support.microsoft.com/en-us/help/4492750

## Automating OS updates with Azure Update Management
By using Azure Update Management, you can automate OS version updates on the VM without manual intervention.

### Method
1. Create an Automation account.
2. Create a Log Analytics workspace.
3. Configure Azure Update Management on your virtual machine.
   - Configure the LogAnalytics workspace and Automation account
   - Select the Log Analytics workspace and Automation account you created in the previous steps.
4. If you wait for a while and refresh the update management screen, the content that has not been applied will be displayed.

### References
[Manage update configuration settings](https://learn.microsoft.com/en-us/azure/update-manager/manage-update-settings?tabs=manage-single-overview%2Cmanage-scale-overview)
