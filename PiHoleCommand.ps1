#Getting Administrative Rights (DNS can't be changed without these rights)
param([switch]$Elevated)
function Check-Admin {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Check-Admin) -eq $false)  {
if ($elevated)
{
# Couldn't set as Admin, quits the program
}
 
else {
 
Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
exit
}
#Sets the system policy to run unsigned commands 
Set-ExecutionPolicy RemoteSigned
#Start of Actual Command
Write-Host "Senior Coastsiders PiHole Command Center Started"
Get-NetAdapter
Set-Variable -Name "PiHole_DNS_IP" -Value "192.168.1.8"
function Show-Menu
{
     param (
           [string]$Header = 'PiHole Diagnostics Command Center'
     )
     cls
     Write-Host "
     ================+"$Header "+================
     "
    
     Write-Host "1: Press '1' to activate the PiHole (Change DNS to"$PiHole_DNS_IP")."
     Write-Host "2: Press '2' disable the PiHole (Reset to DHCP given DNS)."
     Write-Host "3: Press '3' to check if the PiHole is being used (check current DNS adresses)."
     Write-Host "3: Press '4' to check if the PiHole is up (Resolve the PiHole)."
     Write-Host "Q: Press 'Q' to quit.
     "
}
do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input) { '1' {
                 cls
                'You selected #1'
		#SETS TO PIHOLE
                 Write-Host "PiHole Activated"
                 Set-DnsClientServerAddress -InterfaceAlias Wi-Fi -ServerAddresses ("192.168.1.8")
           } '2' {
                cls
                'You selected #2'
        #FAILSAFE MODE
		 Write-Host "PiHole Disabled (DNS Reverted, Failsafe Mode)"
		 Set-DnsClientServerAddress -InterfaceAlias Wi-Fi -ResetServerAddresses
           } '3' {
                cls

                'You selected #3'
                Set-Variable -Name "current_DNS_IP" -Value (Get-DnsClientServerAddress -InterfaceAlias Wi-Fi -AddressFamily IPv4 | Select-Object –ExpandProperty ServerAddresses)
                Write-Output "Your current IPv4 DNS adress is..."
                ($current_DNS_IP)
                if ($current_DNS_IP -eq $PiHole_DNS_IP){
                    Write-Output "This computer is currently set to use the PiHole"
                }
                else{
                    Write-Output "PiHole not in use."
                }
           } '4' {
                cls

               'You selected #4'
               'Loading...'
                Resolve-DnsName -Name www.apple.com -Server $PiHole_DNS_IP -Type A 
                if ($?){
                    Write-Output "PiHole Is Up, System Functioning Correctly"
                }
                else{
                    Write-Output "PiHole is Down"
                }
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q' -OR '1' -OR '2')
#Waits until it recieves an input to quit