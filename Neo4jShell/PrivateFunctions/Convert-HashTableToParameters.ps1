function Convert-HashtableToParameters {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
  param(
    [System.Collections.Hashtable]$Hashtable
  )
  $Parameters = New-Object "System.Collections.Generic.Dictionary[System.String,System.Object]"
  $Hashtable.Keys | ForEach-Object {
    $Parameters[$_] = $Hashtable[$_]
  }
  $Parameters
}