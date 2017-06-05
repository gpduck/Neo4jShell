function Invoke-CypherQuery {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")] #DefaultNeo4jServer
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Scope="Function", Target="*")] #Session
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ParameterSetName="StringQuery")]
    [String]$Query,
    
    [Parameter(Mandatory=$true,ParameterSetName="StatementQuery")]
    [Neo4j.Driver.V1.Statement]$Statement,
    
    [Parameter(ParameterSetName="StringQuery")]
    [Parameter(ParameterSetName="StatementQuery")]
    [ValidateNotNull()]
    [HashTable]$Parameters = @{},
    
    [ValidateNotNull()]
    [Neo4j.Driver.V1.IDriver]$Server = $Global:DefaultNeo4jServer,
    
    [Switch]$RawResult
  )
  $StmtParameters = Convert-HashtableToParameters $Parameters
  if($Query) {
    $Statement = New-Object Neo4j.Driver.V1.Statement($Query, $StmtParameters)
  }
  Write-Debug "Executing $($Statement.ToString())"
  Dispose { $Session = $Server.Session() } {
    $Result = $Session.Run($Statement) 
    if($RawResult) {
      #Wrap result in an array so powershell does not enumerate it.
      $PSCmdlet.WriteObject($Result, $false)
    } else {
      $Result
    }
  }
}