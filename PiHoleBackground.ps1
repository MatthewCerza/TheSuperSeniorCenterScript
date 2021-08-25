#THIS VERSION OF THE PROGRAM ASSUMES YOU ALREADY HAVE ADMIN RIGHTS.

Set-Variable -Name "Default_DNS_IP" -Value "10.128.128.128"
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
