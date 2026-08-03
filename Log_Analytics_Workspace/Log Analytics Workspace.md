# Log Analytics Workspace
An EXPRESSCLUSTER project was started in early 2023 to analyze ECX log files. One part of the project used the Log Analytics workspace feature of Azure Monitor. This project focused on an on-premises ECX cluster. The Azure Arc agent was used to connect the cluster nodes to Azure Monitor. A data collection rule was created to collect ECX log files from both nodes of the cluster and import them into a table in the Log Analytics workspace. An alert rule was then created to monitor the logs and send and email whenever error events were discovered. The details of this project (including steps to create a table, data collection rule, and alert rules) can be found [here](https://github.com/EXPRESSCLUSTER/Log-Analytics/blob/main/README.md). A link to the page on setting up a Log Analytics workspace with Azure Arc is found at the bottom of the document and also included [here](https://github.com/EXPRESSCLUSTER/Log-Analytics/blob/main/Azure_Monitor_Agent_with_Azure_Arc.md).

## Scripts
This section includes information on scripts that can simplify the setup process.

### 1. PowerShell script to create a Table in Log Analytics workspace, a Data Collection Rule (DCR) and a Data Collection Endpoint (DCE)
Bruno Gabrielli created a PowerShell script to create a table in Log Analytics workspace, a DCR and DCE. The scripts and an explanation on how to use them is included in his article titled [Azure Monitor: Gain Observability On Your DHCP Server](https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/azure-monitor-gain-observability-on-your-dhcp-server/ba-p/3865274). You need to create an Azure **Resource Group** and a **Log Analytics workspace** ahead of time, but the script will prompt you for other resource names. It even includes a template for an Azure Workbook, which you may or may not need. The scripts have been downloaded locally [here](Scripts) in a zip file. In order to run the scripts, you will need to install the AZ Powershell module \([instructions here for Windows](https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-10.2.0&tabs=powershell&pivots=windows-psgallery)\) on your system and also prepare the following names ahead of time:    

1.  _Subscription Id_
2.  _Resource Group_ name (previously created)
3.  _Log Analytics workspace_ name (previously created)    
4.  Table Name (create yourself)
5.  DCE Name (create yourself)
6.  DCR Name (create yourself)
7.  JSON Template Name (e.g. DCE-DCR-Template.json)

Once the Table, DCE, and DCR are successfully created, you will need to edit the DCR from the Azure dashboard and add your Azure Arc enabled servers as Resources, choosing the recently created DCE in the _Data collection endpoint_ field.

#### Which script files to use
This folder contains a few generations of the same template, so here's what
each one is and where to find it:

- **[`Scripts`](Scripts)** contains the original download from Bruno
  Gabrielli's article (`DHCP Custom Logs (1).zip` — includes his original
  `TableSchema.json`, `DCE-DCR-Template.json`, `ConfigureDhcpIngestion.ps1`,
  and an Azure Workbook template) alongside **`DCE-DCR-Template (fixed).json`**.
  Use the "(fixed)" version, not the one inside the zip — the original
  template hardcodes the table name to `DHCPLogs` without the required
  `_CL` suffix, which causes the DCR's Data Source to silently fail to get
  created. The "(fixed)" version uses a proper `AzTableName` parameter
  instead. See [`Scripts/Note.txt`](Scripts/Note.txt) for the full
  explanation.
- **[`Scripts/Modified`](Scripts/Modified)** contains a further customized
  version trimmed down to three columns (`TimeGenerated`, `ComputerName`,
  `RawData`), which is what's actually useful for ECX log analysis rather
  than DHCP logs. This folder has **two** DCR template variants — pick
  based on what you want ingested:
  - `DCE-DCR-Template.json` — filters to lines containing the case-sensitive
    word `ERROR` only.
  - `DCE-DCR-Template source.json` — passes the entire contents of the log
    files through, unfiltered.

  `ConfigureDhcpIngestion.ps1` in this folder is unchanged from the
  original script; despite the name, nothing DHCP-specific remains once
  you're using the trimmed `TableSchema.json` here. See
  [`Scripts/Modified/Note.txt`](Scripts/Modified/Note.txt) for details.

#### Modify .json files
If you want to set your own columns for the table, modify whichever
_TableSchema.json_ you're working from (original vs. the 3-column
`Modified` version above), and make the corresponding changes to the
matching _DCE-DCR-Template.json_ variant. The DCR data source KQL query can
also be changed — see the two options under `Scripts/Modified` above.

