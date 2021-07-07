function Show-Menu {
    param (
        [String]$Title = 'Active Directory Cleanup')
        (
        [String]$Info = "Highly recommend Enabling AD Recycle Bin")
    Clear-Host
    Write-Host "========== $Title =========="
    Write-Host "========== $Info =========="
    Write-Host "1: Press "1" to Enable Active Directory Recycle Bin"
    Write-Host "2: Press "2" to Display ADComputers older than 360 Days"
    Write-Host "3: Press "3" to Delete ADComputers in a time frame you specify" 
    Write-Host "4: Press "4" to Display ADUsers older than 360 Days" 
    Write-Host "5: Press "5" to Delete ADUsers in a time frame you specify"
    Write-Host "Q: Press "Q" to quit"
}

function EnableRecycleBin {
    $Domain = Get-ADDomain | Select-Object DNSRoot
    Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $Domain.DNSRoot -Confirm:$False -Verbose   
}

function DisplayADComputers {

$DaysInactive = 360
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
#Get information on inactive computer accounts
Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName
}

function deleteADComputers {
$DaysInactive = Read-Host -Prompt "Enter the number of days you want to find inactive accounts"
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

$Computers = Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName

foreach ($item in $Computers) {
Remove-ADObject $item.DistinguishedName
Write-Output "$($item.DistinguishedName) - Deleted" }        
}

function DisplayAdUsers {
$DaysInactive = 360
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
Get-ADUser  -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName
}

function DeleteADUsers {
    $DaysInactive = Read-Host -Prompt "Enter the number of days you want to find inactive accounts"
    $InactiveDate = (Get-Date).Adddays(-($DaysInactive))
    
    $ADUsers = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName
    
    foreach ($item in $ADUsers) {
    Remove-ADObject $item.DistinguishedName
    Write-Output "$($item.DistinguishedName) - Deleted" }        
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
            DisplayADComputers
            }
        '3' {
            deleteADComputers
            }
        '4' {
            DisplayAdUsers
            }
        '5' {
            DeleteADUsers
            }
        'Q' {
                return      
            }
    }
    Pause
}
Until ($input -eq 'qQ')