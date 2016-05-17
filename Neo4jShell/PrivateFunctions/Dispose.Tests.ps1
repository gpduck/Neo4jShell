[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssigments", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
param()

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$Command = $sut.Split(".")[0]

Describe $Command {
  . $here\$sut
  
  It "Throws when init has multiple statements" {
    { Dispose { $foo = "boo"; $boo = "foo"} {} } | Should Throw 
  }
  
  It "Throws when init is not an assignment statement" {
    { Dispose {"foo"} {} } | Should Throw
  }
  
  It "Throws when init is not IDisposable" {
    { Dispose { $Foo = "" } {} } | Should Throw
  }
  
  It "Calls dispose" {
    $Global:Disposed = New-Object System.Security.SecureString
    Dispose { $ss = $Global:Disposed } { }
    { $Disposed.Clear() } | Should Throw
  }
  
  It "Executes the script block" {
    $Global:Disposed = New-Object System.Security.SecureString
    Dispose { $ss = $Global:Disposed } { "Output" } | Should Be "Output"
  }
}