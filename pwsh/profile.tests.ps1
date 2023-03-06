Describe 'ConvertFrom-Git' {
    It 'returns an empty hash object when directory is not a git repository' {
        $fromGit = "".Split("`n")
        $converted = $fromGit | ConvertFrom-Git 
        $converted.'branch.head' | Should -BeExactly $null
    }

    It 'returns branch name and branch ab is empty when directory is first initialized' {
        $fromGit = @'
# branch.oid (initial)
# branch.head master
'@.Split("`n") 
        $converted = $fromGit | ConvertFrom-Git 
        $converted.'branch.head'.trim() | Should -BeExactly "master"
        $converted.'branch.ab' | Should -BeExactly $null

    }

    It 'returns the status in branch.ab when there is a difference in origin/master' {
        $fromGit = @'
# branch.oid 6f81c3c46ad398217719cd61d9b37deeaf478025
# branch.head master
# branch.upstream origin/master
# branch.ab +0 -0
'@.Split("`n") 
        $converted = $fromGit | ConvertFrom-Git 
        $converted.'branch.head'.trim() | Should -BeExactly "master"
        $converted.'branch.ab'.trim() | Should -BeExactly "+0 -0"

    }

    It 'returns true when repository has modifications' {
        $fromGit = @'
# branch.oid 6f81c3c46ad398217719cd61d9b37deeaf478025
# branch.head master
# branch.upstream origin/master
# branch.ab +0 -0
1 .M N... 100644 
? untrackedfile
'@.Split("`n") 
        $converted = $fromGit | ConvertFrom-Git 
        $converted.'branch.head'.trim() | Should -BeExactly "master"
        $converted.'branch.ab'.trim() | Should -BeExactly "+0 -0"
        $converted.'changed' | Should -BeExactly $true

    }
}

Describe 'Format-GitObject' {
    It 'is an empty string when the git object is null' {
        $obj = [PSCustomObject]@{}
        Format-GitObject $obj | Should -BeNullOrEmpty
    }

    It 'is cyan color when the git object branch did not change' {
        $obj = [PSCustomObject]@{
            'branch.head' = "master"
            'branch.ab'   = "+0 -0"
        }
        $cyan, $red, $default = "`e[96m", "`e[91m", "`e[0m"
        $str = "(" + $obj.'branch.head' + $obj.'branch.ab' + ")"
        $expected = "${cyan}$str$default"
        Format-GitObject $obj | should -BeExactly $expected
    }

    It 'is red color when the git object branch changed' {
        $obj = [PSCustomObject]@{
            'branch.head' = "master"
            'branch.ab'   = "+0 -0"
            changed = $true
        }
        $cyan, $red, $default = "`e[96m", "`e[91m", "`e[0m"
        $str = "(" + $obj.'branch.head' + $obj.'branch.ab' + ")"
        $expected = "${red}$str$default"
        Format-GitObject $obj | should -BeExactly $expected
    }
}
Describe 'Split-Path2' {
    It 'returns same path when path length is less than or equal to 2' {
        $have = "C:\dir1"
        $want = $have
        Split-Path2 $have | Should -BeExactly $want
    }
    It 'returns last 2 elements when path length is greater than 2' {
        $have = "C:\dir1\dir2\dir3"
        $want = "..\dir2\dir3\"
        Split-Path2 $have | Should -BeExactly $want
    }
}


<#
Describe 'Test-InGitWorkTree' {
    BeforeEach {
        $tempDir = New-Item -ItemType Directory -Path $env:TEMP\tempDir
        $path = $tempDir.FullName
    }
    AfterEach {
        Remove-Item $path -Recurse -Force
    }
    It 'validates directory is in git work tree' {
        # setup
        git -C $path init > $null
        # test
        Test-InGitWorkTree $path | Should -BeTrue
    }

    It 'validates directory is not in git work tree' {
        # test
        Test-InGitWorkTree $path | Should -BeFalse
        # cleanup
    }

    It 'validates subdirectory is in git work tree' {
        # setup
        git -C $path init > $null
        $subDir = New-Item -ItemType Directory -Path $tempDir\subDir
        # test
        Test-InGitWorkTree $subDir | Should -BeTrue
    }
}
#>
