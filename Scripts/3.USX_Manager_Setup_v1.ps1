cls
<#
.NOTES 
   File Name             :<FileName of the Script>.ps1
   Author                : Bharath Nagaraj bharath@atlantiscomputing.com
   Version               : 1.0 alpha
   Support               : support@atlantiscomputing.com
   Purpose - To deploy and setup the USX PowerShell modules
   Pre-requisite: PowerShell version 4.0, VMware PowerCLI 6.5 Installed
   Nice to Have: PowerGUI Editor, Fiddler -webapi monitoring tool
#>

##Global Variables
#region
$root_dir_path="C:\USX_Automation"
$Logfile=Join-Path $root_dir_path "Logs\Deployment.log"
$current_user_doc_path = [Environment]::GetFolderPath("MyDocuments")
$local_module_path =  $current_user_doc_path + "\WindowsPowerShell\Modules\Atlantis-USX"
$inpath1 = "$root_dir_path\Input_Files\Hypervisors.csv"
$inpath2 = "$root_dir_path\Input_Files\GeneralConfig_v1.json"
$inpath3 = "$root_dir_path\Input_Files\GlobalSettings.json"
$hyperVisors = import-csv $inpath1 | select -ExpandProperty hypervisor
$GeneralConfig = Get-Content -Raw -Path "$inpath2" | ConvertFrom-Json
$GlobalSettings = Get-Content -Raw -Path "$inpath3" | ConvertFrom-Json
$osdisks =import-csv $inpath1 | select -ExpandProperty VMDatastore
$localflash = import-csv $inpath1 | select -ExpandProperty LocalFlashDatastore
$USXCluster1= "USXCluster"
#endregion
##Global Logging Function
#region
function Write-Log 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path="$Logfile", 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        Add-Content $Path "$FormattedDate $LevelText $Message `n"
    } 
    End 
    { 
    } 
}

#endregion

##Import PowerShell Module
#region
Write-Log "Importing USX PowerShell modules first"
Import-Module "$local_module_path\Atlantis-USX.PSD1" -Force
Get-Module -ListAvailable VMware.VimAutomation.Co* | import-module -Force 

#endregion


##Import variables from the General Configuration
#region
$GeneralConfig | ForEach-Object {
	$managerIp = $_."Primary USX Manager IP Address" 
	$managerUser = $_."USX Manager User"
	$managerPassword = $_."USX Manager Password"
	$vcenterName = $_."vCenter Name"
	$vcenterHost = $_."vCenter IP Address"
	$vCenterUser = $_."vCenter User" 
	$ManagementNetworkIPRange = $_."Mgmt Network IP Address Range"
	$ManagementNetworkNetmask = $_."Mgmt Network Subnet Mask"
	$StorageNetworkIPRange = $_."Storage Network IP Address Range"
	$StorageNetworkNetmask = $_."Storage Network Subnet Mask"
	$ManagementNetworkGateway = $_."Mgmt Network Default Gateway"
	$vsphereStorageNetworkName = $_."Storage Network VM PortGroup"
	$vsphereManagementNetworkName = $_."Mgmt Network VM PortGroup"
	$StorageNetwork = $_."Storage Network USX Profile Name"
	$ManagementNetwork = $_."Mgmt Network USX Profile Name"
	$volumeVMTemplate = $_."VolVM Template Prefix"
	$serviceVMTemplate = $_."SvcVM Template Prefix"
	$volumeServiceTemplate = $_."VolSvc Template Prefix"
	$FastCloneTemplate = $_."FastClone Template Prefix"
	#$USXModulePath = $_."USX PowerShell Module Path"
	}
#endregion

