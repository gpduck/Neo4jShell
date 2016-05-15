$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$Command = $sut.Split(".")[0]

Describe $Command {
  . $here\$sut
  
  It "Allows null for InputObject" {
    ConvertTo-Neo4jType -InputObject $null | Should Be $null
  }
  
  It "Allows [String]::Empty for InputObject" {
    ConvertTo-Neo4jType -InputObject "" | Should Be ""
  }
  
  It "Converts UInt32 to Int64" {
    (ConvertTo-Neo4jType -InputObject ([UInt32]::MaxValue)) -is [Int64] | Should Be $true 
  }
  
  It "Converts DateTime to UTC round-trip format" {
    $DateTime = [DateTime]::New(2000, 1, 2, 3, 4, 5, [DateTimeKind]::UTC)
    ConvertTo-Neo4jType -InputObject $DateTime | Should Be "2000-01-02T03:04:05.0000000Z"
  }
}