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

Set-Variable -Name "Default_DNS_IP" -Value "192.168.0.1"
Set-Variable -Name "PiHole_DNS_IP" -Value "192.168.1.8"
Set-Variable -Name "current_DNS_IP" -Value (Get-DnsClientServerAddress -InterfaceAlias Wi-Fi -AddressFamily IPv4 | Select-Object –ExpandProperty ServerAddresses)

if ($current_DNS_IP -eq $PiHole_DNS_IP){ 
    Write-Output "Currently set to PiHole"
    Resolve-DnsName -Name www.apple.com -Server $PiHole_DNS_IP -Type A 
    if ($?){
        Write-Output "PiHole Is Up, System Functioning Correctly"
    }
    else{
        Write-Output "PiHole is Down"
        Resolve-DnsName -Name www.apple.com -Server $Default_DNS_IP -Type A
        if ($?){
            Write-Output "Default DNS Is Up"
            #SET TO DEFAULT DNS
            Set-DnsClientServerAddress -InterfaceAlias Wi-Fi -ResetServerAddresses
            Write-Output "Default DNS Restored (FAILSAFE MODE)"
        }
        else{
            Write-Output "Default DNS is Down (PROBLEM IS NOT ON OUR END)"
        }
    }
}
            
else{
    Write-Output "Not set to PiHole, Checking if PiHole is up."
    Resolve-DnsName -Name www.apple.com -Server $PiHole_DNS_IP -Type A 
    if ($?){
        Write-Output "PiHole Is Up"
        #SET TO PIHOLE
        Set-DnsClientServerAddress -InterfaceAlias Wi-Fi -ServerAddresses $PiHole_DNS_IP
        Write-Output "DNS Set to PiHole"
    }
    else{
        Resolve-DnsName -Name www.apple.com -Server $Default_DNS_IP -Type A
        if ($?){
        Write-Output "PiHole is Down. Default DNS is up. (FAILSAFE MODE)"
        
        }
        else{
        Write-Output "PiHole and Failsafe are down. Internet is likely down. Exiting without making changes..."
        }
    }
}