# Importing variables for  Global Settings
#region
	$GlobalSettings | ForEach-Object {	
    $advancedsettings= $_."Advanced Settings"
	$multicastip = $_."Multicast IP"	
	$maxmemoryallocation = $_."Max Memory Allocation"
	$maxlocaldiskallocation = $_."Max Local Disk Allocation"
	$maxlocalflashallocation = $_."Max Local Flash Allocation"
	$hypervisorlayoutsforvolume = $_."Hypervisor Layouts for Volume"
	$maxnodesperha = $_."Max Volumes per HA Node"
	$enablehypervisorreservations = $_."Enable Hypervisor Reservations"
	$enablesnapshot = $_."Enable Snapshots & Replication Default"
	$requestinterval = $_."USX Manager Info Refresh Interval"
	$prefersharedstorageforvmdisk = $_."Prefer Shared Storage for VM disk"
	$sharedstoragevmdisktype = $_."Shared Storage VM disk type"
	$preferssdforvmdisk = $_."Prefer SSD for VM disk"
	$preferflashforcapacity = $_."Prefer SSD for Data disk"
	$issharedha = $_."Shared HA"
	
	}
#endregion

##Function Region
##Function TestUSXInputs

function Test-USXInputs{
	try {
		invoke-expression $root_dir_path\Scripts\2.General_Input_File_Validation.ps1
		}
	catch{
		Write-Log "Error in input, please check all the json,csv files first"
		exit
		}
	finally
	{
		Write-Log "Input Validation is complete, Proceeding to setup USX"
	}
	
}


##Function SetUSXGlobalPref

function SetUSXGlobalPref
{
		# Setting advanced setting checkbox to true
		#Connect-USX -IPAddress $managerIp -User $managerUser -Password $managerPassword -Verbose
		
		Write-Log -Message "###################### Setting Global Advanced Setting ###################" 
		###########################
		Set-USXGlobalSetting -Deployment:advset -Value $advancedsettings
		Write-Log -Message "Setting Advanced setting on USX Manager to $advancedsettings" 
		
		# Setting multicast ip for the deployment
		Set-USXGlobalSetting -Deployment:multicastip -Value $multicastip
		Write-Log -Message "Setting Multicast IP to $multicastip" 
					
		# Change global setting to increase memory allocation to 99%
		Set-USXGlobalSetting -Configurator:maxmemoryallocation -Value $maxmemoryallocation
		Write-Log -Message "Setting Global Maximum Memory allocation to $maxmemoryallocation" 
				
		# Change global setting to increase storage allocation to 99%
		Set-USXGlobalSetting -Configurator:maxlocaldiskallocation -Value $maxlocaldiskallocation
		Write-Log -Message "Setting Global Maximum Local disk allocation to $maxlocaldiskallocation" 
		
		# Change global setting to increase storage allocation to 99%
		Set-USXGlobalSetting -Configurator:maxlocalflashallocation -Value $maxlocalflashallocation
		Write-Log -Message "Setting Global Maximum Local Flash  allocation to $maxlocalflashallocation" 
				
		# Change global setting to either 4 or 6 hosts
		Set-USXGlobalSetting -Recommender:hypervisorlayoutsforvolume -Value $hypervisorlayoutsforvolume
		Write-Log -Message "Setting HyperVisor layout for volume to $hypervisorlayoutsforvolume" 
		
		# Change global setting to either 4 or 6 hosts
		Set-USXGlobalSetting -Deployment:reservation -Value $enablehypervisorreservations
		Write-Log -Message "Setting HyperVisor reservations to $enablehypervisorreservations" 
		
		# Set Snapshot and Replication to disabled
		Set-USXGlobalSetting -Deployment:enablesnapshot -Value $enablesnapshot
		Write-Log -Message "Setting USX SnapShot mode to $enablesnapshot"		
		
		# Set USX Manager refresh Interval
		Set-USXGlobalSetting -Deployment:requestinterval -Value $requestinterval
		Write-Log -Message "Setting request interval value to $requestinterval"
		
		# Change global setting enable flash as capacity tier 
		Set-USXGlobalSetting -Recommender:prefersharedstorageforvmdisk -Value $prefersharedstorageforvmdisk
		Write-Log -Message "Setting shared storage for OS Disk setting to $prefersharedstorageforvmdisk"
		
		#Change global setting enable flash as capacity tier 
		Set-USXGlobalSetting -Recommender:shareddiskprovisioningtype -Value $sharedstoragevmdisktype
		Write-Log -Message "Setting shared storage for OS Disk setting to $sharedstoragevmdisktype"
		
		# Change global setting enable flash as capacity tier 
		Set-USXGlobalSetting -Recommender:preferssdforvmdisk -Value $preferssdforvmdisk
		Write-Log -Message "Setting SSD storage for OS Setting to $prefersharedstorageforvmdisk"
		
		# Change global setting enable flash as capacity tier 
		Set-USXGlobalSetting -Recommender:preferflashforcapacity -Value $preferflashforcapacity
		Write-Log -Message "Setting flash storage for data setting to $preferflashforcapacity"
		
		# Change global setting setting max nodes per ha
		Set-USXGlobalSetting -Recommender:maxvolumeperhacluster -Value $maxnodesperha	
		Write-Log -Message "Setting MAX Nodes per HA Cluster $maxnodesperha"
		
		# Change global setting to enable shared HA Containers
		Set-USXGlobalSetting -Recommender:ishashared -Value $issharedha
		Write-Log -Message "Setting shared HA  to $issharedha"		
		
		# Confirm global setting to set the export tyep to NFS
		Set-USXGlobalSetting -Deployment:exporttype -Value "NFS"
		Write-Log -Message "Setting Volume Export type to NFS" 
		Write-Log -Message "###################### Completed Global Settings ###################" 
										
										
}

