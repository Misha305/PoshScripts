<# Created by Mike Rudyi
Domain Controller SRV record checker.  Use to verify existance of SRV records on all the dns servers in the $serverlist.  
Helpful to determin if expected mnemonics policies are applying when the domain controller has uppercase charcters in its name:
https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/dns-registers-duplicate-srv-records-for-dc 

To remove duplicate records, remove from ipam and then remove from the server via command:
Remove-DnsServerResourceRecord -RRType SRV -Name "_ldap._tcp.ForestDnsZones" -ZoneName "fake.com" -RecordData "0","100","389","yourdcname.fake.com." -computername "computerhostingdns"
#>

$entryname = "yourdcname"
$dnsZoneName = "fake.com"
$recordName = "_ldap._tcp.ForestDnsZones"
$recordtype = "SRV"
$serverlist =  "dc1","dc2","dc3"

foreach ($dnsserver in $serverlist) {
    $entryRecord = Resolve-DnsName $($recordName + "." + $dnsZoneName) -Type $recordtype -Server $dnsserver | Where-Object {$_.Name -Like "$entryname*"}
    if ($entryRecord.count -eq 2) {
        Write-Output "$entryname - Multiple entries exists on server $dnsserver"
    }
    elseif ($entryRecord.count -eq 1) {
        Write-Output "$entryname still exists on server $dnsserver"
    }
    else {
        Write-Output "$entryname has been successfully removed on server $dnsserver"
    }
}
