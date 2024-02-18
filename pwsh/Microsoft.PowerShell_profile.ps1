#region commands
# prevent color problem in VSCode
[console]::ResetColor()
# Remove-Module PSReadline

Set-PSReadLineOption -PredictionSource History 
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -ViModeIndicator Cursor
#Set-PSReadLineoption -ShowToolTips # True by default
Set-PSReadLineoption -HistorySearchCursorMovesToEnd
#Set-PSReadLineOption -Colors @{ InlinePrediction = "`e[7m" } # Doesn't work on 32bit
Set-PSReadLineOption -PredictionViewStyle ListView

# parameter color
Set-PSReadlineOption -Color @{
    Command            = "Cyan"
    ContinuationPrompt = "$([char]0x1b)[37m"
    Default            = "$([char]0x1b)[37m"
    Member             = "DarkGreen"
    Number             = "$([char]0x1b)[37m"
    Operator           = "$([char]0x1b)[37m"
    Parameter          = "DarkCyan"
    String             = "DarkYellow"
    Variable           = "Green"
    InlinePrediction   = "#6e6942"
}
#Set-PSReadLineOption -Colors @{ "Parameter"="Cyan" }
#Set-PSReadLineOption -Colors @{ InlinePrediction = "$([char]0x1b)[7m" }

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+k -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+k -Function PreviousHistory
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+j -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+j -Function NextHistory
Set-PSReadLineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord
Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function ForwardWord
# Set-PSReadLineKeyHandler -Chord "Ctrl+b" -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Ctrl+Oem4 -Function ViCommandMode # Ctrl+[ (escape)
Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ViMode Insert
Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ViMode Command

$ErrorActionPreference = 'SilentlyContinue'

#endregion commands

#region aliases
# ALIASES
Set-Alias grep sls
Set-Alias touch New-Item
#Set-Alias gh Get-Help
Set-Alias ssh C:\WINDOWS\System32\OpenSSH\ssh
Set-Alias search Open-Search

#endregion aliases

#region env-variables
$Env:Path = 'C:\Users\VHAISFGARCIJ\programs\;C:\ProgramData\Microsoft\Windows\Start Menu\Programs\;' + $Env:Path
$Env:PathExt += ';.LNK'
#endregion env-variables

#region functions
#region PROMPT
# prompt prints the following string:
# "pwsh working-directory (git status) >>"
function prompt {
    # don't add failed commands to history
    $lastError = -not $?
    if ($lastError) { 
        Remove-LastHistory
    }
    $prompt2 = Get-Prompt2
    $prompt3 = Get-prompt3
    if (($prompt3.Length -gt 0)) {
        Write-Host "$(" ".PadRight($prompt2.Length - 10))$(Get-Prompt3)"
    }
    "$(Get-Prompt1 ">_" $lastError) $(Get-Prompt2) > "
}

# Remove-LastHistory removes the last item in the history
function Remove-LastHistory {
    Clear-History -Count 1 -Newest
}

function Get-Prompt1 {
    param (
        [string] $str,
        [bool] $lastExit
    )
    $red, $green = "`e[91m", "`e[92m"
    if ($lastExit) {
        return Format-Color $str $red
    }
    Format-Color $str $green    
}
function Format-Color {
    param (
        [string] $str,
        [string] $color = "`e[30m"
    )
    $default = "`e[0m"
    "$color$str$default"
}

function Get-Prompt2 {
    $gray = "`e[97m"
    $loc = Split-Path2 (Get-Location).ToString()
    Format-Color $loc $gray    
}

# Split-Path2 returns the current path starting from parent
# example: > $current = Split-Path2
#          > echo $current
#          > ..\repos\dotfiles\
function Split-Path2 {
    param (
        [Parameter()]
        [string] $path
    )
    $sep = [IO.Path]::DirectorySeparatorChar
    $loc = $path
    $locarr = $path.split($sep)
    if ($locarr.Length -gt 2) {
        $loc = $path.split($sep)[-2..-1] -join $sep
        $loc = ".." + $sep + $loc + $sep
    }
    return $loc
}

function Get-Prompt3 {
    Format-GitObject (Get-GitStatus | ConvertFrom-Git)
}

<#
 Get-GitStatus returns an array of strings
 from 'git status --branch porcelain=v2' text field data
 Ex: > $gitStat=Get-GitStatus
     > echo $gitStat
# branch.oid aa901f80a5b9964ea
# branch.head master
# branch.upstream origin/master
# branch.ab +0 -0
1 .M N... 100644 100644 100644 ...
? newFile
#>
function Get-GitStatus {
    Update-GitFetch
    $result = (git status --branch --porcelain=v2 2> $null)
    if (-not $result) { $result = "" }
    $result.Split("`n")
}
function Update-GitFetch {
    If ($dotGit = $(git rev-parse --git-dir 2> $null)) {
        $fetchDir = "${dotGit}/FETCH_HEAD"
        $lastFetch = (Get-Item $fetchDir | New-timeSpan).TotalSeconds
        if ($lastFetch -gt 300) {
            Start-Job { git fetch } > $null
        }
    }
}
<# 
  ConvertFrom-Git converts the output from Get-GitStatus
  to a PSCustomobject
  Ex: > Get-GitStatus | ConvertFrom-Git
