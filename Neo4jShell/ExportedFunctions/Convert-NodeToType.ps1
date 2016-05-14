function Convert-NodeToType {
  param(
    $InputObject,
    
    $Type
  )
  process {
    switch($Type.GetType().Fullname) {
      "System.Management.Automation.ScriptBlock" {
        $DollarScore = New-Object System.Management.Automation.PSVariable("_", $InputObject)
        $Variables = New-Object System.Collections.Generic.List[System.Management.Automation.PSVariable]
        $Variables.Add($DollarScore)
        $Type = $Type.InvokeWithContext(@{}, $Variables, @())
      }
      "System.RuntimeType" {
        $Type = $Type.Fullname
      }
      default {
        $Type = $Type.ToString()
      }
    }
    
    New-Object -TypeName $Type -Property $InputObject.Properties
  }
}