##Function AddVMManager

function AddVMManager{
	
	
	$VMM = Get-USXVMManager
	$vCenterPassword = Read-Host "Input vCenter Password"
	try{
	$result=Add-USXVMManager -Name $vCenterName -VMManagerHostname $vCenterHost -VMManagerType:VCENTER -User $vCenterUser -Password $vCenterPassword
	}
	catch{
		Write-Log "Cannot Connect to Virtual Center $vCenterHost"
		exit
	}
	Write-Log "Connected to Virtual Center $vCenterHost"
	
}

function AddHyperVisors
{
	# In large environments it may take a little while to retrieve the
	# available hypervisors and details
	$activity = "Waiting for USX Manager to retrieve hosts from VM Manager"
	Write-Progress -Activity $activity
	Sleep -Milliseconds 5000
	Write-Progress $activity -Completed
	#Add HyperVisors
	try 
	{
		Add-USXHypervisor -VMManager $vCenterName -Name $hyperVisors -USXCluster $USXCluster1
	}
	catch 
	{
		Write-Log -Message "Adding Hypervisor failed, check your input csv to ensure the data is correct" -Level Error
		
    }

	
		Write-Log -Message "Added Hypervisors"
	
}

function AddStorage ($store)
{
	
	foreach ($disk in $store)
	{
		Add-USXStorage -Name $disk
		Write-Log -Message "Added $disk to the deployment" 
	}

}
function AddNetworkProfiles			
{
	$NetName1 = Get-USXNetwork -Name $StorageNetwork | select -ExpandProperty networkprofilename
	if (!$NetName1) 
	{
	Add-USXNetwork -Name $StorageNetwork -Type:STORAGE -AddressMode:STATIC `
		-IpRanges "$StorageNetworkIPRange" -Netmask $StorageNetworkNetmask
	
	Add-USXNetworkProfile -Name $StorageNetwork `
		-HyperVisor $hyperVisors -NetworkName $VsphereStorageNetworkName -ErrorAction:SilentlyContinue	
	}
	$NetName2 = Get-USXNetwork -Name $ManagementNetwork | select -ExpandProperty networkprofilename
	if (!$NetName2) 
	{
	Add-USXNetwork -Name $ManagementNetwork -Type:MANAGEMENT -AddressMode:STATIC `
		-IpRanges "$ManagementNetworkIPRange" -Netmask $ManagementNetworkNetmask `
		-Gateway $ManagementNetworkGateway
	
	Add-USXNetworkProfile -Name $ManagementNetwork -HyperVisor $hyperVisors `
		-NetworkName $VsphereManagementNetworkName -ErrorAction:SilentlyContinue
	}
	
	$NetName1 = Get-USXNetwork -Name $StorageNetwork | select -ExpandProperty networkprofilename
	$NetName2 = Get-USXNetwork -Name $ManagementNetwork | select -ExpandProperty networkprofilename
	
	if (!$NetName1 -or !$NetName2) 
	{
	Write-Error "Problem with Network Profiles!"
	exit
	}
	Write-Log -Message "`n Network Profiles created"
	
}	
function AddNameTemplates
{

	$TemplateName1 = Get-USXNameTemplate -Name "VolumeVMTemplate" | select -ExpandProperty templatename
	if (!$TemplateName1) 
	{
	# Add volume VM naming template
	Add-USXNameTemplate -Name "VolumeVMTemplate" -Type:VOLUME `
		-Prefix $volumeVMTemplate -NumberOfDigits 2 -StartingNumber 1				
	}
	
	$TemplateName2 = Get-USXNameTemplate -Name "ServiceVMTemplate" | select -ExpandProperty templatename
	if (!$TemplateName2) 
	{
	# Add service VM naming template
	Add-USXNameTemplate -Name "ServiceVMTemplate" -Type:SERVICE_VM `
		-Prefix $serviceVMTemplate -NumberOfDigits 2 -StartingNumber 1							
	}

	$TemplateName3 = Get-USXNameTemplate -Name "VolumeServiceTemplate" | select -ExpandProperty templatename
	if (!$TemplateName3) 
	{
	# Add Volume Service naming template
	Add-USXNameTemplate -Name "VolumeServiceTemplate" -Type:VOLUME_SERVICE `
		-Prefix $volumeServiceTemplate -NumberOfDigits 2 -StartingNumber 1							
	}
	
	$TemplateName4 = Get-USXNameTemplate -Name "FastCloneTemplate" | select -ExpandProperty templatename
	if (!$TemplateName4) 
	{	
	# Add FastClone naming template
	Add-USXNameTemplate -Name "FastCloneTemplate" -Type:FASTCLONE `
		-Prefix $FastCloneTemplate -NumberOfDigits 2 -StartingNumber 1	
	}
	
	$TemplateName1 = Get-USXNameTemplate -Name "VolumeVMTemplate" | select -ExpandProperty templatename
	$TemplateName2 = Get-USXNameTemplate -Name "ServiceVMTemplate" | select -ExpandProperty templatename
	$TemplateName3 = Get-USXNameTemplate -Name "VolumeServiceTemplate" | select -ExpandProperty templatename
	$TemplateName4 = Get-USXNameTemplate -Name "FastCloneTemplate" | select -ExpandProperty templatename

	if ($TemplateName1 -ne "VolumeVMTemplate" -or $TemplateName2 -ne "ServiceVMTemplate" -or $TemplateName3 -ne "VolumeServiceTemplate" -or $TemplateName4 -ne "FastCloneTemplate") 
	{
	Write-Error "Problem with Name Templates! "
	exit
	}
	Write-Log -Message "Last Step : Name Templates created"
	
}	


##Execution Area
Test-USXInputs
try{
$connected=Connect-USX -IPAddress $managerIp -User $managerUser -Password $managerPassword -Verbose
}
catch
{
	Write-Log "Not Connected to USX Manager"
	exit
}
if ($connected)
{
	AddVMManager
	SetUSXGlobalPref
	AddHyperVisors
	AddStorage($localflash)
	AddNetworkProfiles
	AddNameTemplates
}

