# Hybrid cluster (On-premises and Azure)
This guide describes how to create a Site-to-Site VPN tunnel between an Azure site and on-premises site. Instead of using a VPN device on the on-premises site, RRAS is configured on a server to provide VPN access. A Hybrid Azure/On-premises cluster can then be created with EXPRESSCLUSTER software.    

Prerequisites
•	Azure subscription
•	Azure Site-to-Site connection (including a virtual network, VPN gateway, local network gateway, and VPN connection)
•	Azure DNS Zone
•	2 Windows VM Servers (On-premises and Azure), each server with 2 disks
•	Witness VM server in Azure (for NP resolution)
•	RRAS installed on the On-premises Windows Server
•	On-premises external public IP address
There are several values which you will need to prepare ahead of time. The key values which are used multiple times are listed here:
	Azure User Name and Password
	Azure Tenant ID
	Azure Resource Group
	Azure Region
	Azure Virtual network address space
	Azure Virtual network gateway Public IP address
	Azure Zone Name
	Azure Zone Record Set Name
	On-premises internet facing Public IP address
	On-premises network address space
	IP addresses for each ECX node

Create a Site-to-Site IPsec VPN tunnel in Azure
Sign into the Azure portal and create the following resources:
1.	Virtual network
2.	VPN (Virtual network) gateway
Copy the public IP address for future reference
3.	Local network gateway
4.	VPN connection 
Note that this is your Site-to-Site VPN connection between your Azure virtual network gateway and your on-premises site. It will not connect yet since RRAS is not set up on the on-premises site.
Microsoft has a tutorial called Tutorial: Create a Site-to-Site connection in the Azure portal which walks you through each of these steps and provides detailed information about each field. A link is provided for you if you prefer PowerShell. You can skip the section titled Configure your VPN device since we will be using RRAS and not a VPN device. This section refers to downloading a configuration script for a VPN device. An RRAS script could be downloaded in the past, but it is no longer available. I found a copy of the original RRAS PowerShell script and will link to it later in this guide.
Create a DNS zone
This will be needed later for the Azure DNS resource in EXPRESSCLUSTER.
1.	Return to the Azure portal dashboard and search for and select DNS zones.
2.	Click Add.
3.	On the Basics tab, select your Subscription and the Resource Group created previously.
4.	Enter a Name for the zone (e.g. cluster1.zone).
5.	Click Review + Create. After passing validation, click Create.

Microsoft has more information about DNS zones. 
Configure the On-premises site
Install a VM to the on-premises site on the same network referenced for the Azure local network gateway. It will need a second disk for mirroring data. Create the necessary Cluster and Data partitions on the second disk. Click here for more information on mirror disks.
Download the RRAS installation script <script name and link> and copy it to your on-premises server.
Change the following variable in the script to the values in your environment:

$SP_AzureGatewayIpAddress (Azure Virtual network gateway Public IP address)
$SP_Subnet (Azure Virtual network address space)
$SP_PresharedKey (Site to Site VPN connection Shared Key)

Run the script to install and configure RRAS.
Notes:
The original script can be downloaded from https://github.com/Azure/Azure-vpn-config-samples/blob/master/Microsoft/microsoft-rras-windows-server-2012-r2.ps1.xslt.
I used this article Site to Site VPN with RRAS to convert the script from XSLT to PowerShell, and make the variables more easy to modify. The script worked on a Windows 2019 Server. This page is in Japanese.
The VPN should now make a connection between the Azure site and on-premises site. Verify the connectivity status from Azure by accessing the Local network gateway resource and view Connections. The Routing and Remote Access console will show connection status from Network Interfaces on the on-premises server. You may need to create traffic (like pinging an Azure IP address) to activate the demand-dial interface. You can try pinging the Azure public IP address or use the PowerShell command:
Test-Netconnection <IP address>  -InformationLevel Detailed
The script should run the following PowerShell command to connect to Azure:
Connect-VpnS2SInterface -Name <Azure Public IP address>
The connection can also be verified with Get-VpnS2SInterface.
Create VM on Azure
If you have not done so, install a VM in Azure on a subnet of the virtual network create beforehand. It will also need a second disk for mirroring data. Create the necessary Cluster and Data partitions on the second disk, identical to the one created on the on-premises server.
Be sure that the Azure VM and the on-premises VM’s can ping each other before continuing.
Preparation for Azure DNS resource
1.	Install the Azure CLI on each node
2.	Create a server principal using the Azure CLI
Note that the output for this step is a certificate which can be used by the Azure DNS resource to access the Azure zone to manage a DNS record.

