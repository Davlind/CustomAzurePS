function Write-VerboseTS {
    param (
        [Parameter(Position=1, ValueFromPipeline=$true)]
        [string]$Message
    )

    Write-Verbose ("{0} - {1}" -f (Get-Date).ToLongTimeString(), $Message)
}

function Write-VerboseBegin {
    param (
        [Parameter(Position=1)]
        [string]$FunctionName
    )

    Write-VerboseTS ("Begin Operation {0}" -f $FunctionName)

    # $ParameterList = (Get-Command -Name $FunctionName).Parameters;

    # # Grab each parameter value, using Get-Variable
    # foreach ($Parameter in $ParameterList) {


    #     $x = Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue

    #     $Parameter.Values

    #     #Get-Variable -Name $ParameterList;
    # }
}

function Write-VerboseCompleted {
    param (
        [Parameter(Position=1)]
        [string]$FunctionName
    )

    Write-VerboseTS ("Completed Operation {0}" -f $FunctionName)
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