# Azure shared disks
Microsoft recently (July 6, 2020) announced the general availability of [Azure shared disks](https://azure.microsoft.com/en-us/blog/announcing-the-general-availability-of-azure-shared-disks-and-new-azure-disk-storage-enhancements/). This allows a single disk to be simultaneously attached and used from multiple virtual machines (VMs) in the cloud. It is an opportunity to create EXPRESSCLUSTER clusters with shared disks in Microsoft Azure. Azure Disk Storage supports both Windows and Linux-based clustered or high-availability applications. Azure shared disks can use SCSI Persistent Reservations (SCSI PR) commands to control read or write access to the disk. Shared disks are available on Ultra Disks* and Premium SSDs** (disks larger than P15) and can only be enabled as data disks (not OS disks). More specific information on Azure Shared Disks, including SCSI PR, disk sizes, types, and examples can be found at the following link: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disks-shared. Information on enabling Ultra disks and Premium SSDs, including shared disk deployment examples using CLI, PowerShell, and the Azure Resource Manager are available from the following link: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disks-shared-enable.    

    *If using an Ultra Disk, Ultra Disk compatibility must be enabled on the VM.    
    **Premium SSD shared disks are currently only available in West Central US region. The minimum Premium SSD shared disk size is 256GiB.    
    ***All VMs sharing a disk must be deployed in the same proximity placement group.

Shared disks can be created from Azure CLI, PowerShell, and templates. The **maxshares** value of a managed disk can be modified to create a shared disk. Some examples of how to create a shared disk using CLI and PowerShell are listed below.

## CLI
### Create a shared disk
#### Premium SSD Example

az disk create -g *myResourceGroup* -n *mySharedDisk* --size-gb *256* -l westcentralus --sku PremiumSSD_LRS --max-shares *2* --zone *1*    
    Note that this creates a 256GiB disk with 2 shares. The italicized parameters need to be changed to match your environment    
    Other settings to consider might include diskIopsReadOnly, diskIopsReadWrite, diskMbpsReadOnly, and diskMbpsReadWrite.

*Currently Premium SSD shared disks can only be created in the West Central US region. My Azure subscription doesn't allow me to create VM's in that region, so I have done my testing with Ultra Disks. The main difference in the syntax is the sku (disk type). [Ultra Disks](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disks-enable-ultra-ssd#ga-scope-and-limitations) can have cutsom disk sizes. The disk size determines how many shares can be allocated. Max for Premium SSDs is 10. Max for Ultra Disks is 5.*

#### Ultra Disk Example

az disk create -g *myResourceGroup* -n *mySharedDisk* --size-gb *256* -l *westus2* --sku UltraSSD_LRS --max-shares *2* --zone *1*

### View disk properties (useful command)

az disk show -g *myResourceGroup* -n *mySharedDisk*

### Convert existing disk to shared disk or increase number of shares

az disk update -g *myResourceGroup* -n *mySharedDisk* --set maxShares=*2*

    *The maxShares value can only be updated if the disk is detached from all nodes. The default value is 1.
    
### Attach disk to VM

az vm disk attach -g *myResourceGroup* --vm-name *myVMName* --name *mySharedDisk*

    *Note that Option '--disk' has been deprecated and will be removed in a future release. Using '--name' instead.
    
## PowerShell
### Create a shared disk
#### Premium SSD Example

PS />$dataDiskConfig = New-AzDiskConfig -Location WestCentralUS -DiskSizeGB *256* -AccountType PremiumSSD_LRS -CreateOption *Empty* -MaxSharesCount *2* -Zone *1*    
PS />New-AzDisk -ResourceGroupName *myResourceGroup* -DiskName *mySharedDisk* -Disk $dataDiskConfig

#### Ultra Disk Example

PS />$datadiskconfig = New-AzDiskConfig -Location *westus2* -DiskSizeGB *256* -AccountType UltraSSD_LRS -CreateOption *Empty* -MaxSharesCount *2* -Zone *1*    
PS />New-AzDisk -ResourceGroupName *myResourceGroup* -DiskName *mySharedDisk* -Disk $datadiskconfig

