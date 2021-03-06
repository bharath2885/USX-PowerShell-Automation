<#
.NOTES 
   File Name   : Atlantis-USX.psm1 
   Authors     : Remko Weijnen @remkoweijnen, Jim Moyle @jimmoyle and Hugo Phan @hugophan
   GitHub o    : https://github.com/atlantis-computing/powershell
   
   Changelist, legend is # for changes, + for add, - for removal. All dates are in YYYYMMDD
 
   * 20160202 RW: Changelist above is deprecated in favour of commit notes in SVN
#>
if (-not ([System.Management.Automation.PSTypeName]'System.Web.HttpUtility').Type)
{
	Add-Type -AssemblyName "System.Web"
}

if (-not ([System.Management.Automation.PSTypeName]'USX.VOLUME.TYPE').Type)
{
	Add-Type @"
		namespace USX.VOLUME
		{
			public enum TYPE
			{
				HYBRID,
				HYPERCONVERGED,
				ALL_FLASH,
				MEMORY
			};

			public enum SIMPLE
			{
				SIMPLE_HYBRID,
				SIMPLE_MEMORY,
				SIMPLE_FLASH			
			};
			
			public enum EXPORTTYPE
			{
				NFS,
				iSCSI
			};
		
		}
"@
}

if (-not ([System.Management.Automation.PSTypeName]'USX.VMManager').Type)
{
	Add-Type @"
		namespace USX
		{
			public enum VMManager
			{
				VCENTER,
				SCVMM,
				XENSERVER
			};
		}
"@
}

if (-not ([System.Management.Automation.PSTypeName]'USX.SIMPLEVolume').Type)
{
	Add-Type @"
		namespace USX
		{
			public enum SIMPLEVolume
			{
				SIMPLE_HYBRID,
				SIMPLE_MEMORY,
				SIMPLE_FLASH			
			};
		}
"@
}

if (-not ([System.Management.Automation.PSTypeName]'USX.NameTemplate').Type)
{
	Add-Type @"
		namespace USX
		{
			public enum NameTemplate
			{
				SERVICE_VM,
				VOLUME,
				VOLUME_SERVICE,
				FASTCLONE
			};
		}
"@
}

if (-not ([System.Management.Automation.PSTypeName]'USX.Network').Type)
{
	Add-Type @"
		namespace USX
		{
			public enum Network
			{
				STORAGE,
				MANAGEMENT
			};
		}
"@
}

if (-not ([System.Management.Automation.PSTypeName]'USX.PluginTarget').Type)
{
	Add-Type @"
		namespace USX
		{
			public enum PluginTarget
			{
				VOLUMES,
				SERVICEVMS,
				MANAGERS,
				USX
			};
		}
"@
}

if (-not ([System.Management.Automation.PSTypeName]'USX.Network.Type').Type)
{
	Add-Type @"
		namespace USX.Network
		{
			public enum Type
			{
				STORAGE,
				MANAGEMENT
			};
			
			public enum AddressMode
			{
				STATIC,
				DHCP
			}
		}
"@
}

if (-not ([System.Management.Automation.PSTypeName]'USX.Tag.Type').Type)
{
	Add-Type @"
		namespace USX.Tag
		{
			public enum Type
			{
				USX_SITE,
				USX_CLUSTER,
				USX_NETWORK
			};
			
		}
"@
}


if (-not ([System.Management.Automation.PSTypeName]'USX.Settings.RECOMMENDER').Type)
{
	Add-Type @"
		namespace USX.Settings
		{
			public enum SNMPCONFIG
			{
			    snmpport,
			    snmpcommunity,
			    snmphost,
				sysContact,
				enable,
				sysLocation,
				sysName,
				snmp,
				sysDesc,
				snmpAgentPort,
				key,
			};
			
			public enum LICENSEACTIVATION
			{
			    licenseactivationurl
			};			
			
			public enum RECOMMENDER			
			{
			    prefersharedstorageforexport,
			    preferssdforvmdisk,
			    raid0minimumhypervisors,
			    preferflashforcapacity,
			    preferscaleup,
			    raid5minimumhypervisors,
			    hybridratio,
			    minlocaldiskexportsize,
			    shareddiskprovisioningtype,
			    systemreserveonflash,
			    rawdisksizeratio,
			    systemreserveondisk,
			    prefersharedstorageforvmdisk,
			    diskmaxsize,
			    systemreserveonmemory,
			    numhanodes,
			    preferflashformemory,
			    hyperconvergedvolume,
			    hanodemaxmemorydiff,
			    includealllocalstorage,
			    localdiskprovisioningtype,
			    minlocaldiskcapacityrequired,
			    minlocaldiskallocationsizerequired,
			    infrastructurevolumesize,
			    includeallsharedstorage,
			    infrastructurevolumenameprefix,
			    maximizeresilience,
			    hypervisorlayoutsforvolume,
			    ishashared,
				maxvolumeperhacluster,
				vmdiskprovisioningtype,
			    preferflasharrayformemory
			};
			
			public enum CONFIGURATOR
			{
				maxlocalflashallocation,
    			maxmemoryallocation,
				maxlocaldiskallocation
			};

			public enum DEPLOYMENT
			{
			    volumemountoption,
				memorychunksize,
			    ssdalternative,
			    fastsync,
			    exporttype,
			    capacitychunksize,
			    volumememory,
			    multicastip,
			    configurednumofcore,
			    servicevmnumcpus,
			    flashbitmap,
			    configfile,
			    flashchunksize,
			    numberofworkers,
			    servicevmmemory,
			    reservation,
			    advset,
			    directio,
			    capacitybitmap,
			    memorybitmap,
			    deploystandbyalways,
			    requestinterval,
			    debugmode,
			    volumenumcpus,
				infrastructureenabblesnapshot,
				simplevolumememory,
				preferavailability,
				enablevvol,
				licenseexceededwarn,
				stretchcluster,
				raid1enabled,
				tiebreakerip,
				enablesnapshot
			};
			
			public enum INSIGHT
			{
				enableanonymizer
			};
			
			public enum GENERALUSXMANAGERCONFIG
			{
				s3notificationenabled,
				licenseexceededwarn,
				helpcenterurl
			};
		}
"@
}

function UsxDelete([string]$Url, $Data)
{
	return UsxHttpOperation $url "DELETE" $Data
}

function UsxPost([string]$Url, $Data)
{
	return UsxHttpOperation $Url "POST" $Data
}

function UsxPut([string]$Url, $Data)
{
	return UsxHttpOperation $Url "PUT" $Data
}


function IsUSXUUID([String[]]$Id)
{
	if (!$Id)
	{
		return $false
	}
	
	ForEach ($item in $Id)
	{
		if (!($item -match 'USX_[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}'))
		{
			return $false
		}
	}
	
	return $true
}

function IsValidUrl([string]$Url) 
{ 
 	$uri = $Url -as [System.URI] 
    return $uri.AbsoluteURI -ne $null -and $uri.Scheme -match '(http|https)'
} 

# wrapper function to use the POST or PUT method to USX and return data
function UsxHttpOperation
{
	param(
		[Parameter(Position=0, Mandatory=$true)]
 		[ValidateScript({ IsValidUrl $_ })] 	    
		[System.String]$Url,

		[Parameter(Position=1, Mandatory=$true)]
	    [ValidateSet('DELETE','POST','PUT')]
	    [System.String]$Method,
		
		[Parameter(Position=2, Mandatory=$false)]
	    $Data
	)
	
	# $Data can be null (if no data has to be supplied in body)
	if ($Data)
	{
		if ($Data -is [HashTable] -or [Object])
		{
			# convert data to JSON
			$json = ConvertTo-Json $Data
			Write-Debug "Passing JSON to $Url"
			Write-Debug $json
		}
		else
		{
			$json = $data
		}
	}
	else
	{
		$json = $null
	}
	
	# create webrequest
	$request = [Net.WebRequest]::Create($Url)

	# set keep-alive and Cookie Container
	$request.KeepAlive = $true
	$request.CookieContainer = $script:cookieJar
	
	# sometimes we get "The underlying connection was closed: The connection was closed unexpectedly Exception"
	# this makes it go away
	$request.ServicePoint.Expect100Continue = $false
	
	$request.Method = $method
	if ($json)
	{
		# convert json data to byte array
		$bytes = [System.Text.Encoding]::ASCII.GetBytes($json)
		
		# set header
		$request.ContentType = "application/json"
		$request.ContentLength = $bytes.Length

		try
		{
			# write byte array to request stream
			$requestStream = [System.IO.Stream]$request.GetRequestStream()
			$requestStream.write($bytes, 0, $bytes.Length)
		}
		catch
		{
			$stack = Get-PSCallStack | select -Index 2
			$ex = $_
			while ($ex.Exception.InnerException)
			{
		   		$ex = $ex.Exception.InnerException
		    }
			
			Throw "$($Stack.Command): $($ex.Message)" 
		}
	}
	# fire away
	try
	{
		$response = $request.GetResponse()
		
		
	Write-Debug "HTTP Response: $($response.StatusCode)"
	# check result
	if ($response.StatusCode -eq "OK")
	{
		# get response data
		$dataStream = $response.GetResponseStream()
		$reader =  New-Object System.IO.StreamReader($dataStream);
		$responseFromServer = $reader.ReadToEnd();
		
		# convert from json to powershell object
		Write-Debug "Received from USX Manager:"
		Write-Debug $responseFromServer
		$result = $responseFromServer | ConvertFrom-Json
		
		# close & cleanup
		$reader.Close()
	    $dataStream.Close()
		$response.Close()
	}
	else
	{
		# return error description
		$result = $response.StatusDescription
	}

	# return result
	return $result
	}
	catch #[system.exception]
	{
		
		$stack = Get-PSCallStack | select -Index 2
		$ex = $_
		while ($ex.Exception.InnerException)
		{
	   		$ex = $ex.Exception.InnerException
	    }
		
		if ($ex -is [System.Net.WebException])
		{
			$response = $ex.response
            # get response data
            $dataStream = $response.GetResponseStream()
            $reader =  New-Object System.IO.StreamReader($dataStream);
            $responseFromServer = $reader.ReadToEnd();
            
            # $response
            # convert from json to powershell object
            if ($response.ContentType -eq 'application/json')
			{
				$result = ConvertFrom-Json $responseFromServer
			}
			else
			{
				$result = $responseFromServer
			}
            
            # close & cleanup
            $reader.Close()
          	$dataStream.Close()
            $response.Close()

			Throw "$($Stack.Command) $($Stack.Arguments): $result"
		}
		else
		{
			Write-Error "#Todo: wrap this exception type!"
			Throw $ex
		}
	   
	}
}

# wrapper function to use the GET method from USX and return data
function UsxGet([string]$Url)
{
	# create webrequest
	Write-Debug "HTTP Get to $url"
	$request = [Net.WebRequest]::Create($url)
	
	# sometimes we get "The underlying connection was closed: The connection was closed unexpectedly Exception"
	# this makes it go away
	$request.ServicePoint.Expect100Continue = $false
	
	# set keep-alive and Cookie Container
	$request.KeepAlive = $true
	$request.CookieContainer = $script:cookieJar
	
	# fire away
	try
	{	
		$response = $request.GetResponse()
		Write-Debug "HTTP Response: $($response.StatusCode)"
		
		# check result
		if ($response.StatusCode -eq "OK")
		{
			# get response data
			$dataStream = $response.GetResponseStream()
			$reader =  New-Object System.IO.StreamReader($dataStream);
			$responseFromServer = $reader.ReadToEnd();
			
			Write-Debug "USX Manager returned:`n $responseFromServer"
			# convert from json to powershell object
			
			$result = $responseFromServer | ConvertFrom-Json
			
			# close & cleanup
			$reader.Close()
		    $dataStream.Close()
			$response.Close()
		}
		else
		{
			# return error description
			$result = $response.StatusDescription
			
			Write-Debug "HTTP StatusDescription: $result"
		}

		# return result
		if ($result.count -eq 0)
		{
			$stack = Get-PSCallStack  | select -Index 1
			Write-Warning "$($stack.Command): Query did not return any results"
		}
		elseif ($result.count -ge $script:USXCredentials.PageSize)
		{
			$stack = Get-PSCallStack | select -Index 1		
			Write-Warning "$($stack.Command): Query returned $($result.count) items while PageSize is $($script:USXCredentials.PageSize).`nMore items may exist!"
		}

		return $result
	}
	catch 
	{
		# todo: handle nicely
		Write-Error $_
		
	}
}

function IgnoreInvalidCertificates()
{
	if (-not ([System.Management.Automation.PSTypeName]'TrustAllCertsPolicy').Type)
	{

		Write-Verbose "Installing Invalid SSL Certificate Handler"

		Add-Type -TypeDefinition @"
	    using System.Net;
	    using System.Security.Cryptography.X509Certificates;
	    public class TrustAllCertsPolicy : ICertificatePolicy {
	        public bool CheckValidationResult(
	            ServicePoint srvPoint, X509Certificate certificate,
	            WebRequest request, int certificateProblem) {
	            return true;
	        }
	    }
"@

	}

	[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}



<#
	.Synopsis
		Connects to the USX Manager
	
	.Description
		Connects to the the USX Manager with cleartext credentials and returns a (temporary)
		api key that will be used in subsequent operations
	
	.PARAMETER Name
		DNS Hostname or IP Address of an USX Manager
	
	.PARAMETER User
		Username for USX Manager
	
	.PARAMETER Password
		Password for USX Manager
	
	.PARAMETER PageSize
		When querying data from USX Manager the PageSize parameter is used to limt the amount of items returned. This will improve performance with large datasets
	
	.PARAMETER Port
		TCP port used to connect to USX Manager
	
	.Example
		$IsConnected = Connect-USX -Name "192.168.3.1" -User "admin" -Password 'poweruser'
	
	.Example
		$IsConnected = Connect-USX -Name "usxmanager01" -User "admin" -Password 'poweruser'
		#Requires-Version 3.0
	
	.NOTES
		Additional information about the function.
#>
function Connect-USX
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   Position = 0)]
		[Alias('IPAddress')]
		[string]$Name,
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $false,
				   Position = 1)]
		[string]$User,
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $false,
				   Position = 2)]
		[string]$Password,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 3)]
		[int]$PageSize = 100,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 4)]
		[int16]$Port = 8443
	)
	
	#end param
	if ($PageSize -gt 100)
	{
		Write-Warning "Using a large pagesize might result in slow(er) queries, you currently have set the PageSize to $PageSize"
	}
	
	Write-Verbose "Connecting to USX Manager $($Name) on Port $($Port) with PageSize $($PageSize)"
	
	IgnoreInvalidCertificates
	
	# when using a temp api_key, cookies are required!
	$script:cookieJar = New-Object System.Net.CookieContainer
	
	# Get a temporary key from the USX REST API service
	$tempKey = $true.ToString().ToLower()
	
	
	$builder = New-Object System.UriBuilder("https", $Name, $Port, "usxmanager/user/login")
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["istempkey"] = $tempKey
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	$data = @{
		"username" = "$($User)";
		"password" = "$($Password)"
	}
	
	$result = UsxPut $url $data
	
	$script:USXConnectInfo = $result.ServerInfo
	Write-Verbose $USXConnectInfo
	
	$properties = @{
		"Name" = $Name;
		"Username" = $User;
		"Password" = $Password;
		"PageSize" = $PageSize
	}
	$script:USXCredentials = New-Object –TypeName PSObject –Prop $properties
	
	return ![String]::IsNullOrWhiteSpace($script:USXConnectInfo.amcip)
}

function Disconnect-USX
{
<#
.Synopsis
Disconnects from the USX Manager
.Description
Disconnect from the USX Manager
.Example
Disconnect-USX
#Requires-Version 3.0
#>
[CmdletBinding()]
param()
	Write-Debug "Enter Disconnect-USX"

	$script:USXConnectInfo = $null
	$script:cookieJar = $null
	Write-Verbose "Disconnected from USX Manager"

	Write-Debug "Leave Disconnect-USX"
}
function Get-USXDataStore
{
<#
.Synopsis
Gets a USX DataStore
.Description
Get all USX Datastores, or one datastore when using the -Name parameter
.Example
$DataStores = Get-USX DataStore
$DataStore = Get-USXDataStore -Name "My Datastore"
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
	    [String]$Name
	)

	$dataStores = @()
	$hyperVisors = Get-USXHyperVisor
	
	ForEach ($hyperVisor in $hyperVisors)
	{
		if ($Name)
		{
			$datastore = $hyperVisor.datastores | where { $_.datastorename -eq $Name }
			
			if ($datastore)
			{
				return $datastore
			}
		}
		else
		{
			$dataStores += $hyperVisor.datastores
		}
	}

	return $dataStores
}

