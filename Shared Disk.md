# Azure shared disks
Microsoft recently (July 6, 2020) announced the general availability of [Azure shared disks](https://azure.microsoft.com/en-us/blog/announcing-the-general-availability-of-azure-shared-disks-and-new-azure-disk-storage-enhancements/). This allows a single disk to be simultaneously attached and used from multiple virtual machines (VMs) in the cloud. It is an opportunity to create EXPRESSCLUSTER clusters with shared disks in Microsoft Azure. Azure Disk Storage supports both Windows and Linux-based clustered or high-availability applications. Azure shared disks can use SCSI Persistent Reservations (SCSI PR) commands to control read or write access to the disk. Shared disks are available on Ultra Disks* and Premium SSDs** (disks larger than P15) and can only be enabled as data disks (not OS disks). More specific information on Azure Shared Disks, including SCSI PR, disk sizes, types, and examples can be found at the following link: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disks-shared. Information on enabling Ultra disks and Premium SSDs, including shared disk deployment examples using CLI, PowerShell, and the Azure Resource Manager are available from the following link: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disks-shared-enable.    

    *If using an Ultra Disk, Ultra Disk compatibility must be enabled on the VM    
    **Premium SSD shared disks are currently only available in West Central US region.    
    ***All VMs sharing a disk must be deployed in the same proximity placement group.


