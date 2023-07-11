function Show-Menu {
    param (
        [String]$Title = 'Active Directory Cleanup',
        [String]$Info = "Highly recommend Enabling AD Recycle Bin"
    )
    Clear-Host
    Write-Host "========== $Title =========="
    Write-Host "========== $Info =========="
    Write-Host '1: Press "1" to Enable Active Directory Recycle Bin'
    Write-Host '2: Press "2" to Display ADComputers older than 360 Days'
    Write-Host '3: Press "3" to Delete ADComputers in a time frame you specify'
    Write-Host '4: Press "4" to Display ADUsers older than 360 Days'
    Write-Host '5: Press "5" to Delete ADUsers in a time frame you specify'
    Write-Host 'Q: Press "Q" to quit'
}

function EnableRecycleBin {
    $Domain = Get-ADDomain | Select-Object DNSRoot
    Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $Domain.DNSRoot -Confirm:$False -Verbose   
}

function Get-InactiveEntities {
    param (
        [int]$DaysInactive,
        [String]$EntityType
    )
    $InactiveDate = (Get-Date).Adddays(-$DaysInactive)
    if ($EntityType -eq 'ADComputer') {
        Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName
    } elseif ($EntityType -eq 'ADUser') {
        Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName
    }
}

function Delete-Entities {
    param (
        [int]$DaysInactive,
        [String]$EntityType
    )
    $Entities = Get-InactiveEntities -DaysInactive $DaysInactive -EntityType $EntityType
    foreach ($item in $Entities) {
        Remove-ADObject $item.DistinguishedName
        Write-Output "$($item.DistinguishedName) - Deleted"
    }        
}

do 
{
    Show-Menu -Title 'Active Directory Cleanup'
    $input = Read-Host "What do you want to do?"
    switch ($input) 
    {
        '1'{
            EnableRecycleBin
        }
        '2' {  
            Get-InactiveEntities -DaysInactive 360 -EntityType 'ADComputer'
        }
        '3' {
            $DaysInactive = Read-Host -Prompt "Enter the number of days you want to find inactive accounts"
            Delete-Entities -DaysInactive $DaysInactive -EntityType 'ADComputer'
        }
        '4' {
            Get-InactiveEntities -DaysInactive 360 -EntityType 'ADUser'
        }
        '5' {
            $DaysInactive = Read-Host -Prompt "Enter the number of days you want to find inactive accounts"
            Delete-Entities -DaysInactive $DaysInactive -EntityType 'ADUser'
        }
        'Q' {
            return      
        }
        default {
            Write-Host "Invalid option. Please select a valid option."
        }
    }
    Pause
}
Until ($input -eq 'Q')
