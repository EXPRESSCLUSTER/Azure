# On-Premise EXPRESSCLUSTER Windows VM Migration to Azure

Migrating an EXPRESSCLUSTER on-premise Windows VM cluster to Azure cloud requires several pre-migration steps and post-migrations steps in order to make a smoother transition. This guide provides those important steps. Please note that the location to find the Windows settings for a specific task are listed below the step name. If there is a script to perform that task, it is listed in brackets next to the step. Manual instructions for most tasks are included below the step. All included scripts should be run with elevated privileges.

## Before Migration - perform on both servers

1.	Run System File Checker from the command prompt to find any integrity issues:
```
       C:\sfc.exe /scannow
```
2.	Install Windows Updates and restart servers.

       *Settings->Update & Security*

3.	Enable RDP (optional) \[[Enable RDP.bat](Scripts/01%20Enable%20RDP.bat)\]

       *Settings->System->Remote Desktop->Enable Remote Desktop*
    
       Enable RDP if remote access to the server is required. If RDP is enabled, it is also recommended to change the power settings to keep the PC awake and discoverable to facilitate connections.

4.	Set the SAN policy for newly discovered disks to *onlineall* \[[Set SAN Policy.bat](Scripts/02%20Set%20SAN%20Policy.bat)\]
	```
       C:\diskpart
       DISKPART> san policy=onlineall
       DISKPART> exit
	```
    This setting ensures that disks are brought online after migration, and that both disks can be read and written to. If this step is omitted, the mirror disks on the Azure VM will need to be set Online before starting the EXPRESSCLUSTER cluster services.

5.	Change service startup types from "Automatic" to "Manual" \[[Setsrvcman.bat](Scripts/03%20Setsrvcman.bat)\]

       ECX services:  Run "***clpsvcctrl.bat --disable -a***" from a command prompt.

       *clpsvcctrl.bat is located in the ECX bin folder and is in the Windows path.

       SQL Server services – should be already set to manual.

6.	Remove **FIP** or **VIP** resources using the **Cluster WebUI**.

       Launch the **EXPRESSCLUSTER WebUI**. Change to **Config Mode** and remove the resource.

7.	Shut down the On-premise VMs \[[ECX Shutdown.bat](Scripts/04%20ECX%20Shutdown.bat)\]

       Shut down from the EXPRESSCLUSTER WebUI or execute the command *clpstdn.exe*.

------

## Perform Migration

------
## Post Migration - Perform the following steps on both Azure VM servers

1.	Turn on Azure VMs if not automatically started and connect to both VMs.

2.	Enable Network Discovery (optional).

       Log in, and when prompted, click **Yes** to allow your PC to be discoverable by other PCs. If you miss this opening dialog, turn network discovery on in *Network and Sharing Center*. \[[Enable Discovery.bat\]](Scripts/06%20Enable%20Discovery.bat)

       *Settings->Network & Internet->Network and Sharing Center->Change advanced sharing settings*

3.	Confirm that the mirror disk is online in Disk Management.

       *Computer Management->Disk Management*

4.	Change IP addresses in **CLP.CONF** for both servers and mdcs on each server (if new IP addresses were assigned).    
       \*Create a backup of CLP.CONF first \[[*cfset.bat \<server name\> \<lan\&mdc pos.\> \<IP address\>*](Scripts/07%20cfset.bat)\]

       Use the tool *clpcfset.exe* located in the EXPRESSCLUSTER\bin folder to simplify the process. Change the current directory to C:\Program Files\EXPRESSCLUSTER\etc. 

       Example (assuming one lan and one mirror disk):
	```
       clpcfset add device server1 lan 0 192.168.0.10
       clpcfset add device server1 mdc 0 192.168.0.10
       clpcfset add device server2 lan 0 192.168.0.20
       clpcfset add device server2 mdc 0 192.168.0.20
	```
    *modify with your server names and IP addresses.

5.	REPEAT steps 1 – 4 on the other server before continuing

6.	Start the ECX services on BOTH servers \[[StartECXsrvc.bat](Scripts/08%20StartECXsrvc.bat)\]

       *When services start, the cluster should also start automatically. Also note that the EXPRESSCLUSTER API service may start and then stop after starting since it is "not in use".

7.	Change altered services startup types from "Manual" back to "Automatic" in Services Manager on BOTH servers. \[[Setsrvcauto.bat](Scripts/09%20Setsrvcauto.bat)\]

       ECX services:  Run "***clpsvcctrl.bat --enable -a***" from a command prompt.

       *The batch file is located in the ECX bin folder and is in the Windows path.

       SQL services startup type can be left as manual.

## Verification steps - Run on the primary Azure VM server

1.	Start the **Cluster WebUI** to view the cluster status. Change to the **Status** tab.

2.	Start the Cluster (if it hasn't started yet).

3.	Add the **Azure probe port resource**, the Azure version of the VIP resource, to the failover group.
