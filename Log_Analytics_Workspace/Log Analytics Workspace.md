# Log Analytics Workspace
An EXPRESSCLUSTER project was started in early 2023 to analyze ECX log files. One part of the project used the Log Analytics workspace feature of Azure Monitor. This project focused on an On-premesis ECX cluster. The Azure Arc agent was used to connect the cluster nodes to Azure Monitor. A data collection rule was created to collect ECX log files from both nodes of the cluster and import them into a table in the Log Analytics workspace. An alert rule was then created to monitor the logs and send and email whenever error events were discovered. The details of this project (including steps to create a table, data collection rule, and alert rules) can be found [here](https://github.com/EXPRESSCLUSTER/Log-Analytics/blob/main/README.md). A link to the page on setting up a Log Analytics workspace with Azure Arc is found at the bottom of the document and also included [here](https://github.com/EXPRESSCLUSTER/Log-Analytics/blob/main/Azure_Monitor_Agent_with_Azure_Arc.md).

## Scripts
This section includes information on scripts that can simplify the setup process.

### 1. PowerShell script to create a Table in Log Analytics workspace, create a Data Collection Rule (DCR) and Data Collection Endpoint (DCE)
