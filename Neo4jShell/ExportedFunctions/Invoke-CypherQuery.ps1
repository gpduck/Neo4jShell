function Invoke-CypherQuery {
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
    [Neo4j.Driver.V1.IDriver]$Server = $Global:DefaultNeo4jServer
  )
  $StmtParameters = Convert-HashtableToParameters $Parameters
  if($Query) {
    $Statement = New-Object Neo4j.Driver.V1.Statement($Query, $StmtParameters)
  }
  Dispose { $Session = $Server.Session() } {
    $Session.Run($Statement)
  }
}