#handle PS2
if(-not $PSScriptRoot)
{
	$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

Get-ChildItem $PSScriptRoot\ExportedFunctions\*.ps1 -Exclude *.Tests.ps1 | ForEach-Object {
	. $_.Fullname
}

Get-ChildItem $PSScriptRoot\PrivateFunctions\*.ps1 -Exclude *.Tests.ps1 | ForEach-Object {
	. $_.Fullname
}

<#
Add-Type -Path "$PSSCriptRoot\Newtonsoft.Json.dll"

$Script:DefaultServer = $null
$Script:Neo4JContentType = "application/json; charset=UTF-8"

function DiscoverEndpoints {
	param(
		[Parameter(Mandatory=$true)]
		$Uri,
		
		[Switch]$Force
	)
	Invoke-RestMethod -Uri $Uri -Method Get -ContentType $Script:Neo4JContentType
}

function Connect-Neo4JServer {
	param(
		[Parameter(Mandatory=$true)]
		$ComputerName,
		$Port = 7474,
		
		$Uri
	)
	if(!$Uri) {
		$Uri = [Uri]"http://${ComputerName}:$Port/db/data/"
	}
	$Script:DefaultServer = [PSCustomObject]@{
		ServerUri = $Uri;
		Endpoints = (DiscoverEndpoints -Uri $Uri);
	}
	$Script:DefaultServer
}

function Find-Node {
	param(
		[Parameter(Mandatory=$false)]
		$Server = $Script:DefaultServer,
		
		[String]$Label
	)
	$LabelNodesEndpoint = "$($Server.ServerUri.ToString())label/$Label/nodes"
	
	$Response = Invoke-WebRequest -Method Get -ContentType $Script:Neo4JContentType -Uri $LabelNodesEndpoint
	ConvertFrom-Json -InputObject $Response.Content | %{$_}
}

function Get-Label {
	param(
		[Parameter(Mandatory=$false)]
		$Server = $Script:DefaultServer,
		
		[String]$Label
	)
	$LabelEndpoint = $Server.Endpoints.Node_Labels
	$Response = Invoke-WebRequest -Method Get -ContentType $Script:Neo4JContentType -Uri $LabelEndpoint
	ConvertFrom-Json -InputObject $Response.Content | ?{
		if($Label) {
			$_ -eq $Label
		} else {
			$true
		}
	}
}

function New-Node {
	param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		$InputObject,
		
		[Parameter(Mandatory=$false)]
		[string[]]$Label,
		
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		$Server = $Script:DefaultServer
	)
	process {
		$NodeEndpoint = $Server.Endpoints.Node
		#$InputJson = SerializeJson -InputObject $InputObject
		$InputJson = ConvertTo-Json -InputObject $InputObject -Compress -Depth 3
		Write-Debug "Sending: $InputJson"
		$Response = Invoke-WebRequest -Method Post -Body $InputJson -ContentType $Script:Neo4JContentType -Uri $NodeEndpoint
		$NewNode = ConvertFrom-Json -InputObject $Response.Content
		if($Label) {
			Set-NodeLabel -Node $NewNode -Label $Label
		}
		$NewNode
	}
}

function Set-NodeLabel {
	param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		$Node,
	
		[ValidateNotNullOrEmpty()]
		[string[]]$Label,
		
		[switch]$Replace
	)
	$LabelJson = ConvertTo-Json -InputObject $Label -Compress
	if($Replace) {
		$Method = "Put"
	} else {
		$Method = "Post"
	}
	$Response = Invoke-WebRequest -Method $Method -Body $LabelJson -ContentType $Script:Neo4JContentType -Uri $Node.Labels
}

function Set-NodeProperty {
	param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		$Node,
		
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$Name,
		
		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		$Value
	)
	process {
		$NodePropertyEndpoint = $Node.Property -replace "{key}",$Name
		$JsonValue = SerializeJson -InputObject $Value
		$Response = Invoke-RestMethod -Method Put -Body $JsonValue -ContentType $Script:Neo4JContentType -Uri $NodePropertyEndpoint
	}
}

function Remove-Node {
	param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		$Node
	)
	process {
		$Response = Invoke-RestMethod -Method Delete -ContentType $Script:Neo4JContentType -Uri $_.Self 
		$Response
	}
}

function SerializeJson {
	param(
		[Parameter(Mandatory=$true)]
		$InputObject
	)
	$Settings = New-Object Newtonsoft.Json.JsonSerializerSettings
	$Settings.NullValueHandling = "Ignore"
	[Newtonsoft.Json.JsonConvert]::SerializeObject($InputObject, $Settings)
}

function Connect-Node {
	param(
		[Parameter(Mandatory=$true)]
		$FromNode,
		
		[Parameter(Mandatory=$true)]
		$ToNode,
		
		[Parameter(Mandatory=$true)]
		[string]$Type,
		
		[System.Collections.Hashtable]$Properties = @{}
	)
	$RelEndpoint = $FromNode.Create_Relationship
	if($Properties.Count -gt 0) {
		$RelObject = [PSCustomObject]@{
			to = $ToNode.Self;
			type = $Type;
			data = $Properties;
		}
	} else {
		$RelObject = [PSCustomObject]@{
			to = $ToNode.Self;
			type = $Type;
		}	
	}
	$RelJson = ConvertTo-Json -InputObject $RelObject
	Write-Debug $RelJson
	$Response = Invoke-WebRequest -Method Post -Body $RelJson -ContentType $Script:Neo4JContentType -Uri $RelEndpoint
	ConvertFrom-Json $Response.Content
}

function New-CypherQuery {
	param(
		[string]$Query,
		[System.Collections.Hashtable]$Parameters
	)
	[PSCustomObject]@{
		query = $Query;
		params = $Parameters;
	} | ConvertTo-Json
}

function Invoke-CypherQuery {
	param(
		[string]$JsonQuery,
		
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		$Server = $Script:DefaultServer		
	)
	$CypherEndpoint = $Server.ServerUri + "db/data/"
		Write-Host "Shit"
		Write-Debug "Using endpoint $CypherEndpoint"
	$Response = Invoke-WebRequest -Method Post -Body $JsonQuery -ContentType $Script:Neo4JContentType -Uri $CypherEndpoint
	ConvertFrom-Json $Response.Content
}
#>