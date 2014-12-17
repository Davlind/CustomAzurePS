$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

Describe "Write-VerboseTS" {
    It "doesn't throw exception" {
        { Write-VerboseTS "Test" } | Should Not Throw
    }
}

Describe "Write-VerboseBegin" {
    It "doesn't throw exception" {
        { Write-VerboseBegin "Test" } | Should Not Throw
    }
}

Describe "Write-VerboseCompleted" {
    It "doesn't throw exception" {
        { Write-VerboseCompleted "Test" } | Should Not Throw
    }
}