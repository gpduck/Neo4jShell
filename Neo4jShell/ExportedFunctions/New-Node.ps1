function New-Node {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")] #DefaultNeo4jServer
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    $InputObject,
    [Object[]]$Label,
    $Server = $Global:DefaultNeo4JServer
  )
  process {
    $NodeName = "n"
    
    if($Label.Count -gt 0) {
      $Label = $Label | ForEach-Object {
        if($_ -is [System.Management.Automation.ScriptBlock]) {
          $DollarScore = New-Object System.Management.Automation.PSVariable("_", $InputObject)
          $Variables = New-Object System.Collections.Generic.List[System.Management.Automation.PSVariable]
          $Variables.Add($DollarScore)
          $_.InvokeWithContext(@{}, $Variables, @())
        } else {
          $_.ToString()
        }
      }
      
      $LabelPart = $Label -join ":"
      $NodeStmt = "${NodeName}:$LabelPart"
    } else {
      $NodeStmt = $NodeName
    }
    
    $ObjectProperties = Convert-HashtableToParameters @{}
    $InputObject | Get-Member -MemberType Properties | ForEach-Object {
      $PropertyName = $_.Name
      $Value = $InputObject."$PropertyName"
      $ObjectProperties[$PropertyName] = $Value
    }
    $Parameters = Convert-HashtableToParameters @{ props = $ObjectProperties }
    
    $Create = "CREATE ($NodeStmt) SET $NodeName = { props } RETURN n;"
    Write-Debug "Create Statement: $Create"
    $CreateStatement = New-Object Neo4j.Driver.V1.Statement($Create, $Parameters)
    Invoke-CypherQuery -Statement $CreateStatement -Server $Server
  }
}