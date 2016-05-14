function New-Relationship {
  param(
    [Parameter(Mandatory=$true)]
    [Neo4j.Driver.V1.INode]$StartNode,
    
    [Parameter(Mandatory=$true)]
    [Neo4j.Driver.V1.INode]$EndNode,
    
    [String]$Type,
    
    $Server = $Global:DefaultNeo4JServer
  )
  $RelName = "r"
  if($Type) {
    $RelStmt = "${RelName}:$Type"
  } else {
    $RelStmt = "$RelName"
  }
  $Create = "MATCH (s) WHERE ID(s) = {StartId} MATCH (e) WHERE ID(e) = {EndId} CREATE (s)-[${RelStmt}]->(e) RETURN $RelName"
  Invoke-CypherQuery -Query $Create -Parameters @{
    StartId = $StartNode.Id
    EndId = $EndNode.Id
  }
}