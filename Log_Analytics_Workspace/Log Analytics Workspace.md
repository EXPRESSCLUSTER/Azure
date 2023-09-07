# Log Analytics Workspace
An EXPRESSCLUSTER project was started in early 2023 to analyze ECX log files. One part of the project used the Log Analytics workspace feature of Azure Monitor. This project focused on an On-premesis ECX cluster. The Azure Arc agent was used to connect the cluster nodes to Azure Monitor. A data collection rule was created to collect ECX log files from both nodes of the cluster and import them into a table in the Log Analytics workspace. An alert rule was then created to monitor the logs and send and email whenever error events were discovered. The details of this project (including steps to create a table, data collection rule, and alert rules) can be found [here](https://github.com/EXPRESSCLUSTER/Log-Analytics/blob/main/README.md). A link to the page on setting up a Log Analytics workspace with Azure Arc is found at the bottom of the document and also included [here](https://github.com/EXPRESSCLUSTER/Log-Analytics/blob/main/Azure_Monitor_Agent_with_Azure_Arc.md).

## Scripts
This section includes information on scripts that can simplify the setup process.

### 1. PowerShell script to create a Table in Log Analytics workspace, a Data Collection Rule (DCR) and a Data Collection Endpoint (DCE)
Bruno Gabrielli created a PowerShell script to create a table in Log Analytics workspace, a DCR and DCE. The scripts and an explanation on how to use them is included in his article titled [Azure Monitor: Gain Observability On Your DHCP Server](https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/azure-monitor-gain-observability-on-your-dhcp-server/ba-p/3865274). You need to create an Azure **Resource Group** and a **Log Analytics workspace** ahead of time, but the script will prompt you for other resource names. It even includes a template for an Azure Workbook, which you may or may not need. The scripts have been downloaded locally [here](Scripts). In order to run the scripts, you will need to install the AZ Powershell module \([instructions here for Windows](https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-10.2.0&tabs=powershell&pivots=windows-psgallery)\) on your system and also prepare the following names ahead of time:    

1.  _Subscription Id_
2.  _Resource Group_ name (previously created)
3.  _Log Analytic workspace_ name (previously created)    
5.  Table Name (create yourself)
6.  DCE Name (create yourself)
7.  DCR Name (create yourself)
8.  JSON Template Name (e.g. DCE-DCR-Template.json)

Once the Table, DCE, and DCR are successfully created, you will need to edit the DCR from the Azure dashboard and add your Azure Arc enabled servers as Resources, choosing the recently created DCE in the _Data collection endpoint_ field.
#### Modify .json files
If you want to set your own columns for the table, you can modify the _TableSchema.json_ file, and make corresponding changes to the _DCE-DCR-Template.json_ file. The DCR  An alternate version of these configuration files which only has three columns (TimeGenerated, ComputerName, and RawData), helpful for ECX log analysis, can be found [here](Scripts/Modified).