<#
	.SYNOPSIS
		Adds Active Directory Integration to USX Manager
	
	.DESCRIPTION
		Adds Active Directory Integration to USX Manager, at this time only non ssl connection is supported and default port 389 is used
	
	.PARAMETER DomainController
		Domain Controller to be used for querying Active Directory
	
	.PARAMETER Username
		Username (SamAccoutnName) of a service account that can be used to query Active Directory (note: admin permissions are not required)
	
	.PARAMETER Password
		Password for the AD Service Account
	
	.PARAMETER Groupname
		Active Directory Groupname
	
	.NOTES
		Additional information about the function.
#>
function Add-USXADIntegration
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 0)]
		[string]$DomainController,
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$Username,
		[Parameter(Mandatory = $true,
				   Position = 2)]
		[string]$Password,
		[Parameter(Position = 3)]
		[string]$Groupname = '*'
	)
	
	BEGIN
	{
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	}
	
	PROCESS
	{
		$AuthenticationType = [System.DirectoryServices.AuthenticationTypes]::Secure -bor [System.DirectoryServices.AuthenticationTypes]::ServerBind
		$rootDsePath = "LDAP://$DomainController/rootDSE"
		$rootDse = New-Object System.DirectoryServices.DirectoryEntry($rootDsePath, $Username, $Password, $AuthenticationType)
		$domainPath = $rootDse.Properties["defaultNamingContext"].Value
		
		$de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$DomainController/$domainPath", $Username, $Password, $AuthenticationType)
		$ds = New-Object System.DirectoryServices.DirectorySearcher($de)
		
		$ds.Filter = "(&(objectClass=user)(sAMAccountname=$Username))"
		$user = $ds.FindOne().GetDirectoryEntry()
		
		$regex = [RegEx]::Match(($user | select -ExpandProperty parent), '.+/(?<dn>.*)')
		$data = @{
			"binddn" = $domainPath
			"ssl" = $false
			"ipaddress" = $DomainController
			"systembinddn" = $regex.Groups["dn"].Value
			"systemusername" = $user | select -ExpandProperty cn
			"systempassword" = $Password
			"port" = "389"
		}
		if ($GroupName -ne '*')
		{
			$ds.Filter = "(&(objectClass=group)(sAMAccountname=$GroupName))"
			$group = $ds.FindOne().GetDirectoryEntry()
			$data["groupdn"] = $group | select -ExpandProperty distinguishedname
		}
		else
		{
			$data["groupdn"] = '*'
		}
		
		
		$builder = USXGetBuilder "usxmanager/user/auth/ldap"
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["format"] = "json"
		$builder.Query = $query.ToString();
		
		$url = $builder.ToString()
		
		return UsxPost -Url $Url -Data $data
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}
}

function Get-USXManager
{
<#
.Synopsis
Get USX Manager
.Description
Get all USX Managers or a specific Manager by name using the -Name parameter
.Example
Get-USXManager
.Example
Get-USXManager -Name "My Manager"
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
	    [String]$Name
	)

	$builder = USXGetBuilder "usxmanager/usxmanager"
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	if ($Name)
	{
		return $result.items | where { $_.displayname -eq $Name }
	}
	else
	{
		return $result.items
	}
}


function Get-USXSnapshot
{
<#
.Synopsis
Get USX Snapshot
.Description
Get all USX Snapshots or a specific Snapshot by name using the -Name parameter
.Example
$Tags = Get-USXSnapshot
.Example
$Tag = Get-USXSnapshot -Name "My Snapshot"
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
	    [String]$Name
	)

	$builder = USXGetBuilder "usxmanager/usx/dataservice/snapshots"
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	if ($Name)
	{
		return $result.items | where { $_.displayname -eq $Name }
	}
	else
	{
		return $result.items
	}
}

<#
	.Synopsis
		Get USX Tags
	
	.Description
		Get alerts from USX Manager
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.Example
		$Tags = Get-USXTag
	
	.Example
		$Tag = Get-USXTag -Name "My Tag"
		#Requires-Version 3.0
	
	.NOTES
		Additional information about the function.
#>
function Get-USXAlert
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $true,
				   Position = 0)]
		[String]$Name
	)
	
	$builder = USXGetBuilder "usxmanager/alerts"
	
	if ($Name)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[tagname='$($Name)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$builder.Query = $query.ToString();
	}
	
	$url = $builder.ToString()
	
	$rawResult = USXGet -Url $Url
	
	$result = $rawResult.items | Select-Object uuid, checkId, usxuuid, usxtype, displayname, value, target, warn, error, oldStatus, status, description, service, alertTimestamp, @{ n = "alertTime"; e = { ConvertFrom-UsxTimeStamp $_.alertTimeStamp } }, reviewstatus, iliotype, version, datacenteruuid, regionuuid, tenantuuid, taguuids, attributes, chassisuuid
	
	return $result
}

function Get-USXTag
{
<#
.Synopsis
Get USX Tags
.Description
Get all USX Tags or a specific Tag by name using the -Name parameter
.Example
$Tags = Get-USXTag
.Example
$Tag = Get-USXTag -Name "My Tag"
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
	    [String]$Name
	)

	$builder = USXGetBuilder "usxmanager/tags"

	if ($Name)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[tagname='$($Name)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$builder.Query = $query.ToString();
	}
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url	
	return $result.items
}


function Remove-USXTag
{
<#
.Synopsis
Remove USX Tag(s)
.Description
Removes one or more USX Tags from USX Manager
.Example
Remove the USX Tag named "MyTag"
Remove-USXVMManager -Name "MyTag"
Remove all VM Tags
Remove-USXTag
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("tagname")]
		[Alias("uuid")]
		[String[]]$Name
	)
    
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
    
	PROCESS 
	{	
	
		if (-not $Name)
		{
			Get-USXTag | Remove-USXTag
		}
		
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"	
			
			if ($PsCmdlet.ShouldProcess($item))
			{
				Write-Debug "Deleting $item" 
				$tag = Get-USXTag $item
				$builder = USXGetBuilder "usxmanager/tags/$($tag.uuid)"
				$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
				$query["format"] = "json"
				$builder.Query = $query.ToString();
				
				$url = $builder.ToString()
			  
				UsxDelete -Url $Url	
			}
		}
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}	
}

function Add-USXTag
{
	param(
		[Parameter(	Mandatory = $true, 
			Position = 0,
			ValuefromPipeline=$true,
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Name(s) of the Tags')]
		[Alias('tagname')]
		[String[]]$Name,

		[Parameter(	Mandatory = $true, 
			Position = 1,
			HelpMessage = "Enter the USX Tag type")]
		[USX.Tag.Type]$Type,
		
		[Parameter(	Mandatory = $false, 
			Position = 2,
			HelpMessage = "Enter the USX Site Number for this tag (1 or 2)")]
		[ValidateSet(1, 2)]
		[int]$SiteNumber
	)
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
	PROCESS 
	{	
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"		
			$data =  @{
				"tagtype" = $Type.ToString();
				"tagname" = $item;
			}

			if ($Type -eq [USX.Tag.Type]::USX_SITE)
			{
				$SiteId = "site_$SiteNumber"
				
				$data["tagattributes"] = @{"attributes" = @{
					"ui_site_id" = $SiteId;}}
			}
		
			$builder = USXGetBuilder "usxmanager/tags"
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			$query["format"] = "json"
			$builder.Query = $query.ToString();
			
			$url = $builder.ToString()
			
			$result = UsxPost -Url $Url -Data $data

			$result
		}
	}
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}		
}


function Mount-USXVolume
{
<#
.Synopsis
 Mount volume
.Description
 Mount volume
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
	    [Parameter(Position=0, Mandatory=$true)]
	  	[String]$Name,

        [Parameter(Position=1, Mandatory=$true, ValuefromPipeline=$true, ValuefromPipelineByPropertyName = $true)]
		[Alias("hypervisorname")]
		[String[]]$Hypervisor,
		
		[Parameter(
			 Position = 2,
			 Mandatory = $false,
			 ValueFromPipelineByPropertyName = $true,
			 ValueFromPipeline = $false,
			 HelpMessage = "Enter true or Flase if the Volume is shared (useful for XenServer)")]
		[boolean]$Shared = $true
 
    )     
 	
	$volume = Get-USXVolume -Name $Name
	
    $data = @{
        "volumeresourceuuid" = $($Volume.uuid);
        "hypervisornames" = $Hypervisor;
		"datastorename" = $($Name);
		"shared" = $Shared
	}
	
	$builder = USXGetBuilder "usxmanager/usx/deploy/mount"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	$result = USXPost -Url $Url -Data $data
	return $result
}

function Get-USXGlobalSetting
{
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
			ParameterSetName = "DEPLOYMENT")]
	    [USX.Settings.DEPLOYMENT]$Deployment,

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
           ParameterSetName = "CONFIGURATOR")]
	    [USX.Settings.CONFIGURATOR]$Configurator,

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
           ParameterSetName = "RECOMMENDER")]
	    [USX.Settings.RECOMMENDER]$Recommender,

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
           ParameterSetName = "SNMPCONFIG")]
	    [USX.Settings.SNMPCONFIG]$SnmpConfig,

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
           ParameterSetName = "LICENSEACTIVATION")]
	    [USX.Settings.LICENSEACTIVATION]$LicenseActivation
	)	

	Write-Debug "Enter Get-USXGlobalSetting"
	$key = $PsCmdlet.ParameterSetName
	switch ($PsCmdlet.ParameterSetName)
	{
		"DEPLOYMENT" { $entry = $Deployment.ToString(); break }
		"CONFIGURATOR" { $entry = $Configurator.ToString(); break }
		"RECOMMENDER" { $entry = $Recommender.ToString(); break }
		"LICENSEACTIVATION" { $entry = $LicenseActivation.ToString(); break }
		"SNMPCONFIG" { $entry = $SnmpConfig.ToString(); break }
	}

	
	$builder = USXGetBuilder "usxmanager/settings/$($key)"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	Write-Verbose "Url: $url"

	$result = UsxGet $url | select -ExpandProperty $Entry
	
	Write-Verbose "Result: $result"
	Write-Debug "Leave Get-USXGlobalSetting"
	return $result #| select -ExpandProperty $Entry
}


function Set-USXGlobalSetting
{
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
			ParameterSetName = "DEPLOYMENT")]
	    [USX.Settings.DEPLOYMENT]$Deployment,

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
           ParameterSetName = "CONFIGURATOR")]
	    [USX.Settings.CONFIGURATOR]$Configurator,

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
           ParameterSetName = "RECOMMENDER")]
	    [USX.Settings.RECOMMENDER]$Recommender,

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
           ParameterSetName = "SNMPCONFIG")]
	    [USX.Settings.SNMPCONFIG]$SnmpConfig,

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
           ParameterSetName = "LICENSEACTIVATION")]
	    [USX.Settings.LICENSEACTIVATION]$LicenseActivation,

		[Parameter(Mandatory=$true, Position=1, valuefromPipeline=$false)]
	    [System.String]$Value
	)	

	Write-Debug "Enter Set-USXGlobalSetting"
	$key = $PsCmdlet.ParameterSetName
	switch ($PsCmdlet.ParameterSetName)
	{
		"DEPLOYMENT" { $entry = $Deployment.ToString(); break }
		"CONFIGURATOR" { $entry = $Configurator.ToString(); break }
		"RECOMMENDER" { $entry = $Recommender.ToString(); break }
		"LICENSEACTIVATION" { $entry = $LicenseActivation.ToString(); break }
		"SNMPCONFIG" { $entry = $SnmpConfig.ToString(); break }
	}

	
	Write-Verbose "Setting $($entry) to $($value) for microservice $($key)"
	$builder = USXGetBuilder "usxmanager/settings/$($key)"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["entry"] = $Entry

	$boolValue = $false
	if ([Boolean]::TryParse($Value, [ref]$boolValue))
	{
		$Value = $Value.ToLower()
	}
	
	$query["value"] = $Value

	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	#$url = "https://$($script:USXConnectInfo.amcip):$($script:USXConnectInfo.amcport)/usxmanager/settings/$($key)?entry=$($entry)&value=$($value)&api_key=$($script:USXConnectInfo.api_key)"
	
	Write-Verbose "Url: $url"

	$result = UsxPut $url $null
	
	Write-Verbose "Result: $result"
	Write-Debug "Leave Set-USXGlobalSetting"
	
	return $result
}

function Get-USXNetwork
{
<#
.Synopsis
 Get ID for given network name
.Description
 Retreives the USX UUID for a give network name
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
	    [System.String]$Name
	)

	$builder = USXGetBuilder "usxmanager/configurator/networkprofiles"

	if ($Name)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[networkprofilename='$($Name)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$builder.Query = $query.ToString();
	}
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	
	return $result.items
}

<#
	.Synopsis
		Get hypervisor(s)
	
	.Description
		Get all hypervisors or get one hypervisor by name
	
	.PARAMETER Name
		Hypervisor name
	
	.PARAMETER MaxAllocation
		Maximum allocation percentage, overrides global preferences
	
	.PARAMETER Flash
		Indicates if the storage being added should be marked as Flash storage (overrides)
	
	.PARAMETER Weight
		Relative weigth for this datastore/storage
	
	.Example
		Todo
		#Requires-Version 3.0
	
	.NOTES
		Additional information about the function.
#>
function Add-USXStorage
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   Position = 0)]
		[Alias('hypervisoname')]
		[String[]]$Name,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 1)]
		[int]$MaxAllocation,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 2)]
		[switch]$Flash,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 3)]
		[int]$Weight = 5
	)
	
	BEGIN
	{
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	}
	
	PROCESS
	{				
		ForEach ($item in $Name)
		{
			$dataStore = Get-USXDataStore -Name $item
			
			if (!$MaxAllocation)
			{
				if ($dataStore.ssd -or $Flash)
				{
					$MaxAllocation = Get-USXGlobalSetting -Configurator:maxlocalflashallocation
				}
				else
				{
					$MaxAllocation = Get-USXGlobalSetting -Configurator:maxlocaldiskallocation
				}
			}
			
			$data = @{
				"datastoreuuid" = "$($dataStore.uuid)";
				"datastorename" = "$($dataStore.datastorename)";
				"maxallocation" = $MaxAllocation;
				"weight" = $Weight;
				"vmmanagername" = "$($dataStore.vmmanagername)";
				"ssd" = "$($dataStore.ssd.ToString().ToLower())";
			}
			
			if ($Flash)
			{
				$data["ssd"] = $Flash.ToString().ToLower();
			}
			
			$builder = USXGetBuilder "usxmanager/configurator/storageprofiles"
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			$query["format"] = "json"
			$builder.Query = $query.ToString();
			
			$url = $builder.ToString()
			
			$result = UsxPost -Url $Url -Data $data
			
			$result
		}
	}
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}
}

