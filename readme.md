Grab Neo4J from http://neo4j.com/download/ (I've tested with the community edition v2.0.3).

#Connect to your server
Connect-Neo4JServer -ComputerName localhost

#Add nodes (note that no properties can be null)
get-process | select name,id | New-Node -Label Process

$ComputerNode = [PSCustomObject]@{Name = $Env:Computername} | New-Node -Label Computer

#Connect nodes
$ProcessNodes = Find-Node -Label Process

$ProcessNodes | %{ Connect-Node -FromNode $_ -ToNode $ComputerNode -Type "RunningOn" }

#Query for processes running on computer

$Query = New-CypherQuery -Query "MATCH (p:Process)-[rel:RunningOn]->(c:Computer) WHERE c.Name = '$Env:Computername' RETURN p"
Invoke-CypherQuery $Query | % data

#Delete everything in the database
$DeleteQuery = New-CypherQuery -Query "MATCH (n)-[r]-() delete n,r"
Invoke-CypherQuery $DeleteQuery
