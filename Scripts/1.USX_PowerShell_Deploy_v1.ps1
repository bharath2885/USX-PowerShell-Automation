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
## At this point, we should have unzipped the contents of the Automation Script Folder
## USX_Automation is the folder name. 
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
## Execution Region
#region  

Write-Output "Current User directory is $root_dir_path"
Write-Output "Current Log File path is $Logfile"
Write-Log "test" 
##Code to copy Atlantis Modules into the right path in the local computer.
try {
	md $local_module_path -Force
		
}
catch {
	Write-Log "Cannot create directory structure, please check if the permissions are set correctly" -Level Error
	Exit 
}
Finally{
	Write-Log "Directory has been created,now copying the powershell modules over"
	Copy-Item $root_dir_path\Atlantis_Modules\Atlantis-USX.PSD1 $local_module_path -Force
	Copy-Item $root_dir_path\Atlantis_Modules\Atlantis-USX.PSM1 $local_module_path -Force
	Invoke-Item $local_module_path
}

#endregion 