function Get-USXServiceVM
{
<#
.Synopsis
 Get Service VM
.Description
 Get Service VM
.Example
 Todo
#Requires-Version 3.0
#>
	[CmdletBinding(DefaultParametersetName="PSNAME")]
	param(
		[Parameter(	Mandatory = $false, 
			ParameterSetName = "PSNAME",
			Position = 0,
			ValuefromPipeline=$true,
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Name(s) of the volumes')]
		[Alias('displayname')]
		[String[]]$Name,

		[Parameter(	Mandatory = $false, 
			ParameterSetName = "PSVOLUME",
			Position = 0,
			HelpMessage = "Enter the Volume name for which you want the corresponding Service VM's")]
		[String]$Volume,
	
	
		[Parameter(	Mandatory = $false, 
			Position = 0,
			ParameterSetName = "PSID",
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Id (usx uuid) of the volumes')]
		[Alias('uuid')]
		[String[]]$Id
	)
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
	
	PROCESS 
	{	
		$builder = USXGetBuilder "usxmanager/usx/inventory/servicevm/containers"

		if ($Volume)
		{
			$result = @()
			$vol = Get-USXVolume $Volume
			$svmIPList = $vol.raidplans.raidbricks | select -ExpandProperty serviceip
			$svmList = Get-USXServiceVM
			ForEach ($item in $svmList)
			{
				$ip = $item.nics | where { $_.StorageNetwork } | select -ExpandProperty ipaddress
				if ($svmIPList.Contains($ip))
				{
					$result += $item
				}
			}
			
			return $result		
		}
		
		if ($Name -or $Id)
		{
			if (IsUSXUUID $Name)
			{
				$Id = $Name
				$Name = $null
			}			

			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			if ($Id)
			{
				$query["query"] = ".[uuid='$($Id -join "' or uuid='")']"
			}
			
			$query["sortby"] = "uuid"
			$query["pagesize"] = $script:USXCredentials.PageSize
			$query["order"] = "ascend"
			$builder.Query = $query.ToString();
		}

		$url = $builder.ToString()
		
		$result = USXGet -Url $Url	
		$result = $result.items
		
		
		# RW: Using PowerShell Where-Object because filtering /usx/inventory/servicevm/containers
		# on anything other than uuid doesn't work, see USX-53812
		if ($Name)
		{
			$result = $result | where{ $Name.Contains( $_.displayname) }
		}
		
		return $result
	}
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}		
}

<#
	.Synopsis
		Add hypervisor(s) to USX Manager
	
	.Description
		Adds one or more hypervisor hosts to USX manager
	
	.PARAMETER Name
		Hypervisor Name(s)
	
	.PARAMETER Weight
		Relative weigth for the Hypervisor host(s), not used in USX 3.1.2.1111 or lower
	
	.PARAMETER VMManager
		The VMManager that the hypervisor host(s) belong too, when omitted it will be retreived from USX Manager
	
	.PARAMETER Cluster
		Hypervisor Cluster or USX Cluster Tag name
	
	.PARAMETER IncludeAllLocalStorage
		Can be used to override the global preference setting to Include All Local Storage
	
	.PARAMETER IncludeAllSharedStorage
		Can be used to override the global preference setting to Include All Shared Storage
	
	.Example
		Add-USXHypervisor -Name 'hypervisor1"
	.Example
		Get-USXHypervisor -Name @("hypervisor1", "hypervisor2")
	.Example
		Get-USXHypervisor | Add-USXHypervisor
	
	.NOTES
		Additional information about the function.

#Requires-Version 3.0

#>
function Add-USXHypervisor
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 0)]
		[Alias('hypervisorname')]
		[String[]]$Name,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 1)]
		[int]$Weight = 5,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 2)]
		[Alias('vmmanagername')]
		[System.String]$VMManager,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 3)]
		[Alias('USXCluster')]
		[String]$Cluster,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 4)]
		[System.Nullable[switch]]$IncludeAllLocalStorage,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 5)]
		[System.Nullable[switch]]$IncludeAllSharedStorage
	)
	
	BEGIN
	{
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	}
	
	PROCESS
	{
		
		$data = @()
		ForEach ($item in $Name)
		{
			Write-Verbose "Processing $item"
			
			$hyperVisor = Get-USXHyperVisor -Name $item
			$entry = @{
				"vmmanagername" = $hyperVisor.vmmanagername;
				"hypervisoruuid" = $hyperVisor.uuid;
				"weight" = $Weight;
			}
			
			if ($VMManagerName)
			{
				$entry["vmmanagername"] = $VMManagerName
			}
			if ($Cluster)
			{
				$entry["clustertagname"] = $Cluster
				
			}
			elseif (-not [string]::IsNullOrEmpty($hyperVisor.Cluster))
			{
				$entry["clustertagname"] = $hyperVisor.Cluster
			}
			
			$data += $entry
		}
		
		
		$builder = USXGetBuilder "usxmanager/configurator/hypervisorprofiles/batch"
		
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["format"] = "json"
		$builder.Query = $query.ToString();
		
		$url = $builder.ToString()
		
		
		$result = UsxPost -Url $Url -Data $data
		
		if ($IncludeAllLocalStorage -eq $null)
		{
			$IncludeAllLocalStorage = [boolean]::Parse((Get-USXGlobalSetting -Recommender:includealllocalstorage))
		}
		
		if ($IncludeAllLocalStorage)
		{
			ForEach ($item in $Name)
			{
				$hyperVisor = Get-USXHyperVisor -Name $item
				
				ForEach ($datastore in $hyperVisor.datastores | where { -not [bool]$_.multiplehostaccess })
				{
					$dataStore = Get-USXDataStore -Name $datastore.datastorename
					try
					{
						$dataStore = Add-USXStorage -Name $dataStore.datastorename
					}
					catch { }
				}
			}
		}
		# If the IncludeAllSharedStorage switch was not provided we'll use the global setting
		# includeallsharedstorage
		if ($IncludeAllSharedStorage -eq $null)
		{
			$IncludeAllSharedStorage = [boolean]::Parse((Get-USXGlobalSetting -Recommender:includeallsharedstorage))
		}
		
		if ($IncludeAllSharedStorage)
		{
			ForEach ($item in $Name)
			{
				$hyperVisor = Get-USXHyperVisor -Name $item
				
				ForEach ($datastore in $hyperVisor.datastores | where { [bool]$_.multiplehostaccess })
				{
					try
					{
						$dataStore = Add-USXStorage -Name $dataStore.datastorename
					}
					catch
					{
						# ignore errors
					}
				}
			}
		}
		
		return $result
	}
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}
}

function Set-USXHypervisor
{
	param(
		[Parameter(	Mandatory = $true, 
			Position = 0,
			ValuefromPipeline=$true,
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Name(s) of the Hypervisor(s)')]
		[Alias('hypervisorname')]
		[String[]]$Name,

		[Parameter(	Mandatory = $false, 
			HelpMessage = "Enter the Hypervisor relative Weigth")]
		[int]$Weight,	

		[Parameter(	Mandatory = $false, 
			HelpMessage = "Enter the USX Tag")]
		[String]$Tag		
	)
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
	PROCESS 
	{	
		$data = @()
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"
			$hvuuid = Get-USXHyperVisor -Name $item | select -ExpandProperty uuid
			$hvprof = Get-USXHyperVisorProfile -Id $hvuuid
					
			if ($Tag)
			{
				Write-Verbose "Setting hypervisor $item wtag to $Tag"

				$taguuid = Get-USXTag -Name $Tag | select -ExpandProperty uuid				
				$hvprof.taguuids = @($taguuid)
			}
			if ($Weight)
			{
				Write-Verbose "Setting hypervisor $item weigth to $Weight"
				$hvprof.weight = $Weight
			}
			
			# we only need to pass a few fields, not all
			$data += ($hvprof | select uuid, vmmanagername, hypervisoruuid, weight, clustertagname, taguuids)
		}
		
		$builder = USXGetBuilder "usxmanager/configurator/hypervisorprofiles/batch"
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["format"] = "json"
		$builder.Query = $query.ToString();
		
		$url = $builder.ToString()
		
		$result = UsxPut -Url $Url -Data $data

		return $result
	}
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}		
}

function Get-USXHyperVisor
{
<#
.Synopsis
 Get hypervisor(s)
.Description
 Get all hypervisors or get one hypervisor by name
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
	    [System.String]$Name
	)

	$builder = USXGetBuilder "usxmanager/vmm/hypervisors"

	if ($Name)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[hypervisorname='$($Name)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$builder.Query = $query.ToString();
	}
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	
	return $result.items
}

function Get-USXHyperVisorProfile
{
<#
.Synopsis
 Get hypervisor profile(s)
.Description
 Get all hypervisor profiles or get one hypervisor profile by name
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
		[Alias("uuid")]
		[System.String]$Id
	)

	$builder = USXGetBuilder "usxmanager/configurator/hypervisorprofiles"

	if ($Id)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[hypervisoruuid='$($Id)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$builder.Query = $query.ToString();
	}
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	
	return $result.items
}


function Get-USXStorage
{
<#
.Synopsis
 Get storage
.Description
 #todo
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
	    [System.String]$Name
	)

	$builder = USXGetBuilder "usxmanager/configurator/storageprofiles"

	if ($Name)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[datastorename='$($Name)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$builder.Query = $query.ToString();
	}
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	
	return $result.items
}


function Remove-USXVMManager
{
<#
.Synopsis
Remove VM Manager
.Description
Removes one or more VM Managers from USX Manager
.Example
Remove the VM Manager named "My VM Manager"
Remove-USXVMManager -Name "My VM Manager"
.Example
Remove all VM Managers
Remove-USXManager
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("uuid")]
		[String[]]$Name
	)
    
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
    
	PROCESS 
	{	
	
		if (-not $Name)
		{
			Get-USXVMManager | Remove-USXVMManager
		}
		
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"	
			
			if ($PsCmdlet.ShouldProcess($item))
			{
				Write-Debug "Deleting $item" 
				$builder = USXGetBuilder "usxmanager/vmm/vmmanagers/$($item)"
				$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
				$query["format"] = "json"
				$builder.Query = $query.ToString();
				
				$url = $builder.ToString()
			  
				UsxDelete -Url $Url	
			}
		}
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}	

}

function Remove-USXHypervisor
{
<#
.Synopsis
Remove Hypervisor from USX Manager
.Description
Removes one or more Hypervisors from USX Manager
.Example
Remove the Hypervisor named "My Hypervisor"
Remove-USXHypervisor -Name "My Hypervisor"
.Example
Remove all Hypervisors
Remove-USXHypervisor
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("hypervisorname")]
		[String[]]$Name
	)
    
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
    
	PROCESS 
	{	
	
		if (-not $Name)
		{
			$Name = (Get-USXHyperVisor).hypervisorname		
		}

		$data = @()

		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"	
			$hyperVisor = Get-USXHyperVisor $item
			$hyperVisorProfile = Get-USXHyperVisorProfile -Id $hyperVisor.uuid -WarningAction:SilentlyContinue
			if ($hyperVisorProfile)
			{
				if ($PsCmdlet.ShouldProcess($item))
				{
					$data += $hyperVisorProfile.uuid 
				}
			}
		}
		
		if ($data.count -gt 0)
		{
			$builder = USXGetBuilder "usxmanager/configurator/hypervisorprofiles/batch"
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			$query["format"] = "json"
			$builder.Query = $query.ToString();
					
			$url = $builder.ToString()
				  
			UsxDelete -Url $Url $data
		}
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}	

}


function Remove-USXNetwork
{
<#
.Synopsis
Removes a network from USX Manager
.Description
Removes one or more networks from USX Manager
.Example
Remove a USX Network by name
Remove-USXNetwork -Name "My Network"
.Example
Remove all USX Networks
Remove-USXNetwork
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("networkprofilename")]
		[String[]]$Name
	)
    
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }		
    
	PROCESS 
	{	
		if (-not $Name)
		{
			Get-USXNetwork | Remove-USXNetwork
		}
		
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"
			if ($PsCmdlet.ShouldProcess($item))			
			{
				$Network = Get-USXNetwork -Name $item
				$builder = USXGetBuilder "usxmanager/configurator/networkprofiles/$($Network.uuid)"
				$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
				$builder.Query = $query.ToString();
				
				$url = $builder.ToString()	  
				UsxDelete -Url $Url	
			}
		}
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}	
}

function Add-USXNetwork
{
<#
.Synopsis
 Add a Network to USX Manager
.Description
 Add a Network to USX Manager
.Example
 Add-USXNetwork
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false)]
	    [String]$Name,
	
		[Parameter(Mandatory=$true, Position=1, valuefromPipeline=$false)]
		[USX.Network.Type]$Type,
		
		[Parameter(Mandatory=$true, Position=2, valuefromPipeline=$false)]
		[USX.Network.AddressMode]$AddressMode,
		
		[Parameter(Mandatory=$true, Position=3, valuefromPipeline=$false)]
		[string[]]$IpRanges,
		
		[Parameter(Mandatory=$false, Position=4, valuefromPipeline=$false)]
		[string]$Netmask,

		[Parameter(Mandatory=$false, Position=5, valuefromPipeline=$false)]
		[string]$Gateway		
	)
	
	$isStorageNetwork = $Type -eq [USX.Network.Type]::STORAGE
	$data = @{
		"networkprofilename" = $Name;
		"storagenetwork" = $isStorageNetwork;
		"mode" = "$($AddressMode)";
		"netmask" = $Netmask;
		"gateway" = $Gateway;
		"ipranges" = $IpRanges;
		"defaultnetworkname" = $Name;
	}
	
	#$data["ipranges"] = $IpRanges
	
	$builder = USXGetBuilder "usxmanager/configurator/networkprofiles"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	return UsxPost -Url $Url -Data $data
}

function Get-USXVMManager
{
<#
.Synopsis
 Get usx managers details
.Description
 Nice long description
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
	    [String]$Name
	)
	
	$builder = USXGetBuilder "usxmanager/vmm/vmmanagers"

	if ($Name)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[name='$($Name)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$query["page"] = 0
		$query["pagesize"] = 100
		$builder.Query = $query.ToString();
	}
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	
	return $result.items
}
function Add-USXVMManager
{
<#
.Synopsis
 Add a VM Manager to USX
.Description
 Adds a VM Manager to USX Manager
.Example
 Add-USXVMManager -Name "vCenter" -VMManagerHostname "vcenter.mycloud.local" -User "administrator@vsphere.local" -Password 'secret' -VMManagerType VCENTER
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
	    [String]$Name,
		
		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false)]
	    [String]$VMManagerHostname,

		[Parameter(Mandatory=$false, Position=2, valuefromPipeline=$false)]
		[String]$User,
		
		[Parameter(Mandatory=$false, Position=3, valuefromPipeline=$false)]
	    [String]$Password,
		
		[Parameter(Mandatory=$false, Position=4, valuefromPipeline=$false)]
		[USX.VMManager]$VMManagerType
	)

	$data = @{
    	"name"="$($Name)";
        "vmmhostname"="$($VMManagerhostname)";
		"port"="";
        "username"="$($User)";
		"password"="$($Password)";
		"uuid"="";
		"vmmanagertype"="$($VMManagertype)";
		}
			
	$builder = USXGetBuilder "usxmanager/vmm/vmmanagers"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
  
	return UsxPost -Url $Url -Data $data
}

function USXGetBuilder([string]$path)
{
	if (-not $script:USXCredentials)
	{
		$stack = Get-PSCallStack | select -Index 1
		Throw "$($stack.Command): You are not connected to a USX Manager please call Connect-USX before attempting any operation"
	}
	
	$builder = New-Object System.UriBuilder("https", $script:USXCredentials.Name, $script:USXConnectInfo.amcport, $path)
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["api_key"] = $script:USXConnectInfo.api_key
	$builder.Query = $query.ToString();

	return $builder
}


function Remove-USXTask
{
<#
.Synopsis
Remove a task from USX Manager
.Description
Remove one or more tasks from USX Manager
.Example
 Todo
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
	    [String]$Name
	)
	if ($PsCmdlet.ShouldProcess("All Tasks"))
	{
		$builder = USXGetBuilder "usxmanager/model/jobstatus"

		if ($Name)
		{
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			$builder.Query = $query.ToString();
		}	

		$url = $builder.ToString()
		
		$result = USXDelete -Url $Url	
	}
}

function Set-USXNameTemplate
{
<#
.Synopsis
Sets the last number used in Name Template(s)
.Description
Sets the last number used in Name Template(s), if LastNumberUsed is not specified it's set to 0
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true, ValuefromPipelineByPropertyName = $true)]
		[Alias("templatename")]
	    [String[]]$Name,
		
		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false)]
	    [int]$LastNumberUsed		
	)
    BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }	
	
	PROCESS
	{

		if (-not $Name)
		{
			$Name = Get-USXNameTemplate | select -ExpandProperty templatename
			if (!$Name)
			{
				return $null
			}
		}
		
		ForEach ($item in $Name)
		{
			Write-Verbose "Processing $item"
			$nameTemplate = Get-USXNameTemplate -Name $item
			Write-Verbose "$item has uuid $($nameTemplate.uuid)"
			
			$builder = USXGetBuilder "usxmanager/configurator/nametemplates/$($nameTemplate.uuid)/reset"
			$url = $builder.ToString()
			
			if ($LastNumberUsed)
			{
				UsxPut -Url $Url -Data $LastNumberUsed
			}
			else
			{
				UsxPut -Url $Url
			}

		}
	}
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}		
}

