function ConvertTo-Neo4jType {
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [AllowNull()]
    [AllowEmptyString()]
    $InputObject
  )
  process {
    if($InputObject -eq $null) {
      return $null
    }
    switch($InputObject.GetType()) {
      ([UInt32]) {
        [Int64]$InputObject
      }
      ([System.DateTime]) {
        $InputObject.ToUniversalTime().ToString("o")
      }
      default {
        $InputObject
      }
    }
  }
}