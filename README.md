# USX-PowerShell-Automation
Based on the design, I had to change a few fundamental pieces so that the platform can be used to build automation upon different volume types and sizes. Which is why I re-booted the logic a bit. 
Script is set to work after you manually deploy USX Manager ovf . Ensure that USX manager is reachable via IP before you move further.
Also ensure that VMware powercli is installed, and for ease of use, download and install PowerGUI Editor. 
Here are the steps to unzip and make things work :-

1.	Download the “USX_Automation_2.0.zip” 
2.	It should unpack into USX_Automation
3.	Which has the following folder structure
 
4.	The Atlantis PowerShell Modules are present in the “Atlantis_Modules” folder
5.	Input_Files contains all the json files and the csv files needed (most of the customer/environment related inputs will be changed here only here, unless you want to change the underlying logic)
6.	Logs folder – contains for now “Deployment.log” that records and contains all the activities of the automation. 
7.	Backup – (we will come to this later). 
8.	Scripts folder shown below contains all the relevant scripts required for the automation
 
Scripts are named in the order/ or intended sequence of execution
1.	USX_powershell_deploy_v1.ps1 – Deploys your USX PowerShell modules into the current user directory’s folder.
2.	General_Input_File_Validation.ps1 checks all the json and csv files and makes sure that it is consistent. You will execute this every time you change the input and before you run any script. (I also do an internal check in the script, but it’s better to be careful I suppose)
3.	USX_Manager_Setup_v1.ps1 setups all the parameters required to configure the USX Manager prior to deployment of the volumes themselves.
9.	The idea here is to make the above 3 scripts as the main skeleton , upon which Volume specific scripts are controlled and deployed separately.
10.	For now “All_Flash” will work great, it deploys 3 Volumes + HA, and with some tweaking, you can make changes to deploy any no of volumes you want and enable Ha for it. 
11.	I will make changes to “Simple_All_Flash” based on the current structure (in view to complete for Jackson National ps work) 
12.	Environment-Clean-Scripts – should be used with caution, it will delete volumes, disable HA, remove orphaned VMs, remove ServiceVMs, zero the configuration of the USX Manager. 
13.	In essence you start from scratch if you ever run Environment-Clean-script. 