function Get-USXNameTemplate
{
<#
.Synopsis
 Add a Name Template to USX
.Description
 Nice long description
.Example
 Todo
#Requires-Version 3.0
#>
#([string]$templatename, [string]$componenttype, [string]$prefix, [int]$numberofdigits, [int]$startingnumber)
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
	    [String]$Name
	)
	$builder = USXGetBuilder "usxmanager/configurator/nametemplates"

	if ($Name)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[templatename='$($Name)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$builder.Query = $query.ToString();
	}	

	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	
	return $result.items
}

function Remove-USXNameTemplate
{
<#
.Synopsis
Removes a Name Template
.Description
Removes one or more Name Templates from the USX Manager.
.Example
Remove name template with name "My Name Template"
Remove-USXNameTemplate -Name "My Name Template"
.Example
Remove all name templates except the system default ones
Remove-USXNameTemplate
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("templatename")]
		[String[]]$Name,
		[Parameter(Mandatory=$false, valuefromPipeline=$false)]
		[Switch]$Force = $false
	)
    BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }	
	
	PROCESS
	{
		if (-not $Name)
		{
			Get-USXNameTemplate | Remove-USXNameTemplate
		}
		
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"
			Write-Debug "Retreiving uuid for $item"
			$template = Get-USXNameTemplate -Name $item
			if ($Force -or (-not $template.templatename.StartsWith("Default-")))
			{
				if ($PsCmdlet.ShouldProcess($item))
			    {

					Write-Debug "Remove template $item with uuid $($template.uuid)"
					
					$builder = USXGetBuilder "usxmanager/configurator/nametemplates/$($template.uuid)"
					$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
					$query["format"] = "json"
					$builder.Query = $query.ToString();
					
					$url = $builder.ToString()
				  
					UsxDelete -Url $Url
				}
				else
				{
					Write-Debug "not deleting template $item with uuid $($template.uuid), use -Force if you really want to delete it"
				}
				
			}
		}
	}
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}	
}

<#
	.Synopsis
		Add a Name Template to USX
	
	.Description
		Add a Name Template to USX Manager
	
	.PARAMETER Name
		Display name for the Name Template
	
	.PARAMETER Type
		The type of the Name Template
	
	.PARAMETER Prefix
		Prefix for the Name Template
	
	.PARAMETER NumberOfDigits
		Number of digits for the Name Template
	
	.PARAMETER StartingNumber
		Starting number for the Name Template
	
	.PARAMETER Postfix
		Postfix for the Name Template
	
	.Example
		Add-USXNameTemplate -Name "VolumeVMTemplate" -Type VOLUME -Prefix "USX-VVM" - NumberOfDigits 3
	
	.Example
		Add-USXNameTemplate -Name "ServiceVMTemplate" -Type SERVICE_VM -Prefix "USX-SVM" - NumberOfDigits 3
	
	.Example
		Add-USXNameTemplate -Name "VolumeServiceTemplate" -Type VOLUME_SERVICE -Prefix "USX-DS" - NumberOfDigits 3
		
		#Requires-Version 3.0
	
	.NOTES
		Additional information about the function.
#>
function Add-USXNameTemplate
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 0)]
		[String]$Name,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 1)]
		[USX.NameTemplate]$Type,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 2)]
		[String]$Prefix,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 3)]
		[int]$NumberOfDigits = 3,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 4)]
		[int]$StartingNumber = 1,
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $false,
				   Position = 5)]
		[String]$Postfix
	)
	
	#([string]$templatename, [string]$componenttype, [string]$prefix, [int]$numberofdigits, [int]$startingnumber)
	
	
	$builder = USXGetBuilder "usxmanager/configurator/nametemplates"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	$NameTemplateUUID = "$($Name)-#$($NumberOfDigits)#"
	
	$data = @{
		"componenttype" = "$($Type)";
		"templatename" = "$($Name)";
		"elements" = @("$($Prefix)", @{
				"startingnumber" = $($StartingNumber);
				"numberofdigits" = $($NumberOfDigits);
			},
			"$($Postfix)"
		);
		"isenable" = $true;
		"uuid" = "$($NameTemplateUUID)"
	}
	
	$result = UsxPost -Url $Url -Data $data
	return $result
}

<#
	.Synopsis
		Add a Network Profile to USX
	
	.Description
		Add a Network Profile to USX
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.PARAMETER HyperVisor
		Hypervisor hostname(s)
	
	.PARAMETER NetworkName
		Network name (as visible in hypervisor/vm manager)
	
	.Example
		Add-USXNetworkProfile -Name "Management Network" -Hypervisor "hypervisor1" -NetworkName "VM Network"
	.EXAMPLE
		Add-USXNetworkProfile -Name "Storage Network" -Hypervisor @("hypervisor1", "hypervisor2") -NetworkName "Storage Network"
	.EXAMPLE
		Get-USXHypervisor | Add-USXNetworkProfile -Name "Storage Network" -NetworkName "Storage Network"
	
	.NOTES
		Additional information about the function.
#>
function Add-USXNetworkProfile
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $false,
				   Position = 0)]
		[String]$Name,
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $true,
				   Position = 1)]
		[Alias('hypervisorname')]
		[string[]]$HyperVisor,
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $false,
				   Position = 2)]
		[string]$NetworkName
	)
	
	$builder = USXGetBuilder "usxmanager/configurator/networkprofiles/mapping/batch"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	$network = Get-USXNetwork -Name $Name
	$data = @()
	ForEach ($item in $HyperVisor)
	{
		$hv = Get-USXHyperVisor -Name $item
		$entry = @{
			"hypervisoruuid" = $hv.uuid;
			"networkname" = $NetworkName;
			"networkprofileuuid" = $network.uuid;
			"vmmanagername" = $hv.vmmanagername;
		}
		
		$data += $entry
	}
	
	return UsxPost -Url $Url -Data $data
}

function StringToNumber
{
<#
.Synopsis
 Converts string value to numeric
.Description
 Converts string value to numeric, tries to return Int32, UInt32, Int64, UInt64
.Example
 StringToNumber "1234567"
#Requires-Version 3.0
#>
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false)]
		[string]$s
	)

	[Int32]$result = 0
	if (-not [Int32]::TryParse($s, [ref]$result))
	{
		[UInt32]$result = 0
		if (-not [UInt32]::TryParse($s, [ref]$result))
		{
			[Int64]$result = 0
			if (-not [Int64]::TryParse($s, [ref]$result))
			{
				if (-not [UInt64]::TryParse($s, [ref]$result))
				{
					throw New-Object System.OverflowException("Cannot convert $s to a numeric value")
				}
			}
		}
	}
	
	return $result
}

# USX Time is milliseconds since 1/1/1970
 # We will convert it to the LOCAL timezone
function ConvertFrom-USXTimeStamp
{
<#
.Synopsis
 Convert USX date(s) to Powershell Date Time
.Description
 Converts USX date time value(s) to PowerShell Date Time value(s)
.Example
 ConvertFrom-USXTimeStamp
#Requires-Version 3.0
#>
  [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false)]
		[System.Array]$TimeStamp
	)
    BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }	
	
	PROCESS
	{
	
		$baseTime = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970'))
		ForEach ($item in $TimeStamp)
		{
			if ($item -is [String])
			{
				$item = StringToNumber $item
			}
			
			switch ($item.GetType())
			{
				{ $_ -eq [string] } { $item = StringToNumber $item }
				{ $_ -in [Int32], [UInt32] } { $baseTime.AddSeconds($item) }
				{ $_ -in [long], [UInt64], [Int64] } { $baseTime.AddMilliSeconds($item) }
				
			}			
		}
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}		
 }
 
 Function ConvertTo-USXDate ([datetime]$DateTime) {
 
 $baseDate = Get-Date -Date "01/01/1970"
 # Need to convert it back to UTC time !!	
 $result = (New-TimeSpan -Start $baseDate -End $DateTime.ToUniversalTime()).TotalMilliSeconds
 return [math]::truncate($result)
 }

function Get-USXRepository
{
<#
.Synopsis
 Get a USX Repository (database table)
.Description
 Get a USX Repository (database table) from USX Manager
.Example
 #Todo
#Requires-Version 3.0
#>
  [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false)]
		[String[]]$Name
	)
    BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }	
	
	PROCESS
	{

		ForEach ($item in $Name)
		{
			$builder = USXGetBuilder "/usxmanager/grid/repositories/$item"
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			$query["pagesize"] = $script:USXCredentials.PageSize
			$query["sortby"] = "uuid"
			$query["order"] = "ascend"
			$builder.Query = $query.ToString();
	
			$url = $builder.ToString()
			
			$result = UsxGet -Url $Url
			return $result.items
		}
	
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}		
 }


function Remove-USXRepositoryKey
{
<#
.Synopsis
Remove an key/value pair from an USX repository
.Description
Remove an key/value pair from an USX repository
.Example
Remove-USXRepositoryKey -Name "ALERT" -Key "alert-0afc0f02-e54a-4fdb-8a99-c54509790b7b"

#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipelineByPropertyName = $true)]
		[String]$Name,
		
		[Parameter(Mandatory=$true, Position=1, valuefromPipelineByPropertyName = $true)]
		[Alias("uuid")]
		[String[]]$Key
	)
    
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
    
	PROCESS 
	{	
		ForEach ($item in $Key)
		{
			Write-Verbose "Processing $($item)"	
			
			if ($PsCmdlet.ShouldProcess($item))
			{
				Write-Verbose "Deleting $item" 
				$builder = USXGetBuilder "/usxmanager/grid/repositories/$Name/$item"
				$url = $builder.ToString()
			  
				UsxDelete -Url $Url	
			}
		}
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}	

}

function Remove-USXAlert
{
<#
.Synopsis
Clear USX alerts
.Description
Clear all USX alerts or clear all Alerts with status other than OK
.Example
Remove-USXAlerts
.Example
Remove-USXAlerts -ErrorsOnly
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[switch]$ErrorsOnly	
	)
    
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
    
	PROCESS 
	{	
		$alerts = Get-USXRepository -Name 'ALERT'
		if ($ErrorsOnly)
		{
			$alerts = $alerts | where { $_.status -ne 'OK' }
		}
		
		if ($alerts)
		{
			$alerts | Remove-USXRepositoryKey -Name 'ALERT' 
		}
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}	

}

function Get-USXCluster
{
<#
.Synopsis
Gets the available clusters from USX Manager
.Description
Gets the available clusters from USX Manager
.Example
Get-USXCluster
.Example
Get-USXCluster -Name "My Cluster"
#Requires-Version 3.0
#>

[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
	    [String]$Name
	)
	
	$builder = USXGetBuilder "usxmanager/configurator/hypervisorprofiles"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["sortby"] = "uuid"
	$query["order"] = "ascend"
	$builder.Query = $query.ToString();
	$url = $builder.ToString()

	$result = UsxGet $url
	if ($Name)
	{
		$result = $result.items | where { $_.clustertagname -eq 'Prod' } | select -ExpandProperty taguuids | sort | Get-Unique
	}
	else
	{
		$result = $result.items | select -ExpandProperty taguuids | sort | Get-Unique
	}
	return $result
}

#function Get-USXCluster_Old
#{
#<#
#.Synopsis
# Gets the available clusters from USX Manager
#.Description
# Nice long description
#.Example
# Todo
##Requires-Version 3.0
##>
#
#[CmdletBinding()]
#	param(
#		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
#	    [String]$Name
#	)
#	
#	$builder = USXGetBuilder "usxmanager/haconfigs"
#	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
#	$query["sortby"] = "uuid"
#	$query["order"] = "ascend"
#	$builder.Query = $query.ToString();
#	$url = $builder.ToString()
#
#	$result = UsxGet $url
#	$result = $result.items | select -ExpandProperty taguuids
#	
#	if ($Name)
#	{
#		$result = $result | where { $_ -eq $Name }
#	}
#	return $result
#}


function Wait-USXBootStrap([string]$JobRefId, [int]$TimeOut)
{
	$now = Get-Date
	
	$isCompleted = $false
	
	while (!($isCompleted))
	{
		$secondsElapsed = (New-TimeSpan -Start $now -End (Get-Date)).TotalSeconds
		
		if ($secondsElapsed -ge $TimeOut)
		{
			Write-Progress -Activity "TimeOut" -PercentComplete 100
			return $false
		}
		$status = Get-USXJob -JobRefId $JobRefId
		$bootStrap = $status.items | where { $_.SERVICE -eq "DEPLOYMENT"}
		if ($bootStrap)
		{
			$isCompleted = $bootStrap.percentcomplete -ge 100
		}
		
		$lastStatus = ($status.items | select -Last 1)
		if (!($completed))
		
		{
			Write-Progress -Activity $($lastStatus.Service) $($lastStatus.name) -CurrentOperation ($lastStatus.tasks | select -Last 1).message -PercentComplete $lastStatus.percentcomplete
			Start-Sleep -Seconds 1
		}
	}

	Write-Progress -Activity $($lastStatus.Service) $($lastStatus.name) -CurrentOperation ($lastStatus.tasks | select -Last 1).message -PercentComplete 100
	
	return $isCompleted
}

function Restore-USXDatabase
{
<#
.Synopsis
Restores a backup of the grid database
.Description
Restores a backup of the grid database from a given Path
.Example
Restore-USXDatabase -Path "C:\Backups\My Backup.zip"
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false)]	    
		[String]$Path
	)
	
	if ($PsCmdlet.ShouldProcess($Path))
	{
		$fileName = Split-Path $Path -Leaf
		$restorePath = "/opt/amc_db"
		$secpasswd = ConvertTo-SecureString $script:USXCredentials.Password -AsPlainText -Force
		$creds = New-Object System.Management.Automation.PSCredential ($script:USXCredentials.Username, $secpasswd)

		Set-SCPFile -AcceptKey:$true -ComputerName $script:USXCredentials.Name -LocalFile $path -RemotePath $restorePath -Credential $creds
		$session = New-SSHSession -AcceptKey:$true -ComputerName $script:USXCredentials.Name -Credential $creds
		try
		{
			$output = ""
			$output += Invoke-SSHCommand -SSHSession $session -Command "cd /opt/amc_db"
			$output += Invoke-SSHCommand -SSHSession $session -Command "service amcDB stop"
			$command = "unzip -o -d /opt/amc_db " + $restorePath + "/" + $fileName 
			$output += Invoke-SSHCommand -SSHSession $session -Command $command
			$command = "rm /opt/amc_db/" + $fileName
			$output += Invoke-SSHCommand -SSHSession $session -Command $command
			$output += Invoke-SSHCommand -SSHSession $session -Command "reboot" -TimeOut 1
			
			return $output			
		}

		finally
		{
			Remove-SSHSession -SSHSession $session
		}
		
	}
}

function Backup-USXDatabase
{
<#
.Synopsis
Takes a backup of the grid database
.Description
Takes a backup of the grid database to a given Path
.Example
Backup-USXDatabase -Path "C:\Backups\My Backup.zip"
#Requires-Version 3.0
#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false)]	    
		[String]$Path
	)

	if (!(Get-Command Get-PoshSSHModVersion -ErrorAction:SilentlyContinue))
	{
		iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
	}	
	
	$fileName = "backup-$(ConvertTo-UsxDate (Get-Date))"
	if (!($path.EndsWith(".zip")))
	{
		$path = Join-Path -Path $path -ChildPath $fileName
		$path += ".zip"
	}
	$backupPath = "/opt/amc_db/backup-$fileName"
	
	$builder = USXGetBuilder "usxmanager/grid/data/backups"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["backupfile"] = $backupPath
	$builder.Query = $query.ToString();
	$url = $builder.ToString()

	$result = UsxPost $url
	
	$secpasswd = ConvertTo-SecureString $script:USXCredentials.Password -AsPlainText -Force
	$creds = New-Object System.Management.Automation.PSCredential ($script:USXCredentials.Username, $secpasswd)
	Get-SCPFile -LocalFile $Path -RemoteFile $backupPath -ComputerName $script:USXCredentials.Name -Credential $creds -AcceptKey:$true
	
	$session = New-SSHSession -AcceptKey:$true -ComputerName $script:USXCredentials.Name -Credential $creds
	try
	{
		$output = Invoke-SSHCommand -SSHSession $session -Command "rm $backupFile"
	}
	finally
	{
		Remove-SSHSession -SSHSession $session
	}
	
	return $Path
}

