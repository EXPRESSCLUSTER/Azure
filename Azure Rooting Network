# Azure Rooting Network
Azure has its own mechanism for routing traffic between resources on the Internet.
Azure automatically creates a route table for each subnet within an Azure virtual network and adds system default routes to the table.
These have the following advantages when applied to EXPRESSCLUSTER.

## Advantage
It is not need to rely on DNS with Azure.Since there is no need to rely on DNS, it can be used in environments where quick responses are required.
If you use this rooting, you can use the secondary IP to dynamically FO this IP to this region.

## How Azure selects a route
When outbound traffic is sent from a subnet, Azure selects a route based on the destination IP address, using the longest prefix match algorithm.

### Type
1.  System routes
2.  Subnet default routes
3.  Routes from other virtual networks
4.  BGP routes
5.  Service endpoint routes
6.  User Defined Routes (UDR)

If there are multiple next hop entries with the same address prefix then Azure selects the routes in following order.

1.  User-defined routes (UDR)
2.  BGP routes
3.  System routes

## Requirements
1. Implement two virtual networks in the same Azure region and enable resources to communicate between the virtual networks.

2. Enable an on-premises network to communicate securely with both virtual networks through a VPN tunnel over the Internet. Alternatively, an ExpressRoute connection could be used, but in this example, a VPN connection is used.

3. For one subnet in one virtual network:

	Force all outbound traffic from the subnet, except to Azure Storage and within the subnet, to flow through a network virtual appliance, for inspection and logging.

	Don't inspect traffic between private IP addresses within the subnet; allow traffic to flow directly between all resources.

	Drop any outbound traffic destined for the other virtual network.

	Enable outbound traffic to Azure storage to flow directly to storage, without forcing it through a network virtual appliance.

4. Allow all traffic between all other subnets and virtual networks.

## Implementation
The following picture shows an implementation through the Azure Resource Manager deployment model that meets the previous requirements:
