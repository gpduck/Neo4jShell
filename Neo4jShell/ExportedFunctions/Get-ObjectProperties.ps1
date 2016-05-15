function Get-ObjectProperties {
  param(
    [Parameter(Mandatory=$true)]
    $InputObject
  )
  process {
    $Properties = New-Object "System.Collections.Generic.Dictionary[System.String,System.Object]"
    if($InputObject -is [System.Collections.IDictionary]) {
      $InputObject.Keys | ForEach-Object {
        $Name = $_
        $Properties[$Name] = ConvertTo-Neo4jType -InputObject $InputObject[$Name]
      }
    } else {
      $InputObject | Get-Member -MemberType Properties | ForEach-Object {
        $PropertyName = $_.Name
        $Value = $InputObject."$PropertyName"
        $Properties[$PropertyName] = ConvertTo-Neo4jType -InputObject $Value
      }
    }
    $Properties
  }
}