function Add-USXVolume
{
<#
.Synopsis
 Create a new USX Volume
.Description
 Nice long description
.Example
Add-USXVolume -Name Test01 -StorageNetwork NetProfile -VolumeVMTemplate Default-VOLUME  -SizeGB 20 -Simple SIMPLE_HYBRID -ManagementNetwork VMNetwork
 Todo
#Requires-Version 3.0
#>
[CmdletBinding(DefaultParametersetName="NONSIMPLE")]
	param(	

		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
		[string]$Name,

		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [USX.Volume.Simple]$Simple,

		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false,
			ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$Infrastructure,

		[Parameter(Mandatory=$false, Position=2, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [string]$HyperVisor,
		
		[Parameter(Mandatory=$true, Position=2, valuefromPipeline=$false,
			ParameterSetName = "NONSIMPLE")]
	    [USX.VOLUME.TYPE]$Type,

		[Parameter(Mandatory=$false, Position=3, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [USX.VOLUME.EXPORTTYPE]$ExportType = [USX.VOLUME.ExportType]::NFS,

		[Parameter(Mandatory=$true, Position=4, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
#	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [int]$SizeGB,
		
		[Parameter(Mandatory=$true, Position=5, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [string]$StorageNetwork,
		
		[Parameter(Mandatory=$false, Position=6, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [string]$ManagementNetwork,

		[Parameter(Mandatory=$false, Position=7, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [string]$VolumeVMTemplate,
		
		[Parameter(Mandatory=$false, Position=8, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$EnableSnapshots = $false,

		[Parameter(Mandatory=$false, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$StretchedCluster = $false,
		
		[Parameter(Mandatory=$false, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [switch]$EnableSnapClone = $true,

		[Parameter(Mandatory=$false, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [switch]$ActivateSnapClone = $true,

		[Parameter(Mandatory=$false, valuefromPipeline=$false,
			 ParameterSetName = "SIMPLE")]
		[ValidateSet('THIN', 'THICKLAZY', 'THICKEAGER')]
	    [String]$SnapcloneDiskType = 'THIN',

		[Parameter(Mandatory=$false, Position=8, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$VVOL = $false,

		[Parameter(Mandatory=$false, valuefromPipeline=$false,
			ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [int]$ExportSizeGB,
		
		[Parameter(Mandatory=$true, Position=9, valuefromPipeline=$false,
			ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [string]$ServiceVMTemplate,
		
		[Parameter(Mandatory=$false, Position=10, valuefromPipeline=$false,
		    ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$PreferFlashForCapacity,
		
		[Parameter(Mandatory=$false, Position=11, valuefromPipeline=$false,
		    ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$PreferFlashForPerformance,
		
		[Parameter(Mandatory=$false, Position=12, valuefromPipeline=$false,
		    ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$PreferSharedStorageForExports,

		[Parameter(Mandatory=$false, Position=13, valuefromPipeline=$false,
		    ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$DirectIO,

		[Parameter(Mandatory=$false, Position=14, valuefromPipeline=$false,
		    ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$FastSync,
		
		[Parameter(Mandatory=$false, valuefromPipeline=$false,
		    ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [switch]$NFSSync,
		
		[Parameter(Mandatory=$false, Position=15, valuefromPipeline=$false,
		    ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [int]$MemoryToDiskRatio = 15,

		[Parameter(Mandatory=$false, Position=16, valuefromPipeline=$false,
		    ParameterSetName = "INFRASTRUCTURE")]
	    [Parameter(ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "NONSIMPLE")]
	    [string]$VolumeName,

		[Parameter(Mandatory=$false, Position=17, valuefromPipeline=$false,
		    ParameterSetName = "NONSIMPLE")]
	    [Parameter(ParameterSetName = "SIMPLE")]
	    [Parameter(ParameterSetName = "INFRASTRUCTURE")]
	    [string]$Cluster,
		
		[Parameter(Mandatory=$false, Position=18, valueFromPipeline=$false)]
		[String]$USXCluster
	)
	
	$storNetwork = Get-USXNetwork -Name $StorageNetwork
	
	if ($ManagementNetwork)
	{
		$mgmtNetwork = Get-USXNetwork -Name $ManagementNetwork
	}
	
	if (!$VolumeName)
	{
		$VolumeName = $Name
	}
	
	if ($VolumeVMTemplate)
	{
		$volumeNameTemplate = Get-USXNameTemplate -Name $VolumeVMTemplate
	}
	else
	{
		$volumeNameTemplate = [string]::Empty
	}
	
	if ($ServiceVMTemplate)
	{
		$serviceNameTemplate = Get-USXNameTemplate -Name $ServiceVMTemplate
	}
	else
	{
		$serviceNameTemplate = [String]::Empty
	}
	
	switch ($PsCmdlet.ParameterSetName)
	{
		"INFRASTRUCTURE" { $volumeType = "INFRASTRUCTURE" ; break }
		"SIMPLE" { $volumeType = $Simple ; break }
		"NONSIMPLE" { $volumeType = $Type ; break }
	}

	$data = @{
		"volumetype" = "$($volumeType)";
	    "volumesize" = $SizeGB;
	    "volumeservicename" = "$($VolumeName)";
	    "storagenetworkprofileuuid" = "$($storNetwork.uuid)";
		"vvol" = ($VVol).ToString().ToLower();
		
#		"managementnetworkprofileuuid" = "$($mgmtNetwork.uuid)";
		
		# Added to select USX Cluster
		#"clustertagname" = "$($USXCluster)";
		
	    "attributes" = @{
	          "exporttype" = "$($ExportType)";
			  "preferflashforcapacity" = $PreferFlashForCapacity.ToString().ToLower();
			  "preferflashformemory" = $PreferFlashForPerformance.ToString().ToLower();
			  "stretchcluster" = ($StretchedCluster).ToString().ToLower();
	          "enablesnapshot" = ($EnableSnapshots).ToString().ToLower();
			  "fs_sync" = ($NFSSync).ToString().ToLower();			  
			  }
		"prefersharedstorageforexports" = $PreferSharedStorageForExports.ToString().ToLower();
		"directio" = $DirectIo.ToString().ToLower();
		"fastsync" = $FastSync.ToString().ToLower();
		"hybridratio" = $MemoryToDiskRatio;
#		"snapshotenabled" = (-not $DisableSnapshots).ToString().ToLower();
    }

	if ($HyperVisor)
	{
		
		#$data["hypervisorname"] = $hyperVisor	
		$data["hypervisoruuids"] = @(Get-USXHyperVisor -Name $Hypervisor | select -ExpandProperty uuid)
	}

	if ($VolumeVMTemplate)
	{
		$data["volumenametemplateuuid"] = "$($volumeNameTemplate.uuid)";
	}
	else
	{
		$data["volumename"] = $Name
	}

	if ($ServiceVMTemplate)
	{
		$data["servicevmnametemplateuuid"] = "$($serviceNameTemplate.uuid)";
	}
	
	if ($Cluster)
	{
		$data.attributes["clustertaguuid"] = $Cluster	
	}
	
	if ($ManagementNetwork)
	{
		$data["managementnetworkprofileuuid"] = "$($mgmtNetwork.uuid)"	
	}
	
#	if ($VolumeName)
	#{
		#$data["volumename"] = $VolumeName
	#}
	
	if ($Infrastructure)
	{
		$data["infrastructurevolume"] = $true
		$data.Remove("volumesize")
		$data.Remove("volumetype")
#		$data.attributes["clustertaguuid"] = $Cluster
	}
	elseif ($Type -eq [USX.VOLUME.TYPE]::HYPERCONVERGED)
	{
		$data.attributes["hyperconvergedvolume"] = $true.ToString().ToLower()
		$data["volumetype"] = "HYBRID"		
	}
	elseif ($Simple -eq [USX.VOLUME.SIMPLE]::SIMPLE_MEMORY)
	{
		$data.attributes["snapcloneenabled"] = $EnableSnapClone.ToString().ToLower();
		$data.attributes["snapcloneactivated"] = $ActivateSnapClone.ToString().ToLower();
		$data.attributes["snapclonediskprovisioningtype"] = $SnapcloneDiskType.ToString();
		
		if ($ExportSizeGB)
		{
			$data["memorysizeoverride"] = $SizeGB
			$Data["volumesize"] = $ExportSizeGB
		}
	}
	
	if ($ExportType -eq [USX.VOLUME.EXPORTTYPE]::iSCSI)
	{
		if (-not $ExportSize)
		{
			$data["iscsiexportsize"] = $SizeGB
		}
		else
		{
			$data["iscsiexportsize"] = $ExportSize
		}
	}
	
#	$builder = USXGetBuilder "usxmanager/workflows/volume/autodeploy"
	if ($Simple)
	{
		$builder = USXGetBuilder "usxmanager/workflows/volume/batchdeploy"
	}
	else
	{
		$builder = USXGetBuilder "usxmanager/workflows/volume/autodeploy"
	}
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()

	$result = UsxPost -Url $Url -Data $data
	return $result	
}

function Get-USXVolume
{
<#
.Synopsis
 Get Volume(s)
.Description
 Get all volumes or get one volume by volume service name (datastore name)
.Example
 Todo
#Requires-Version 3.0
#>
	[CmdletBinding(DefaultParametersetName="PSNAME")]
	param(
		[Parameter(	Mandatory = $false, 
			ParameterSetName = "PSNAME",
			Position = 0,
			ValuefromPipeline=$true,
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Name(s) of the volumes')]
		[Alias('displayname')]
		[String[]]$Name,

		[Parameter(Mandatory=$false, 
			Position = 0,
			ParameterSetName = "PSVMNAME")]
		[Alias('vm')]
		[String[]]$VMName,
		
		[Parameter(	Mandatory = $false, 
			Position = 0,
			ParameterSetName = "PSID",
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Id (usx uuid) of the volumes')]
		[Alias('uuid')]
		[String[]]$Id
	)

	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }
	
	PROCESS 
	{	
		$builder = USXGetBuilder "usxmanager/usx/inventory/volume/resources"
			
		if ($Name -or $Id -or $VMName)
		{
			if (IsUSXUUID $Name)
			{
				$Id = $Name
				$Name = $null
			}			
			
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			if ($Name)
			{
				$query["query"] = ".[volumeservicename='$($Name -join "' or volumeservicename='")']"
			}
			elseif ($VMName)
			{
				$containerUuid = Get-USXContainer -Name $VMName | select -ExpandProperty uuid
				$query["query"] = ".[containeruuid='$($containerUuid -join "' or containeruuid='")']"	
			}
			else
			{
				$query["query"] = ".[uuid='$($Id -join "' or uuid='")']"
			}
			
			$query["sortby"] = "uuid"
			$query["pagesize"] = $script:USXCredentials.PageSize
			$query["order"] = "ascend"
			$builder.Query = $query.ToString();
		}
		$url = $builder.ToString()
		
		$result = USXGet -Url $Url

		if ($result.count -ge $script:USXCredentials.PageSize)
		{
			Write-Warning "Query returned $($result.count) items while PageSize is $($script:USXCredentials.PageSize).`nMore items may exist!"
		}
		return $result.items
	}
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}
}

function Set-USXEnableHA
{
<#
.Synopsis
 Enable HA on a Volume (Datastore)
.Description
 Nice long description
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(	
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
		[Boolean]$IsHaShared,
		
		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false)]
		[String]$VolumeName
	)

	Set-USXGlobalSetting -Recommender:ishashared $IsHaShared
	$VolumeServiceName = Get-USXVolume -Name $VolumeName

#    $data = @{"vresourceuuid" = "$($VolumeServiceName.uuid)"}
	$data = "$($VolumeServiceName.uuid)"	
			
	$builder = USXGetBuilder "usxmanager/workflows/volume/$($data)/enableha"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
  
#	return UsxPost -Url $Url -Data $data
	return UsxPost -Url $Url
}

function Set-USXVolume
{
<#
.Synopsis
 Enable HA on a Volume (Datastore)
.Description
 Nice long description
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(	
		[Parameter(Mandatory=$true, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("displayname")]
		[String[]]$Name,
		
		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false,
			ParameterSetName = "ENABLEHA")]
		[Switch]$EnableHA,

		[Parameter(Mandatory=$false, Position=2, valuefromPipeline=$false,
			ParameterSetName = "ENABLEHA")]
		[int]$HaNodes,

		[Parameter(Mandatory=$false, Position=3, valuefromPipeline=$false,
			ParameterSetName = "ENABLEHA")]
		[Switch]$SharedHA
	)
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
		if 	($PsCmdlet.ParameterSetName -eq "ENABLEHA")		
		{
			if ($SharedHA)
			{
				$WasHaShared = Get-USXGlobalSetting -Recommender:ishashared
				if ($WasHaShared -ne $SharedHA)
				{
					$bResult = Set-USXGlobalSetting -Recommender:ishashared -Value $IsHaShared
				}
			}

			if ($HaNodes)
			{
				$OldNumHaNodes = Get-USXGlobalSetting -Recommender:numhanodes
				if ($OldNumHaNodes -ne $HaNodes)
				{
					$bResult = Set-USXGlobalSetting -Recommender:numhanodes -Value $HaNodes
				}
			}	
	    }
    }
	PROCESS 
	{	
	
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"	

			if 	($PsCmdlet.ParameterSetName -eq "ENABLEHA")		
			{
			
				$volume = Get-USXVolume -Name $item
			
				$builder = USXGetBuilder "usxmanager/workflows/volume/$($volume.uuid)/enableha"
				$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
				$query["format"] = "json"
				$builder.Query = $query.ToString();
		
				$url = $builder.ToString()
	  
				UsxPost -Url $Url
			}
		}
	}
	END
	{
		if ($SharedHA)
		{
			if ($WasHaShared -ne $SharedHA)
			{
				$bResult = Set-USXGlobalSetting -Recommender:ishashared -Value $WasHaShared
			}
		}

		if ($HaNodes)
		{
			if ($OldNumHaNodes -ne $HaNodes)
			{
				$bResult = Set-USXGlobalSetting -Recommender:numhanodes -Value $OldNumHaNodes
			}
		}

		Write-Debug "Leaving $($MyInvocation.MyCommand)"		
	}
}


function Set-USXDisableHA
{
<#
.Synopsis
Disable HA on a Volume (Datastore)
.Description
 Nice long description
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
		[String]$VolumeName
	)
	
	$VolumeServiceName = Get-USXVolume -Name $VolumeName

	$data = "$($VolumeServiceName.uuid)"	
			
	$builder = USXGetBuilder "usxmanager/usx/deploy/disable/ha/resources/$($data)"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
  
	return UsxPut -Url $Url
	return $result.uuid
}

function Add-USXLdap
{
<#
.Synopsis
Add LDAP Authentication to USX
.Description
 Nice long description
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
		[String]$BindDn,
		
		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false)]
		[String]$GroupDn,
		
		[Parameter(Mandatory=$false, Position=2, valuefromPipeline=$false)]
		[Boolean]$Ssl,
		
		[Parameter(Mandatory=$false, Position=3, valuefromPipeline=$false)]
		[String]$IpAddress,
		
		[Parameter(Mandatory=$false, Position=4, valuefromPipeline=$false)]
		[String]$Username,
		
		[Parameter(Mandatory=$false, Position=5, valuefromPipeline=$false)]
		[String]$Password,
		
		[Parameter(Mandatory=$false, Position=6, valuefromPipeline=$false)]
		[String]$Port		
	)
	
	$data = @{
            "binddn" = "$($BindDn)";
            "groupdn" = "$($GroupDn)";
            "ssl" = $($Ssl);
			"ipaddress" = "$($IpAddress)";
            "systemusername" = "$($Username)";
			"systempassword" = "$($Password)";
			"port" = "$($Port)"
			}
	
	$builder = USXGetBuilder "usxmanager/user/auth/ldap"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
  
	return UsxPost	-Url $Url -Data $data
	return $result.uuid
}

function Remove-USXServiceVM
{
<#
.Synopsis
Deletes a Service VM from the USX Manager
.Description
Deletes one or more USX Service VM's from the USX Manager.
.Example
Remove Service VM with display name "My Service VM"
Remove-USXServiceVM -Name "My Service VM"
.Example
Remove all Service VM's
Remove-USXServiceVM
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	Param(		
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("displayname")]
		[String[]]$Name,
		
		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false)]
		[switch]$Force = $true	
	)
	
    BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }	
    PROCESS 
	{	
	
		if (-not $Name)
		{
			Get-USXServiceVm | Remove-USXServiceVM
		}
		
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"
	
			if ($PsCmdlet.ShouldProcess($item))
		    {					
				$serviceVM = Get-USXServiceVM -Name $item

				$builder = USXGetBuilder "usxmanager/usx/manage/servicevm/$($serviceVM.uuid)"
				$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
				$query["forcedelete"] = $Force.ToString().ToLower()
				$builder.Query = $query.ToString();
				
				$url = $builder.ToString()
				UsxDelete -Url $Url			
			}
		}	
	}

	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}	
}


function Remove-USXVolume
{
<#
.Synopsis
Deletes a Volume (Datastore)from the USX Manager
.Description
Deletes one or more USX Volumes from the USX Manager. USX will delete the Volume VM's but not the HA VM's or Service VM's.
.Example
Remove volume with display name "My Volume"
Remove-USXVolume -Name "My Volume"
.Example
Remove all volumes
Remove-USXVolume
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	Param(
		
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("displayname")]
		[String[]]$Name,
	
		[Parameter(Mandatory=$false, Position=1, valuefromPipeline=$false)]
		[Switch]$IsVolume = $true,
		
		[Parameter(Mandatory=$false, valuefromPipeline=$false)]
		[Switch]$Force = $true
	)
    BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }	
    PROCESS 
	{	
	
		if (-not $Name)
		{
			Get-USXVolume | Remove-USXVolume
		}
		
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"
			$volume = Get-USXVolume -Name $item

			if ($PsCmdlet.ShouldProcess($item))
		    {					
				$builder = USXGetBuilder "usxmanager/usx/manage/volume/$($volume.uuid)"
				$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
				$query["forcedelete"] = $Force.ToString().ToLower()
				$query["isresource"] = $IsVolume.ToString().ToLower()
				$builder.Query = $query.ToString();
				
				$url = $builder.ToString()
			  
				UsxDelete -Url $Url
			}
		}
	}

	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}
}

function Get-USXJob
{
<#
.Synopsis
 Get USX Job
.Description
 Nice long description
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$false)]
		[Alias("id")]
		[String]$JobRefId
	)
	
	$builder = USXGetBuilder "usxmanager/jobstatus/inventory"
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["query"] = ".[jobrefid='$($JobRefId)']"
	$query["sortby"] = "uuid"
	$query["order"] = "ascend"
	
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	return UsxGet -Url $Url
#
}

function Get-USXContainer
{
<#
.Synopsis
 Get Container(s)
.Description
 Get all containers or get one container including HA container (by VM name)
.Example
 Todo
#Requires-Version 3.0
#>
	[CmdletBinding(DefaultParametersetName="PSNAME")]
	param(
		[Parameter(	Mandatory = $false, 
			Position=0,
			ParameterSetName = "PSNAME",
			ValuefromPipeline=$true,
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Name(s) of the container(s)')]
		[Alias('displayname', 'vmname')]
		[String[]]$Name,

		[Parameter(	Mandatory = $false, 
			Position=0,
			ParameterSetName = "PSVOLNAME",
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Volume name(s) associated with the container(s)')]
#		[Alias('uuid', 'containeruuid')]
		[String[]]$VolumeName,
	
		[Parameter(	Mandatory = $false, 
			Position=0,
			ParameterSetName = "PSCONID",
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Id (usx uuid) of the container(s)')]
		[Alias('containeruuid')]
		[String[]]$Id,

		[Parameter(	Mandatory = $false, 
			Position=0,
			ParameterSetName = "PSID",
			ValuefromPipelineByPropertyName = $true,
			HelpMessage = 'Enter the Id (usx uuid) of the container(s)')]
		[Alias('usxuuid','volumeresourceuuids')]
		[String[]]$Uuid
		
	)
	
    BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    } 
    PROCESS 
 	{ 
		$builder = USXGetBuilder "usxmanager/usx/inventory/volume/containers"

		if ($VolumeName)
		{
			$Id = Get-USXVolume -Name $VolumeName | select -ExpandProperty containeruuid
		}
		if ($Name -or $Id -or $Uuid)
		{
			if (IsUSXUUID $Name)
			{
				$Id = $Name
				$Name = $null
			}
			
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			if ($Name)
			{
				$query["query"] = ".[displayname=$([string]::Concat("'", $Name -join "'|'", "'"))]"
			}
			elseif ($Uuid)
			{
				$query["query"] = ".[volumeresourceuuids='$($Uuid -join "' or volumeresourceuuids='")']"
			}
			else
			{
				$query["query"] = ".[uuid='$($Id -join "' or uuid='")']"
			}
			
			$query["sortby"] = "uuid"
			$query["order"] = "ascend"
			$query["pagesize"] = $script:USXCredentials.PageSize			
			$builder.Query = $query.ToString();
		}
		
		$url = $builder.ToString()
		
		$result = USXGet -Url $Url
		
		return $result.items
	}

	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}
}

function Remove-USXContainer
{
<#
.Synopsis
Deletes an USX Container (Oprhaned HA VM)from the USX Manager
.Description
Deletes one or more (Orphaned) HA VS
.Example
Remove container with display name "My Container"
Remove-USXContainer -Name "My Container"
.Example
Remove all container
Remove-USXContainer
#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	Param(
		
		[Parameter(Mandatory=$false, Position=0, valuefromPipelineByPropertyName = $true)]
		[Alias("displayname")]
		[String[]]$Name,
			
		[Parameter(Mandatory=$false, valuefromPipeline=$false)]
		[Switch]$Force = $true
	)
    BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    }	
    PROCESS 
	{	
	
		if (-not $Name)
		{
			Get-USXContainer | Remove-USXContainer
		}
		
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"
			$container = Get-USXContainer -Name $item

			if ($PsCmdlet.ShouldProcess($item))
		    {					
				$builder = USXGetBuilder "usxmanager/usx/manage/volume/$($container.uuid)"
				$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
				$query["forcedelete"] = $Force.ToString().ToLower()
				$query["isresource"] = $false.ToString().ToLower()
				$builder.Query = $query.ToString();
				
				$url = $builder.ToString()
			  
				UsxDelete -Url $Url
			}
		}
	}

	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}
}


function Get-USXStorageProfile
{
<#
# This function fully works Last update 01:02 BST 1/7/2015
.Synopsis
 Get storage profile UUID for given datastore name
.Description
 Retrieves the USX UUID of the storage profile for a given datastore name
.Example
 Todo
#Requires-Version 3.0
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false, Position=0, valuefromPipeline=$true)]
	    [System.String]$Name
	)

	$builder = USXGetBuilder "usxmanager/configurator/storageprofiles"

	if ($Name)
	{
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["query"] = ".[datastorename='$($Name)']"
		$query["sortby"] = "uuid"
		$query["order"] = "ascend"
		$builder.Query = $query.ToString();
	}
	
	$url = $builder.ToString()
	
	$result = USXGet -Url $Url
	
	return $result.items
}

function Remove-USXStorageProfile
{
<#
# This function fully works Last update 01:02 BST 1/7/2015
.Synopsis
Removes a storage profile from hypervisor
.Description
 Provide the datastore name
.Example
 Todo
#Requires-Version 3.0
#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
        ConfirmImpact="High")]
	param(		
		[Parameter(	Mandatory=$true, 
					Position=0, 
					valuefromPipeline=$false,
					ValuefromPipelineByPropertyName = $true)]
		[Alias('datastorename')]
	    [String[]]$Name		
	) #param
	
	BEGIN{
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	}
	
	PROCESS{
	
		ForEach  ($item in $Name){
			
			$dataStore = Get-USXStorageProfile -Name $item
			
			$data = @($dataStore.uuid)
			
			$builder = USXGetBuilder "usxmanager/configurator/storageprofiles/batch"
			#$builder = USXGetBuilder "usxmanager/configurator/storageprofiles"
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			$query["format"] = "json"
			$builder.Query = $query.ToString();
			
			$url = $builder.ToString()
			
			$result = UsxDelete -Url $Url -Data $data
		
		} #Foreach

		return $result
	} #PROCESS
	
	END{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	} #END
	
} #Function


function Get-USXStatus
{
<#
.SYNOPSIS
 Get status information for volumes from any of volumeservicename/vmname/volumeresourceuuid. 
.DESCRIPTION
 Volumes must have been already deployed and mounted for this command to return status.
 Gets all Nine Status Details from /USX/STATUS/ALL and returns them to display (with -Full).
 Not all status information flags are relevant to all types of volume, which means a status of unknown is probably fine.
 
 The single status available by default is actuallt VOLUME_SERVICE_STATUS
 
 If the full switch is not present this will show only status information for the volume service status, this should be relevant to all volume types.
 

 
 This CMDLET is supported and maintained by Jim Moyle jim@atlantiscomputing.com
 Requires-Version 3.0
 
.PARAMETER InputType <String> 'VolumeName | UUID | VmName'

Limited to 3 values 'VolumeName | UUID | VmName' This also controls the result, if you leave the name parameter blank, but specify a type, it will return all volumes under the connected USX manager and also return the type information for that volume.

.PARAMETER Name <string>

Name is per volume and has aliases of : 'volume, uuid, usxuuid, volumeresourceuuid, vmname, vm'  All these van be used to import data via pipeline or CSV.

.PARAMETER Full <switch>

This switches between 1 and 9 statues, -Full is all 9, 1 is just VOLUME_SERVICE_STATUS
  
 .EXAMPLE
Get-USXStatus

Gets all volumes for current connection and return the status with associated volume names

Status                                            Type                                              VolumeName
------                                            ----                                              ----------
OK                                                SIMPLE_HYBRID                                     default-VOLUME-SERVICE006
OK                                                SIMPLE_HYBRID                                     default-VOLUME-SERVICE008
OK                                                SIMPLE_HYBRID                                     default-VOLUME-SERVICE005

 .EXAMPLE
Get-USXStatus -InputType VolumeName -Name default-VOLUME-SERVICE006,default-VOLUME-SERVICE008

Gets single status for both volumes listed
 .EXAMPLE
Get-USXStatus -Name default-VOLUME-SERVICE006,default-VOLUME-SERVICE008

Gets single status for both volumes listed
 .EXAMPLE
Get-USXStatus default-VOLUME-SERVICE006,default-VOLUME-SERVICE008

Gets single status for both volumes listed
 .EXAMPLE
Get-USXStatus -Full

Gets all volume status information for all volumes

VolumeService      : OK
ExportAvailability : OK
DedupFilesystem    : OK
VolumeStorage      : OK
Container          : OK
HA                 : UNKNOWN
HAFailover         : UNKNOWN
RaidSync           : UNKNOWN
VolumeExtension    : UNKNOWN
Type               : SIMPLE_HYBRID
VolumeName         : default-VOLUME-SERVICE006

VolumeService      : OK
ExportAvailability : OK
DedupFilesystem    : OK
VolumeStorage      : OK
Container          : OK
HA                 : UNKNOWN
HAFailover         : UNKNOWN
RaidSync           : UNKNOWN
VolumeExtension    : UNKNOWN
Type               : SIMPLE_HYBRID
VolumeName         : default-VOLUME-SERVICE008

VolumeService      : OK
ExportAvailability : OK
DedupFilesystem    : OK
VolumeStorage      : OK
Container          : OK
HA                 : UNKNOWN
HAFailover         : UNKNOWN
RaidSync           : UNKNOWN
VolumeExtension    : UNKNOWN
Type               : SIMPLE_HYBRID
VolumeName         : default-VOLUME-SERVICE005
 .EXAMPLE
Get-USXStatus -InputType VolumeName -Full

Gets all volume status information for all volumes
 .EXAMPLE
'default-VOLUME-SERVICE006','default-VOLUME-SERVICE008' | Get-USXStatus

Gets single status for both volumes listed
 .EXAMPLE
Import-Csv c:\JimM\volumes.csv | Get-USXstatus

Gets status information for all volumes listed in the CSV, as long as CSV title is Name or one of its aliases
 .EXAMPLE
Get-USXStatus -InputType UUID USX_08eaee72-225a-3cf3-9595-6381f3d7942c,USX_555a9d76-14d3-3e12-b736-4cb26cce10a5 -verbose -Full

Gets all volumes status for two listed by UUID
 .EXAMPLE
Get-USXStatus -InputType UUID
 .EXAMPLE
'USX_08eaee72-225a-3cf3-9595-6381f3d7942c','USX_555a9d76-14d3-3e12-b736-4cb26cce10a5' | get-USXStatus -InputType UUID

Gets a single volume status for two listed by UUID
 .EXAMPLE
Import-Csv c:\JimM\uuid.csv | Get-USXstatus -InputType UUID

Gets single status for all UUIDs listed in the CSV, as long as CSV title is Name or one of its aliases
 .EXAMPLE
Get-USXStatus -InputType VmName default-VOLUME007,default-VOLUME010

Gets status by VMName for both volumes
 .EXAMPLE
'default-VOLUME007','default-VOLUME010' | get-USXStatus -InputType VmName

Gets status by VMName for both volumes
 .EXAMPLE
Get-USXStatus -InputType VmName

Returns a single status for each volume associted with it's vm name
 .EXAMPLE
Import-Csv c:\JimM\vms.csv | Get-USXstatus -InputType VmName -Full

Gets all statuses for all vms listed in the CSV, as long as CSV title is Name or one of its aliases
#>
	[CmdletBinding(DefaultParametersetName="PSVOLUME")]
	param(
		
		[Parameter(Mandatory=$false,
			valuefromPipeline = $true,
			valuefromPipelineByPropertyName = $true,
			Position = 0,
			ParameterSetName = "PSVOLUME")]
		[Alias('displayname,volumeservicename')]
		[String[]]$Name,

		[Parameter(Mandatory=$false,
			valuefromPipelineByPropertyName = $true,
			Position = 0,
			ParameterSetName = "PSVMNAME")]
		[Alias('vm,machinename')]
		[String[]]$VMName,

		[Parameter(Mandatory=$false,
			valuefromPipelineByPropertyName = $true,
			Position = 0,
			ParameterSetName = "PSID")]
		[Alias('uuid,usxuuid')]
		[String[]]$Id,

		[Parameter(Mandatory=$false,
			valuefromPipeline=$false,
			Position = 1)]
		[Switch]$Full = $false
	) #param
		
		
	BEGIN{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	} #BEGIN
	
    PROCESS { 
		$builder = USXGetBuilder "usxmanager/usx/status/all"
		$uuidList = @() #This is to prevent duplicate entries when the pipeline is used
		
		switch ($PsCmdlet.ParameterSetName)
		{
			'PSVOLUME' { $uuidList = Get-USXVolume -Name $Name | select -ExpandProperty uuid ; break }
			'PSVMNAME' { $uuidList = Get-USXVolume -VMName $VMName | select -ExpandProperty uuid ; break }	
			'PSID' { $uuidList = $Id ; break }
		}
		
		$result = @() #Setting up result variable before foreach is run
		
		ForEach ($item in $uuidList)
		{
			
			$vol = Get-USXVolume -Id $item
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			$query["query"] = ".[usxuuid='$($item)']"
			$query["sortby"] = "usxuuid"
			$query["order"] = "ascend"
			$query["pagesize"] = $script:USXCredentials.PageSize
			$builder.Query = $query.ToString();
			
			$url = $builder.ToString()
			
			$urlresult = USXGet -Url $Url
			
			$trimresult = $urlresult.items | Select-Object -ExpandProperty usxstatuslist | select-object name,value
		
			$intVMName = Get-USXContainer -Id $vol.containeruuid | select -ExpandProperty displayname
			
			$props = [ordered]@{'Name' = $vol.displayname;
								'VolumeType' = $vol.volumetype;
								'VolumeService' = ($trimresult | Where-object {$_.name -eq 'VOLUME_SERVICE_STATUS'}).value;
					   			'ExportAvailability' = ($trimresult | Where-object {$_.name -eq 'VOLUME_EXPORT_AVAILABILITY'}).value;
								'DedupFilesystem' = ($trimresult | Where-object {$_.name -eq 'DEDUP_FILESYSTEM_STATUS'}).value;
								'VolumeStorage' = ($trimresult | Where-object {$_.name -eq 'VOLUME_STORAGE_STATUS'}).value;
								'Container' = ($trimresult | Where-object {$_.name -eq 'CONTAINER_STATUS'}).value;
								'HA' = ($trimresult | Where-object {$_.name -eq 'HA_STATUS'}).value;
								'HAFailover' = ($trimresult | Where-object {$_.name -eq 'HA_FAILOVER_STATUS'}).value;
								'RaidSync' = ($trimresult | Where-object {$_.name -eq 'RAID_SYNC_STATUS'}).value;
								'VolumeExtension' = ($trimresult | Where-object {$_.name -eq 'VOLUME_EXTENSION_STATUS'}).value;									
								'VMName' = $intVMName;
								'Id' = $item;
					  		   } #props
			
			$obj = New-Object -TypeName PSObject -Property $props
			$result += $obj
		}
		
		if (!$Full)
		{
			$result = $result | select Name, VolumeType, VolumeService, VMName, Id
		}
		
		return $result | sort Name
				
	} #PROCESS

	END{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	} #END

} #function Get-USXStatus


function removeconfig{
	try{
		Get-USXNameTemplate -WarningAction SilentlyContinue | Remove-USXNameTemplate -Confirm:$false -WarningAction SilentlyContinue
		Get-USXNetwork -WarningAction SilentlyContinue | Remove-USXNetwork -Confirm:$false -WarningAction SilentlyContinue
		Get-USXStorageProfile -WarningAction SilentlyContinue | Remove-USXStorageProfile -WarningAction SilentlyContinue # -Confirm:$false 
		Get-USXHypervisor -WarningAction SilentlyContinue | Remove-USXHypervisor -Confirm:$false -WarningAction SilentlyContinue
		} #try
	
	finally{
			Write-Verbose "`n Existing Name Templates, Network templates and Storage profiles have been removed"
	} #finally
} #function removeconfig

function Wait-USXStatus{

	[CmdletBinding()]
	
	param(	
		[Parameter(	Mandatory = $true, 
					ValuefromPipelineByPropertyName = $true,
					HelpMessage = 'Enter the Name for the volume' )]
		[Alias('volume' , 'displayname' , 'volumename')]
		[String]$Name,
		
		[Parameter(	Mandatory=$false, 
					ValuefromPipelineByPropertyName = $true,
					HelpMessage = 'Enter the timeout value beyond which we should not wait for the volume to become available' )]
		[int]$Timeout = (10*60)
	) #param	
		
	$now = Get-Date
	
	$isCompleted = $false
	
	while (!($isCompleted))
	{
		$secondsElapsed = (New-TimeSpan -Start $now -End (Get-Date)).TotalSeconds
		
		if ($secondsElapsed -ge $TimeOut)
		{
			Write-Verbose "Timed out waiting for volume $Name to deploy"
			Write-Error 'Volume deployment timed out'
			return $false
		}
		
		#Get volumeservice status
		$status = (Get-USXStatus -Name $Name | Select-Object -ExpandProperty volumeservice)
		
		if ($status -eq 'OK')
		{
			$isCompleted = $true
		}
		
		Start-Sleep -Seconds 5
		
	}
	Write-Verbose "$Name deployment has finished $Status"
	return $true
	
}# Function Wait USX Status

function Add-USXCSVDeployment{
	[CmdletBinding()]
	param(	
		[Parameter(	Mandatory = $true, 
					ValuefromPipelineByPropertyName = $true,
					HelpMessage = 'Enter the Name(s) for the simple volumes which you wish to deploy' )]
		[Alias('volume' , 'displayname' , 'volumename','volumeservicename')]
		[String[]]$Name,
		
		[Parameter(	Mandatory=$true, 
					ValuefromPipelineByPropertyName = $true )]
		[USX.SIMPLEVolume]$SimpleType,
		
		[Parameter(	Mandatory=$true, 
					ValuefromPipelineByPropertyName = $true )]
		[Alias('Size')]
		[int[]]$VolumeSize,
		
		[Parameter( Mandatory = $true,
					ValuefromPipelineByPropertyName = $true,
					HelpMessage = 'Enter the Name(s) of the vcenters you wish to deploy to (once per volume)' )]
		[Alias('Vcenter')]
		[String[]]$VMManager,
		
		[Parameter( Mandatory = $true,
					ValuefromPipelineByPropertyName = $true,
					HelpMessage = 'Enter the Name(s) of the physical hosts you wish to deploy too (once per volume)' )]
		[Alias('Hypervisor')]
		[String[]]$HostName,
		
		[Parameter(	Mandatory=$true, 
					ValuefromPipelineByPropertyName = $true,
					HelpMessage = 'enter the IP for the NFS storage' )]
		[string[]]$StorageIp,
		
		[Parameter(	Mandatory=$true, 
					ValuefromPipelineByPropertyName = $true )]
		[string[]]$StorageNetmask,
		
		[Parameter(	Mandatory=$true, 
					ValuefromPipelineByPropertyName = $true,
					HelpMessage = 'Enter the (case sensitive) name of the network exactly as it states in the VM Manager')]
		[string[]]$StorageNetworkName,

		[Parameter(	Mandatory=$true, 
					ValuefromPipelineByPropertyName = $true )]
		[string[]]$Gateway,
		
		[Parameter(	Mandatory=$true, 
					ValuefromPipelineByPropertyName = $true )]
		[string[]]$Datastore,

		[Parameter(	Mandatory=$true, 
					ValuefromPipelineByPropertyName = $true )]
		[string[]]$VmName,		
		
		[Parameter(	Mandatory=$false, 
					ValuefromPipelineByPropertyName = $true )]
		[string[]]$ManagementIp,
		
		[Parameter(	Mandatory=$false, 
					ValuefromPipelineByPropertyName = $true )]
		[string[]]$ManagementNetmask,
		
		[Parameter(	Mandatory=$false, 
					ValuefromPipelineByPropertyName = $true,
					HelpMessage = 'Enter the (case sensitive) name of the network exactly as it states in the VM Manager' )]
		[string[]]$ManagementNetworkName,
		
		[Parameter(	Mandatory=$false, 
					ValuefromPipelineByPropertyName = $true )]
		[string[]]$OsDatastore,		
		
		[Parameter(	Mandatory=$false, 
					ValuefromPipelineByPropertyName = $true )]
		[string[]]$MemoryToDiskRatio,
		
		[Parameter(	Mandatory=$false,
					ValuefromPipelineByPropertyName = $true )]
		[USX.VMManager]$VMManagerType = 'VCENTER',
		
		[Parameter(	Mandatory = $false,
					ValuefromPipelineByPropertyName = $true )]
		[alias('username')]
		[string]$VMMUsername,
		
		[Parameter(	Mandatory = $false,
					ValuefromPipelineByPropertyName = $true )]
		[alias('password')]
		[string]$VMMPassword,
		
		[Parameter(	Mandatory = $false,
					ValuefromPipelineByPropertyName = $true )]
		[alias('TimeoutSeconds')]
		[int]$Timeout = (60 * 10),
		
		[Parameter(Mandatory = $false,
				   ValuefromPipelineByPropertyName = $true)]
		[switch]$EnableSnapshots = $false,
		
		[Parameter(Mandatory = $false)]
		[switch]$NoMount = $false
	
	) #param
	
	BEGIN{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	} #BEGIN
	
    PROCESS {
		
		#setting up object from param input, should work for both pipeline and CLI
		
		$props = @{	'obName' = $Name;
					'obSimpleType' = $SimpleType
					'obVolumeSize' = $VolumeSize
					'obVMManager' = $VMManager;
					'obHostName' = $HostName;
					'obNfsIP' = $StorageIp;
					'obNfsMask' = $StorageNetmask;
					'obNfsName' = $StorageNetworkName;
					'obGateway' = $Gateway;
					'obDatastore' = $Datastore;
					'obVmName' = $VmName;
					'obMgtIP' = $ManagementIP;
					'obMgtMask' = $ManagementNetmask;
					'obMgtName' = $ManagementNetworkName;
					'obOsDatastore' = $OsDatastore;
					'obMemoryToDiskRatio' = $MemoryToDiskRatio
					'obVMManagerType' = $VMManagerType;
					'obVMMUsername' = $VMMUsername;
					'obVMMPassword' = $VMMPassword
					'obTimeout' = $Timeout
				  } # props
		
		$importObj = New-Object -TypeName PSObject -Property $props
		
		#Looping through new object to get individual values for each deployment
		
		ForEach-Object -InputObject $importObj  -Process {
			[string]$volumeServiceName =  $_.'obName'
			[string]$volType = $_.'obSimpleType'
			[string]$volSize = $_.'obVolumeSize'
			[string]$usxVmManager = $_.'obVMManager'
			[string]$hyperVisor = $_.'obHostName'
			[string]$nfsIp = $_.'obNfsIP'
			[string]$nfsMask = $_.'obNfsMask'
			[string]$nfsName = $_.'obNfsName'
			[string]$defaultGw = $_.'obGateway'
			[string]$MachineName = $_.'obVmName'
			[string]$mgtIp = $_.'obMgtIP'
			[string]$mgtMask = $_.'obMgtMask'
			[string]$mgtName = $_.'obMgtName'
			[string]$backStore = $_.'obDatastore'
			[string]$osStore = $_.'obOsDatastore'
			[string]$memToDiskRatio = $_.'obMemoryToDiskRatio'
			[string]$vmmType = $_.'obVMManagerType'
			[string]$usxVmmUser = $_.'obVMMUsername'
			[string]$usxVmmPass = $_.'obVMMPassword'
			[int]$deployTimeout = $_.'obTimeout'

			
			#INSERT check to see if any of the mandatory params are blank as PoSH appears to let them through via pipeline

			
			#Remove all existing settings, apart from vmmanager
			removeconfig | out-null
			
			#Add VM Manager if it's not already there.
			
			if ($usxVmManager -ne ((Get-USXVMManager -Name $usxVmManager).name))
			{
				try
				{
					$result = Add-USXVMManager -Name $usxVmManager -User $usxVmmUser -Password $usxVmmPass -VMManagerType $VMManagerType -VMManagerHostname $usxVmManager -ErrorAction Stop
					
					#When VM Manager is added, we need to wait while USX brings settings into USX Manager, trying to add a hypervisor immediately will fail the following waits for hypervisors or times out after 60 seconds
					
					$enumerateTimeout = (3 * 60)
					
					$isEnumerated = $false
					
					$now = Get-Date
					
					while (!($isEnumerated))
					{
						$secondsElapsed = (New-TimeSpan -Start $now -End (Get-Date)).TotalSeconds
						
						if ($secondsElapsed -ge $enumerateTimeout)
						{
							Write-Verbose "Timed out waiting for hypervisors to enumerate"
							$isEnumerated = $true
						}
						Write-Verbose "Checking if hypervisors have been enumerated, next check in 5 seconds"
						if (get-usxhypervisor -ErrorAction SilentlyContinue)
						{
							Write-Verbose "Hypervisors have been enumerated"
							$isEnumerated = $true
						}
						else
						{
							Write-Verbose "starting sleep"
							Start-Sleep -Seconds 5
						}
					}
				}
				catch
				{
					Write-Error "Cannot create connection from USX Manager to $usxVmManager please check all credentials and names."
					break
				}
			}
			
			#Add Hypervisor
			Write-Verbose "Adding Hypervisor with: Add-USXHypervisor -VMManager $usxVmManager -Name $hyperVisor"
			try
			{
				$result = Add-USXHypervisor -VMManager $usxVmManager -Name $hyperVisor -ErrorAction Stop
			}
			catch
			{
				Write-Error -Message "Failed to add $hyperVisor to $usxVmManager"
				break
			}
			<#Add Storage
			Only configure one datastore if optional param for OS has not been specified, configure both if both specified
			If both specified set OS to flash so we can use the global prefs to control disk location
			This is a pretty horrible way to control disk location, but the API doesn't allow to specify
			It's possible that there are situations where this placement method won't work.
			Should add check later if possible to confirm location and warn if it hasn't worked
			#>
			if ($osStore)
			{
				try
				{
					Add-USXStorage -Name $osStore -Flash -ErrorAction Stop | Out-Null
					Add-USXStorage -Name $backStore -ErrorAction Stop | Out-Null
				}
				catch
				{
					Write-Error -Message "Failed to add either $osStore or $backStore to USX Manager"
					break
				}
			} #if osStore
			else
			{
				try
				{
					Add-USXStorage -Name $backStore -ErrorAction Stop | Out-Null
				}
				catch
				{
					Write-Error -Message "Failed to add $osStore to USX Manager"
					break
				}
			}
			
			
			#Add Network Profile, only add storage if management not specified, if one, gateway on that network, if two gateway on management network.
			Write-Verbose "Adding Network Profile(s)"
			$netNameStorage = $volumeServiceName + "Storage"
			$netNameMgt = $volumeServiceName + "Management"
			if ($mgtIP -and $mgtMask)
			{
				try
				{
					Write-Verbose 'Adding both Management and Storage networks'
					#Adding both Management and network profiles as there is a management IP present
					#adding storage Network
					Add-USXNetwork -Name $netNameStorage -Type:STORAGE -AddressMode:STATIC -IpRanges "$nfsIp-$nfsIp" -Netmask $nfsMask -ErrorAction Stop | Out-Null
					Add-USXNetworkProfile -Name $netNameStorage -HyperVisor $hyperVisor -NetworkName $nfsName -ErrorAction Stop | Out-Null
					
					#adding Management Network with gateway on mgt network
					Add-USXNetwork -Name $netNameMgt -Type:MANAGEMENT -AddressMode:STATIC -IpRanges "$mgtIp-$mgtIp" -Netmask $mgtMask -Gateway $defaultGW -ErrorAction Stop | Out-Null
					Add-USXNetworkProfile -Name $netNameMgt -HyperVisor $hyperVisor -NetworkName $mgtName -ErrorAction Stop | Out-Null
				}
				catch
				{
					Write-Error -Message "Failed to add Network to USX Manager"
					break
				}
			}
			else
			{
				try
				{
					Write-Verbose 'Adding only and Storage networks as it is combined with management'
					#adding storage Networkwith gateway
					Add-USXNetwork -Name $netNameStorage -Type:STORAGE -AddressMode:STATIC -IpRanges "$nfsIp-$nfsIp" -Netmask $nfsMask -Gateway $defaultGW -ErrorAction Stop | Out-Null
					Add-USXNetworkProfile -Name $netNameStorage -HyperVisor $hyperVisor -NetworkName $nfsName -ErrorAction Stop | Out-Null
				}
				catch
				{
					Write-Error -Message "Failed to add Network to USX Manager"
					break
				}
			}
			
			#Add volume Name template
			#chop name up
			#remove FQDN (everything after 1st (.) 
			$notfqdn = $machineName.split(".")[0]
<#			#regex to extract prefix, number and postfix from name
			$notfqdn -match "([\w]+[\D])([\d]+)([\D]*$)"
			$templatePrefix = $matches[1]
			$templateNumber = $matches[2]
			$templatePostfix = [string]$matches[3]
			$templateDigits = $templateNumber.length
			$templateName = $notfqdn
			
			if ($notfqdn -ne $templatePrefix + $templateNumber + $templatePostfix)
			{
				#check to see if name matches origibnal after it's been chopped upo and put back together again
				Write-Error 'Name does not match input name after being chopped up with RegEx, please deploy manually.'
				exit
			} #if machinename
			
			if ($templatePostfix)
			{
				try
				{
					Add-USXNameTemplate -Name $templateName -Type:VOLUME -Prefix $templatePrefix -Postfix $templatePostfix -NumberOfDigits $templateDigits -StartingNumber $templateNumber -ErrorAction Stop
				}
				catch
				{
					Write-Error -Message "Failed to add Name Template $templateName to USX Manager"
					break
				}
			} #if postfix
			else
			{
				
				try
				{
					Add-USXNameTemplate -Name $templateName -Type:VOLUME -Prefix $templatePrefix -NumberOfDigits $templateDigits -StartingNumber $templateNumber -ErrorAction Stop
				}
				catch
				{
					Write-Error -Message "Failed to add Name Template $templateName to USX Manager"
					break
				}
				
			} #else postfix
			#>
			#deploy volume
			#add mandatory parameters
			
			$params = @{
				Name = [string]"$notfqdn"
				Simple = $volType
				ExportType = 'NFS'
				StorageNetwork = $netNameStorage
				SizeGB = $volSize
				#VolumeVMTemplate = $templateName
				VolumeName = [string]"$name"
			}
			
			#$deployCommand = "Add-USXVolume -Name $volumeServiceName -Simple:$volType -ExportType:NFS -StorageNetwork $netNameStorage -SizeGB $volSize -VolumeVMTemplate $templateName"
			
			if ($mgtIP -and $mgtMask)
			{
				$params.Add('ManagementNetwork' , $netNameMgt )
			}
			
			if ($memToDiskRatio)
			{
				$params.Add('MemoryToDiskRatio' , $memToDiskRatio)
			}
			
			if ($EnableSnapshots -and $SimpleType -ne "SIMPLE_MEMORY")
			{
				$params.Add('EnableSnapshots', $true)
			}
					
			
			try
			{
				$result = Add-USXVolume @params
			}
			catch
			{
				$invokeMessage = $error[0].Exception.message
				Write-Error "add-usxvolume failed with $invokeMessage"
				break
			}
			#Wait for volume to become available
			
			Write-Verbose "Waiting for $volumeServiceName to be deployed, timeout is $deployTimeOut seconds"
			
			try
			{
				$result = Wait-USXStatus $volumeServiceName -timeout $deployTimeOut -WarningAction SilentlyContinue -ErrorAction Stop
			}
			catch
			{
				$waitMessage = $error[0].Exception.message
				Write-Error -Message "Wait-USXstatus Failed with $waitMessage"
				break
			}
			
			if ($result -and -not $NoMount)
			{
				$mountTargets = Get-USXHypervisor | Where-Object {$_.cluster -eq ((Get-USXHyperVisor $hyperVisor).cluster)} | Select-Object -expandproperty hypervisorname
				
				ForEach ($target in $mountTargets)
				{
					Write-Verbose "Mounting $volumeServiceName on $target"
					Mount-USXVolume -Name $volumeServiceName -Hypervisor $target | out-null
				}
			} #if result of status
			
		} #foreach-object
		
		#Remove all existing settings, apart from vmmanager
		try
		{
			removeconfig | Out-Null
		}
		catch
		{
			Write-Warning "Failed to remove configuration after volume deployment"
		}
		
		$props = @{
			DeployResult = $true
			Name = [string]"$notfqdn"
		}
		
		$returnObject = New-Object -TypeName System.Management.Automation.PSObject -Property $props
		
		Write-Output $returnObject
	} #PROCESS
	
	END{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	} #END
	
} #function Add-USXSimpleVolume

function Get-USXCSVDeployment
{
	[CmdletBinding(DefaultParametersetName="PSID")]
	param(
	
	[Parameter(Mandatory=$false,
		valuefromPipeline = $true,
		valuefromPipelineByPropertyName = $true,
		Position = 0,
		ParameterSetName = "PSVOLUME")]
	[Alias('displayname,volumeservicename')]
	[String[]]$Name,

	[Parameter(Mandatory=$false,
		valuefromPipelineByPropertyName = $true,
		Position = 0,
		ParameterSetName = "PSVMNAME")]
	[Alias('vm,machinename')]
	[String[]]$VMName,

	[Parameter(Mandatory=$false,
		valuefromPipelineByPropertyName = $true,
		Position = 0,
		ParameterSetName = "PSID")]
	[Alias('uuid,usxuuid,volumeresourceuuids')]
	[String[]]$Id
	
	) #param
	
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	} #BEGIN
	
    PROCESS 
	{
		$uuidList = @() #This is to prevent duplicate entries when the pipeline is used
		$loopResult = @()
		$result = @()
		
		if (!($Id -or $VMName -or $Name))
		{
			$Id = (Get-USXVolume).uuid
		}
		
		switch ($PsCmdlet.ParameterSetName)
		{
			'PSVOLUME' { $uuidList = Get-USXVolume -Name $Name | select -ExpandProperty uuid ; break }
			'PSVMNAME' { $uuidList = Get-USXVolume -VMName $VMName | select -ExpandProperty uuid ; break }	
			'PSID' { $uuidList = $Id ; break }
		}
		

		
		ForEach ($uuid in $uuidList)
		{
			$getUSXVolume = Get-USXVolume -id $uuid
			$getUSXContainer = Get-USXContainer -uuid $uuid
			
			#Get gateway info
			$storGW = $getUSXContainer.nics | where-object {$_.storagenetwork -eq $true} | Select-Object -ExpandProperty gateway
			$mgtGW = $getUSXContainer.nics | where-object {$_.storagenetwork -eq $false} | Select-Object -ExpandProperty gateway
			
			if ( $storGW -eq $mgtGW)
			{
				$resultGateway = $mgtGW
			}
			else
			{
				$resultGateway = $storGW + $mgtGW
			}
			
			#Get datastorename and use regex to get name within []
			$getUSXVolume.raidplans.raidbricks.diskfullname -as [string] -match "\[(.*)\]" | Out-Null
			$regexDatastore = $matches[1]
			
			$props = [ordered]@{
				'Name' = $getUSXVolume.volumeservicename;
				'SimpleType' = $getUSXVolume.volumetype;
				'VolumeSize' = $getUSXVolume.volumesize;
				'VmName' = $getUSXContainer.displayname;
				'Vcenter' = $getUSXContainer.vmmanagername;
				'HostName' = $getUSXContainer.usxvm.hypervisorname;
				'StorageIp' = $getUSXContainer.nics | where-object {$_.storagenetwork -eq $true} | Select-Object -ExpandProperty ipaddress;
				'StorageNetmask' = $getUSXContainer.nics | where-object {$_.storagenetwork -eq $true} | Select-Object -ExpandProperty netmask;
				'StorageNetworkName' = $getUSXContainer.nics | where-object {$_.storagenetwork -eq $true} | Select-Object -ExpandProperty networkname;
				'Gateway' = $resultGateway
				'ManagementIp' = $getUSXContainer.nics | where-object {$_.storagenetwork -eq $false} | Select-Object -ExpandProperty ipaddress;
				'ManagementNetmask' = $getUSXContainer.nics | where-object {$_.storagenetwork -eq $false} | Select-Object -ExpandProperty netmask;
				'ManagementNetworkName' = $getUSXContainer.nics | where-object {$_.storagenetwork -eq $false} | Select-Object -ExpandProperty networkname;
				'DataStore' = $regexDatastore;
				'MemoryToDiskRatio' = if($getUSXVolume.volumetype -eq 'SIMPLE_HYBRID'){$getUSXVolume.raidplans.hybridratio};
				'VMManagerType' = $getUSXContainer.usxvm.vmmanagertype;
				'VMMUsername' = (Get-USXVMManager).username;
				'VMMPassword' = ''
				'TimeoutSeconds' = 600
				}
			
			$loopResult = New-Object -TypeName PSObject -Property $props
			
			
			$result += $loopResult

			#OsDatastore

		} #foreach uuid
		
		
		return $result
		
		
	} #PROCESS
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	} #END

}

<#
	.SYNOPSIS
		Upload a new plugin to USX Manager
	
	.DESCRIPTION
		Uploads and enables a new plugin to USX Manager
	
	.PARAMETER Path
		Specifies the path to an USX Plugin zip file. The parameter name ("Path" or "FilePath") is optional..
	
	.NOTES
		Additional information about the function.
#>
function Add-USXPlugin
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true)]
		[ValidateScript({ Test-Path $_ })]
		[Alias('FilePath')]
		[string[]]$Path
	)
	
	#param
	
	BEGIN
	{
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	} #BEGIN
	
	PROCESS
	{
		Add-Type -AssemblyName System.Net.Http | Out-Null
		
		$builder = USXGetBuilder "usxmanager/plugins/upload"
		
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$builder.Query = $query.ToString();
		$url = $builder.ToString()
		
		ForEach ($InFile in $Path)
		{
			$httpClientHandler = New-Object System.Net.Http.HttpClientHandler
			$httpClientHandler.CookieContainer = $script:cookieJar
			$httpClient = New-Object System.Net.Http.Httpclient $httpClientHandler
			
			$packageFileStream = New-Object System.IO.FileStream @($InFile, [System.IO.FileMode]::Open)
			
			$contentDispositionHeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
			$contentDispositionHeaderValue.Name = "file"
			$contentDispositionHeaderValue.FileName = (Split-Path $InFile -leaf)
			
			$streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
			$streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
			$streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue "application/x-zip-compressed"
			
			$content = New-Object System.Net.Http.MultipartFormDataContent
			$content.Add($streamContent)
			
			try
			{
				$response = $httpClient.PostAsync($url, $content).Result
				
				if (!$response.IsSuccessStatusCode)
				{
					$responseBody = $response.Content.ReadAsStringAsync().Result
					$errorMessage = "Status code {0}. Reason {1}. Server reported the following message: {2}." -f $response.StatusCode, $response.ReasonPhrase, $responseBody
					
					throw [System.Net.Http.HttpRequestException]$errorMessage
				}
				
				$response.Content.ReadAsStringAsync().Result
			}
			finally
			{
				if ($null -ne $httpClient)
				{
					$httpClient.Dispose()
				}
				
				if ($null -ne $response)
				{
					$response.Dispose()
				}
			}
		}
		
	} #PROCESS
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	} #END
}


function Invoke-USXPlugin
{
	[CmdletBinding()]
	param(
		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true,
			ValueFromPipeline = $true)]
		[alias('pluginname,pluginanme')]
		[string]$Name,

		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true)]
			[alias('Body','Data')]
		[string]$PluginJson
		
	) #param
		
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	} #BEGIN
	
    PROCESS 
	{
		#check plugin name is in expected format
		if (-not ($Name -match "^usxops\.(.*)\-plugin$"))
		{
			Write-Warning "$Name does not appear to be in the correct format of usxops.<Name>-plugin"
		}
				
		$builder = USXGetBuilder "usxmanager/plugins/execute/$($Name)"
		
		$data = ConvertFrom-json $PluginJson
		
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["format"] = "json"
		$builder.Query = $query.ToString();
		
		$url = $builder.ToString()
		
		$result = USXPost -Url $Url -Data $data
		
		return $result
		
		
	} #PROCESS
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	} #END

} #function Invoke-USXPlugin

function Remove-USXPlugin
{
<#
.Synopsis
Remove USX Plugin
.Description
Removes one or more USX plugins from USX Manager
.Example
Remove-USXPlugin -Name "usxops.snapclone-config-plugin"

Remove the plugin named "usxops.snapclone-config-plugin"

.Example
Remove-USXPlugin

Remove all Plugins

#Requires-Version 3.0
#>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "High")]
	param(
		[Parameter(
			Mandatory = $false, 
			Position = 0,
			ValuefromPipelineByPropertyName = $true)]
		[Alias('pluginanme','pluginname')]
		[String[]]$Name
	) #param
    
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
    } #BEGIN
    
	PROCESS 
	{	
	
		if (-not $Name)
		{
			Get-USXPlugin | Where-Object {$_.systemplugin -ne $True} | Remove-USXPlugin
		} #if not name
		
		ForEach ($item in $Name)
		{
			Write-Debug "Processing $($item)"	

			if ($PsCmdlet.ShouldProcess($item))
			{
				Write-Debug "Deleting $item" 
				$builder = USXGetBuilder "usxmanager/plugins/$($item)"
				$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
				$query["format"] = "json"
				$builder.Query = $query.ToString();
				
				$url = $builder.ToString()
			  
				UsxDelete -Url $Url
				
			} #if confirmed
		} #Foreach item in name
	} #PROCESS
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	}#END

} #function Remove-USXPlugin