#>
function ConvertFrom-Git {
    begin { $objhash = @{} }
    process { 
        $fields = $_.split(' ')
        if ($fields[0] -eq "#") {
            # branch lines
            $objhash[$fields[1]] = $fields[2] + " " + $fields[3]
        }
        # modified tracked and untracked files ?
        if ( ($fields[0] -eq "?") -or ($fields[0] -eq "1") ) { 
            $objhash["changed"] = $true
        }
    }
    end { [pscustomobject] $objhash }
}

function Format-GitObject {
    param (
        [PSCustomObject] $obj
    )
    $str = "" # not git repository
    $cyan, $red, $default = "`e[96m", "`e[91m", "`e[0m"
    if ($obj.'branch.head') {
        # git repository
        $str = "(" + $obj.'branch.head' + $obj.'branch.ab' + ")"
        if ( $obj.changed ) {
            $str = "${red}$str$default"
        }
        else {
            $str = "${cyan}$str$default"
        }
    }
    $str
}
#endregion PROMPT

# Open-Search opens browser tab to search
# for the $term
function Open-Search {
    Param(
        [parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string]$term
    )
    $url = "https:www.google.com/search?q=" + $term.Replace(" ", "+")
    Start-Process Chrome $url
}

# Test-Committed checks the local git repos
# to ensure repo is committed and up to date
function Test-Committed {
    $dirs = Get-ChildItem $HOME\repos -Directory
    foreach ($dir in $dirs) {
        Push-Location $dir.FullName
        #$dirty = (git status --porcelain=v2)
        $dirty = (git diff --name-only HEAD)
        if (-not $dirty) { Pop-Location; continue }
        $red, $green = 31, 32
        "`n$dir    `e[${red}mneeds update `e[${green}m"
        $dirty; "`e[0m"
        Pop-Location
    }
}

# Get-Todos gets list of TODO items
# from each of the local git repos
function Get-Todos ($parentDir = "$HOME\repos\" ) {
    $todos = (Get-ChildItem $parentDir -Recurse | Where-Object { $_.BaseName -eq "TODO" })
    foreach ($todo in $todos) {
        $dir = $todo.Directory.FullName
        $parentDir = $parentDir.FullName
        $length = $dir.Length - $parentDir.Length
        $dir = $dir.Substring($parentDir.Length, $length)
        $green = 32
        "`n`n$([char]0x1b)[${green}m${dir}$([char]0x1b)[0m"
        $content = Get-Content $todo.FullName #| Select-String "[x]" -NotMatch -SimpleMatch
        $content
        "`n"; pause
    }
}
# Get-Commits gets list of commits
# from each of the local git repos
function Get-Commits ($date = (Get-Date).AddDays(-7), $parentDir = "$HOME\repos\" ) {
    $dirs = Get-ChildItem $parentDir -Directory
    foreach ($dir in $dirs) {
        Write-Output "`n$dir"
        Push-Location $dir.FullName
        $date = Get-Date $date -UFormat %F
        git log --after=$date --oneline
        Pop-Location
        "`n"; pause
    }
}
# Get-IAMToken prompts for PIV card and 
# copies SSOi SAML token in clipboard
function Get-IAMToken {
    $pwsh32 = "C:\Windows\syswow64\Windowspowershell\v1.0\powershell.exe"
    & $pwsh32 ~\bin\xuiamssoix32.ps1
}
function Start-VPNClient {
    & "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe"
}
function Start-ReflectionElev {
    Start-Process 'C:\Program Files (x86)\Micro Focus\Reflection\Attachmate.Emulation.Frame.exe' -Verb runAs 
}
function Start-MyPrograms {
    Start-Process outlook
    Start-Process teams
    Start-Process chrome "https://vajira.max.gov/secure/RapidBoard.jspa?rapidView=8598&view=detail&selectedIssue=VP-488&quickFilter=33358"
}
function Stop-Others {
    Get-MyPrograms | Where-Object { $_.Name -notmatch "outlook" -and $_.Name -notmatch "teams" -and $_.Name -notmatch "chrome" } |
    Close-MainWindow
}
function Get-MyPrograms {
    # programs with MainWindowTitle except Windows Terminal and VPN client
    Get-Process | Where-Object { $_.MainWindowTitle -and $_.Name -notmatch "terminal" -and $_.Name -notmatch "vpnui" } 
}
# Stop-MyPrograms gracefully stops a program
# will not stop if unsaved files
function Stop-MyPrograms {
    $myprograms = Get-MyPrograms
    # stop gracefully those that respond to CloseMainWindow but not if unsaved files
    $notClosed = ($myprograms | Close-MainWindow)
    if ($notClosed) {
        Write-Host -ForegroundColor Red "Close unsaved work before trying again"
        $notClosed
    }
    # hard stop those with multiple instances that autosave 
    $myprograms | Get-OtherPrograms | Stop-Process
    Stop-WinPrograms
}

function Close-MainWindow {
    process {
        if ( -not $_.CloseMainWindow()) { $_ }
    }
}
function Get-OtherPrograms {
    process {
        if ( $_.Name -match "Teams" -or $_.Name -match "Code" ) { $_ } 
    }
}
function Stop-WinPrograms {
    # stop ComObject window apps like Explorer.exe
    $winObjects = (New-Object -ComObject Shell.Application).Windows()
    $winObjects | ForEach-Object { $_.quit() }
}
#endregion functions