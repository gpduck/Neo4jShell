function Dispose {
  param(
    [Parameter(Mandatory=$true)]
    [ScriptBlock]$InitScriptBlock,
    
    [Parameter(Mandatory=$true)]
    [ScriptBlock]$ExecuteScriptBlock
  )
  $InitStatements = $InitScriptBlock.Ast.EndBlock.Statements
  if($InitStatements.Count -ne 1 -or -not ($InitStatements[0] -is [System.Management.Automation.Language.AssignmentStatementAst])) {
    throw "Init block must contain a single assigment statement"
  }
  $Name = $InitStatements[0].Left.VariablePath.UserPath
  . $InitScriptBlock
  $Value = (Get-Variable -Name $Name).Value
  if(-not ($Value -is [System.IDisposable])) {
    throw "Value defined in init block must be IDisposable"
  }
  
  $Variable = New-Object System.Management.Automation.PSVariable($Name, $Value)
  $Variables = New-Object "System.Collections.Generic.List[PSVariable]"
  $Variables.Add($Variable)
  
  try {
    $ExecuteScriptBlock.InvokeWithContext(@{}, $Variables, @())
  } finally {
    if($Value) {
      $Value.Dispose()
    } else { 
      Write-Warning "Dispose variable $Name was $null after execution, object may not have been disposed properly"
    }
  }
}