cls
Import-Module c:\Users\Administrator.VSIINFRA\Documents\WindowsPowerShell\Modules\Atlantis-USX\Atlantis-USX.PSM1 -Force
$connected = Connect-USX 10.30.10.5 admin poweruser
Remove-USXContainer