$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$Command = $sut.Split(".")[0]

Describe $Command {
  . $here\$sut
  It "Returns IDictionary[String,Object]" {
    $Parameters = Convert-HashtableToParameters @{}
    $Parameters -is [System.Collections.Generic.IDictionary[System.String,System.Object]] | Should Be $True
  }
  
  It "Copies all the values" {
    $Parameters = Convert-HashtableToParameters @{
      One = 1
      Two = 2
    }
    $Parameters.Count | Should Be 2
    $Parameters.ContainsKey("One") | Should Be $true
    $Parameters.ContainsKey("Two") | Should Be $true
    $Parameters["One"] | Should Be 1
    $Parameters["Two"] | Should Be 2
  }
  
  It "Converts non-string keys" {
    $Parameters = Convert-HashtableToParameters @{
      1 = "One"
    }
    $Parameters.ContainsKey("1") | Should Be $true
    $Parameters["1"] | Should Be "One"
  }
}