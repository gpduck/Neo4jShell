function Connect-Neo4jServer {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")] #DefaultNeo4jServer
  param(
    [Parameter(Mandatory=$true)]
    [String]$ComputerName,
    
    [int]$Port = 7687,
    
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential,
    
    [Neo4j.Driver.V1.Config]$Config = ([Neo4j.Driver.V1.Config]::DefaultConfig),
    
    [Switch]$NotDefault
  )
  $Uri =  [Uri]"bolt://${ComputerName}:${Port}"
  if($Credential) {
    $AuthToken = [Neo4j.Driver.V1.AuthTokens]::Basic($Credential.Username, $Credential.GetNetworkCredential().Password)
  } else {
    $AuthToken = [Neo4j.Driver.V1.AuthTokens]::None
  }
  $Server = [Neo4j.Driver.V1.GraphDatabase]::Driver($Uri, $AuthToken, $Config)
  if(!$NotDefault) {
    $Global:DefaultNeo4jServer = $Server
  }
  $Server
}