function Get-USXPlugin
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false,
			valuefromPipeline = $true,
			valuefromPipelineByPropertyName = $true,
			Position = 0)]
		[Alias('pluginname,systemplugin,pluginanme')]
		[String[]]$Name
	) #param
	
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	} #BEGIN
	
    PROCESS 
	{
		$builder = USXGetBuilder "usxmanager/plugins"
		
		
		if ($Name)
		{
			if (-not ($Name -match "^usxops\.(.*)\-plugin$"))
			{
				Write-Warning "$Name does not appear to be in the correct format of usxops.<Name>-plugin"
			}
			
			$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
			$query["query"] = ".[pluginname='$($Name)']"
			$query["sortby"] = "uuid"
			$query["order"] = "ascend"
			$builder.Query = $query.ToString();
		}	

		$url = $builder.ToString()
		
		$result = USXGet -Url $Url
		
		return $result.items
				
	} #PROCESS
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	} #END
} #function get-USXPlugin


function usxPluginDiscover
{
	#helper function to discover plugins
	$builder = USXGetBuilder "usxmanager/plugins/discover"
		
	#$data = $PluginJson
	
	$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
	$query["format"] = "json"
	$builder.Query = $query.ToString();
	
	$url = $builder.ToString()
	
	$result = USXPost -Url $Url #-Data $data
	
	return $result

}