See the Instructions for performing these steps - scroll down to step 8 and proceed from there.

Additional notes:
- You need to make note of the certificate’s output since the certificate is encrypted. Write down the “name” (URI) and tenant ID.
- You only need to create a certificate on one node and then copy the certificate to the other node. Place the certificate in the same location on each node.
- Also make note of the path Azure CLI was installed to.
- See Notes on Azure DNS Resources for more information about this resource.
Install EXPRESSCLUSTER
Install EXPRESSCLUSTER on the Azure VM using the instructions from section 4.2.1 in the Installation and Configuration Guide. If more information on registering a license is needed, click here. Repeat on the on-premises node.
Create a cluster
Create the cluster, including the Azure DNS resource by following the instructions in section 4.3.of the Azure configuration guide. Perform the installation steps on either node up to the Custom monitor resource section since we will not be adding monitor resources. When at the Azure DNS resource configuration page, see the note below about the IP addresses. Skip down to page 67, step 5 to complete the configuration. Follow the instructions in section 4.4 to verify whether the environment is working. See the note about testing by deleting the A record.

Additional notes:
- On the Azure DNS resource details page, enter the primary server IP address in the IP Address field of the common tab and then enter the IP addresses of each server node in the respective tabs at the top.
- Deleting the A record in the DNS zone will not cause a failover since the record will be recreated before that can happen.
Witness Server configuration
On Witness Server
In order to provide NP resolution, a witness server VM needs to be prepared on Azure with a witness server service. It is best if it is not in the same network or region as the VPN gateway. It also needs a public IP address which can be accessed by each node of the EXPRESCLUSTER cluster, from the Azure site and on-premises site. In order to set up the witness service, you will need to download Node.js (which is required by the witness server service) and locate the witness service module, clpwitnessd-<version>.tgz, which is in a subfolder of the EXPRESSCLUSTER installation. A Node.js installation package can be downloaded from the Nodejs.org page. The witness service module can be found in the EXPRESSCLUSTER installation subfolder Common\4.2\common\tools\witnessd. Copy both files to the witness server and follow the installation guide.

Note:
The winser command to register and start the Witness server service in step 4 should be winser -i -a.
Since the witness heartbeat resource uses the ECX HTTP network partition resolution resource as well, an inbound port rule to allow port 80 needs to be created on the witness server’s NIC and through the VM’s local firewall.
Witness heartbeat resource configuration in EXPRESSCLUSTER
An explanation of the witness heartbeat resource can be found here. 
1.	Open the Cluster WebUI.
2.	Change to Config mode.
3.	Click on the Cluster properties gear icon.
4.	Select the Interconnect tab.
5.	Click Add to add another heartbeat resource.
6.	Change the Type of the new entry to Witness. MDC should be set to Do Not Use and each server set to Use.
7.	Click on the Properties button and enter the Witness server’s Public IP address for the Target Host. The Service Port can be left at 80. Click OK.
(If you click on the NP Resolution tab, there should be a new HTTP Type entry.)
8.	Click Apply the Configuration File.
Client
DNS setting
If you have a client VM on the Azure network, it can be configured to connect to whichever server is active in the cluster. It will need access to the DNS record in the DNS zone. If you go to the DNS zones page in Azure and click on the zone created previously, you will notice four entries for Name server (1 – 4). Copy the name for Name server 1 e.g. ns1-06.azure-dns.com. Now do the following:

1.	Log into the Azure VM node,  open a command prompt and type nslookup <DNS server name> e.g. nslookup ns1-06.azure-dns.com.
2.	Copy the IP address from the output.
3.	In the Azure portal locate the client VM’s page and click on the Networking folder.
4.	Then click on the network interface.
5.	Click on DNS servers and change from Inherit from virtual network to Custom.
6.	Enter the IP address from the DNS zone’s DNS server and Save it.

You should now be able to access the DNS record created by EXPRESSCLUSTER from the client. The full record name from the example in the user’s guide would be test-record1.cluster1.zone. If you pinged that entry from the client machine, you should get the IP address of the active EXPRESSCLUSTER node.

TTL setting
The default TTL value of the Azure DNS record is 3600 seconds. You need to change it to a much lower value in order for DNS updates to occur quickly after a failover from one cluster node to the other. You can manually change the TTL of the record, but when the record is modified due to a failover, for some reason it is reset to 3600 seconds. A workaround has been created so that your desired TTL will be permanent. Follow the instructions from the Azure GitHUB page titled Workaround for AzureCLI issue.to be performed on the Azure DNS resource in EXPRESSCLUSTER.

