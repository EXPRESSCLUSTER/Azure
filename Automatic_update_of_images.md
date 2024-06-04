# Automatic update of images in Azure marketplace
Azure Marketplace is the online store for developers and IT pros looking for technical building blocks to run on Azure.
We sell the vertial machine installed EXPRESSCLUSTER in Azure Marketplace.
Customers buy VMs with ECX already installed, so they don't need to configure ECX.
To make it easier for customers to use, it is recommended to always keep the VM's OS latest version.

## Windows OS release on Azure Marketplace update history
You can find updates for Windows Server and Windows images in Azure Marketplace.
- https://support.microsoft.com/en-us/help/4497947/
- https://support.microsoft.com/en-us/help/4492750

## How Azure selects a route
By using Azure Update Management, you can automate OS version updates.

### Method(Being Edit)
1. Create an Automation account.
2. Create a Log Analytics workspace.
3. Configure Azure Update Management on your virtual machine.
   - You configure the LogAnalytics workspace and Automation account. Select the LogAnalytics workspace and Automation account you created earlier.
4. If you wait for a while and display the update management screen again, the content that has not been applied will be displayed.
