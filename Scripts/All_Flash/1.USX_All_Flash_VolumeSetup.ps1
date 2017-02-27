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

#endregion
# Path to Input files
#region
$inpath1 = "$root_dir_path\Input_Files\Hypervisors.csv"
$inPath2 = "$root_dir_path\Input_Files\GeneralConfig_v1.json"
$inPath3 = "$root_dir_path\Input_Files\GlobalSettings.json"
$inpath4 = "$root_dir_path\Input_Files\VolumeConfig.json"

#endregion
# Import Volume Variables
	$VolumeConfig | ForEach-Object {
	$VolType = $_."USX Volume Type"
	$VolExportType = $_."USX Volume Export Type"
	$SharedHAProperty = $_."USX Volume Shared HA"
	$NFSSyncSetting = $_."NFS Sync Setting"
	$VolSize = $_."USX Volume SizeGB"
	$USXVOL1 = $_."USX Volume1 Name"
	$USXVOL2 = $_."USX Volume2 Name"
	$USXVOL3 = $_."USX Volume3 Name"
	
	}
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


##Function Area
function CreateUSXVolume($USXVOLNAME)
{
	
		try {
			Add-USXVolume -Type:$VolType -Name $USXVOLNAME -ExportType:$VolExportType -VolumeVMTemplate "VolumeVMTemplate" -ServiceVMTemplate "ServiceVMTemplate" -SizeGB $VolSize -ManagementNetwork $ManagementNetwork -StorageNetwork $StorageNetwork -PreferFlashForCapacity -NFSSync:$true
		}
		catch{
			Write-Log "Error setting up volume $USXVOLNAME"
		}
		Wait-USXStatus –name $USXVOLNAME
		
		
}


function EnableHAforVolume($USXVOLNAME)
{
	
		Set-USXEnableHA -VolumeName $USXVOLNAME -IsHAShared:$true
		Sleep 30 
}

##Execution Area

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
			CreateUSXVolume($USXVOL1)
			CreateUSXVolume($USXVOL2)
			CreateUSXVolume($USXVOL3)
			##Enable HA
			Sleep 30
			EnableHAforVolume($USXVOL1)
			Sleep 30
			EnableHAforVolume($USXVOL2)
			Sleep 30
			EnableHAforVolume($USXVOL3)
	
}