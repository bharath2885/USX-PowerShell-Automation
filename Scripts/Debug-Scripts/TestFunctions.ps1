$volservicelist= Get-USXVolume | select volumeservicename
$vollist = $volservicelist.GetEnumerator() | % { $_.volumeservicename }

if (!$vollist)
	{
		Write-Log "All VMs have HA Disabled" 
		break	
	}
else
{
	foreach ($vol in $vollist)
	{
		Set-USXDisableHA -VolumeName $vol -ErrorAction:SilentlyContinue	
		Write-Log -Message "Disabling Shared HA for $vol" 
		
	}
}	
	