function Invoke-USXPluginCommand
{
	[CmdletBinding(DefaultParametersetName="PSID")]
	param(
	
	[Parameter(Mandatory = $true,
		valuefromPipeline = $true,
		valuefromPipelineByPropertyName = $true,
		Position = 0,
		ParameterSetName = "PSVOLUME")]
	[Alias('displayname,volumeservicename')]
	[String]$Name,

	[Parameter(Mandatory = $true,
		valuefromPipelineByPropertyName = $true,
		Position = 0,
		ParameterSetName = "PSVMNAME")]
	[Alias('vm,machinename')]
	[String]$VMName,

	[Parameter(Mandatory = $true,
		valuefromPipelineByPropertyName = $true,
		Position = 0,
		ParameterSetName = "PSID")]
	[Alias('uuid,usxuuid,volumeresourceuuids')]
	[String]$Id,
	
	[Parameter (Mandatory = $true,
		valuefromPipelineByPropertyName = $false,
		Position = 1)]
	[String]$Command
	
	) #param
	
	BEGIN
	{       
		Write-Debug "Entering $($MyInvocation.MyCommand)"
	} #BEGIN
	
    PROCESS 
	{
		
		$uuidList = @{} 
		
		switch ($PsCmdlet.ParameterSetName)
		{
			'PSVOLUME' { $uuidList = Get-USXVolume -Name $Name | select -ExpandProperty containeruuid ; break }
			'PSVMNAME' { $uuidList = Get-USXVolume -VMName $VMName | select -ExpandProperty containeruuid ; break }	
			'PSID' { $uuidList = $Id ; break }
		}
		#Discoverplugins, needs to be run once for this to work
		usxPluginDiscover | Out-Null
		
		$builder = USXGetBuilder "usxmanager/plugins/execute/command"
		
		$data = @{	'targettype' = 'USX_VOLUME';
					'targetuuids' = [Object[]]$uuidList;
					'command' = $command
				  } #props
				  
		$query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
		$query["format"] = "json"
		$builder.Query = $query.ToString();
		
		$url = $builder.ToString()
		
		$result = USXPost -Url $Url -Data $data
		
		return $result
	

	} #PROCESS
	
	END
	{
		Write-Debug "Leaving $($MyInvocation.MyCommand)"
	} #END
	
} #Function Invoke-UsxPluginCommand


function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception |Format-List * -Force
   }
}

Export-ModuleMember '*-USX*'