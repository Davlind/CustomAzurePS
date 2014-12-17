function Write-VerboseTS {
    param (
        [Parameter(Position=1)]
        [string]$Message
    )

    Write-Verbose ("{0} - {1}" -f (Get-Date).ToLongTimeString(), $Message)
}

function Write-VerboseBegin {
    param (
        [Parameter(Position=1)]
        [string]$FunctionName
    )

    Write-Verbose ("{0} - Begin Operation {1}" -f (Get-Date).ToLongTimeString(), $FunctionName)
}

function Write-VerboseCompleted {
    param (
        [Parameter(Position=1)]
        [string]$FunctionName
    )

    Write-Verbose ("{0} - Completed Operation {1}" -f (Get-Date).ToLongTimeString(), $FunctionName)
}