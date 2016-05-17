function Format-CypherProfile {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")] #The whole point is write-host
  param(
    [Parameter(Mandatory=$true)]
    [Neo4j.Driver.V1.IProfiledPlan]$ProfiledPlan
  )
  Write-Host "Compiler $($ProfiledPlan.Arguments['version'])"
  Write-Host ""
  Write-Host "Planner $($ProfiledPlan.Arguments['planner'])"
  Write-Host ""
  Write-Host "Runtime $($ProfiledPlan.Arguments['runtime'])"
  Write-Host ""
  
  $Children = FormatChildren -Plan $ProfiledPlan -Depth 0 
  $TotalDbHits = ($Children | Measure-Object -Property DbHits -Sum).Sum
  $Children | Format-Table -Auto
  
  Write-Host ""
  Write-Host "Total database accesses: $TotalDbHits" 
}

function FormatChildren {
  param(
    [Neo4j.Driver.V1.IProfiledPlan]$Plan,
    $Depth
  )
  $Padding = "--" * $Depth
  $Plan.Children | ForEach-Object {
    New-Object PSObject -Property ([Ordered]@{
      Operator = "${Padding}$($_.OperatorType)"
      EstimatedRows = $_.Arguments["EstimatedRows"]
      Rows = $_.Arguments["Rows"]
      DbHits = $_.DbHits
      Variables = $_.Identifiers
      Other = $_.Arguments["LegacyExpression"]
    })

    if($_.Children.Length -gt 0) {
      FormatChildren -Plan $_ -Depth ($Depth + 1)
    } 
  }
}