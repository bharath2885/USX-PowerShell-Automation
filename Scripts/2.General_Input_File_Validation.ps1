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

##Execution and validation of input files

##Testing HyperVisor CSV Input
#region
$pathtest1 = test-path $inpath1
$hyperVisors = import-csv $inpath1 | select -ExpandProperty hypervisor
if (!$hyperVisors)
{
	Write-Log "Cannot read Hypervisor csv file" -Level Error
	Exit
}
else
{
	Write-Log -Message "The Hypervisor csv file has been validated"
	
}				


#endregion

##Testing General Configuration FIle
#region
Write-Log -Message $inPath2
$pathtest2 = test-path $inPath2
$GeneralConfig = Get-Content -Raw -Path "$inPath2" | ConvertFrom-Json
if (!$GeneralConfig)
{
	Write-error "Cannot read General Configuration Json file"
	Exit
}
else
{
	Write-Log -Message "The General configuration file has been validated"
	
}
#endregion

#Testing Global Configuration file
#region

$pathtest3 = test-path $inPath3
Write-Log -Message $inPath3
$GlobalSettings = Get-Content -Raw -Path "$inPath3" | ConvertFrom-Json
if (!$GlobalSettings)
{
	Write-Log "Cannot read GlobalSettings Json file" -Level Error
	Exit
}
else
{
	Write-Log -Message "The Global configuration file has been validated" 
	
}
#endregion
#Volume configuration validation
#region

$pathtest4 = test-path $inpath4
$VolumeConfig = Get-Content -Raw -Path "$inpath4" | ConvertFrom-Json
if (!$VolumeConfig)
{
	Write-Log "Cannot read Volume Config Json file" -Level Error
	Exit
}
else
{
	Write-Log -Message "The Volume Config file has been validated" 
	
}
	
#endregion
##Ending Input validationregion

$osdisks =import-csv $inpath1 | select -ExpandProperty VMDatastore
Write-Log "VM disks being used is $osdisks"
$localflash = import-csv $inpath1 | select -ExpandProperty LocalFlashDatastore
Write-Log "LocalFlash disks being is $localflash"
