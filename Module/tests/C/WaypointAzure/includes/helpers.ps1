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

function Invoke-Prompt {
    param (
        [string]$Title,
        [string]$Message,
        [string]$FirstChoice,
        [string]$FirstChoiceHelp,
        [string]$SecondChoice,
        [string]$SecondChoiceHelp
    )
    $choice0 = New-Object System.Management.Automation.Host.ChoiceDescription $FirstChoice, $FirstChoiceHelp
    $choice1 = New-Object System.Management.Automation.Host.ChoiceDescription $SecondChoice, $SecondChoiceHelp

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($choice0, $choice1)

    $result = $host.ui.PromptForChoice($Title, $Message, $options, 0)

    return $result
}