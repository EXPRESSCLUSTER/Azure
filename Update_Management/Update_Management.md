Azure Update Management
One big challenge with patching operating systems where Expresscluster software is installed is making sure that updates aren’t installed on all nodes at the same time, especially if a reboot is required. One solution to this issue is manually applying the updates. A better solution is to automate the updates using a predetermined schedule, updating the OS of the primary node first, and then up to a day later, updating the OS of the standby node. Azure Update Manager provides the ability to patch a system on a preset schedule, hourly, daily, weekly, or monthly.
Pre-requisites
Azure VMs:  Azure Windows VM Agent is required. It is usually installed by default on most Azure VMs. Verify by opening Task Manager on the VM and search for the WindowsAzureGuestAgent.exe process.
The Azure VM Linux agent is needed for Azure Linux VMs.
Non-Azure machines: Azure Arc.
Enable Auto-updates for Azure VMs with a Maintenance Configuration
1.	Sign into Azure.
2.	Search for and click on Azure Update Manager.
3.	Under Manage, click on Machines.
All machines eligible for update management should be listed.
4.	Check the box next to the machine(s) to be managed.
5.	Click on Schedule Updates. A wizard should start to Create a maintenance configuration.
6.	Fill in the fields:
Subscription: Should be auto-populated
Resource group: Choose the appropriate group
Configuration name: Enter a unique name
Region: Choose the appropriate region
Maintenance scope: Guest (Azure VM, Arc-enabled VMs/servers)
Reboot setting: Reboot if required
 
7.	Click Add a schedule.
8.	Fill in the following:
Start on: Desired date and time
Time zone: Time zone of machine
Maintenance window: Leave at the maximum of 3 Hours 55 Minutes
(This is the time allowed for updates to be installed. If there is not enough time, some updates will not be applied. 20 minutes of this time is reserved for reboots.)
Repeats: 2nd Tuesday of every month (patch Tuesday) with no offset
 
9.	Save and click Next: DynamicScopes.
10.	Dynamic Scopes are not needed for this configuration, so click Next : Resources.
11.	The machine selected at the beginning of this process should be the only one listed at this time. Other machines could be added to use the same schedule here or later. Click Next : Updates.
12.	The default updates are classified as Critical and Security. Click Include update classification to include more update classifications such as Update rollups, Feature packs, Service packs, Definition updates, Tools, or Updates. Click Next : Tags.
13.	Add and Tags that are needed and click Next : Review + Create.
14.	If the validation passes, click Create.
A new maintenance configuration will be created with an update schedule for the selected machine(s). This configuration can be edited from the Azure Update Manager > Machines window by clicking on Maintenance configurations.
Confirm that the Patch orchestration is set to ‘Customer managed schedules’
Back on the Azure Update Manager > Machines page, put a check next to the machine(s) just configured and in the upper window, click on Settings > Update settings.
 
A prompt will ask if you want to change update settings like patch orchestration, hotpatch option or periodic assessment for selected 1 Windows Server(s) and 0 Linux machine(s). Click Update settings to continue.
If Patch orchestration is not set to ‘Customer Managed Schedules’, change it from the dropdown menu and Save. This is the recommended configuration setting.
 
*Note – Patch orchestration is not applicable to Arc-enabled servers.
Turn on periodic assessment to regularly check for updates
Enable Periodic assessment from the same window. Change the setting from Disable to Enable and Save. This will allow update management to check for new updates every 24 hours.
 

Additional Notes
•	The upper maintenance window is 3 hours 55 mins.
•	A minimum of 1 hour and 30 minutes is required for the maintenance window.
•	Maintenance updates cannot be applied to any shut down machines. You need to ensure that your machine is turned on at least 15 minutes before a scheduled update or your update may not be applied.

