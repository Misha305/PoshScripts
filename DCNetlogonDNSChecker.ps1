<#
    Created by Mike Rudyi 3/2/23
    Script to verify DNS entry registrations for a DC. Also Use to verify appropriate entries are removed when the dclocator mnemonics are applied.
    Helpful to determin if expected mnemonics policies are applying when the domain controller has uppercase charcters in its name which can create duplicate srv records:
    https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/dns-registers-duplicate-srv-records-for-dc 
    If checking the dclocator mnemonics, copy the C:\Windows\System32\config\netlogon.dns file to a temp location before applying the mnemonics settings.  After applying the settings,
    check the dns entries against the copied netlogon.dns file.

#>

$script:netlogondnsfile = ""
$dcName = "dcname.fakedomain.com"

function checkDcDnsEntries {
    if (!$script:netlogondnsfile) {
        $script:netlogondnsfile = Join-Path $env:SystemRoot "System32\config\netlogon.dns"
    }

    Get-Content -Path $script:netlogondnsfile| ForEach-Object {
        $netlogondnsentry = $_.split('')[0]
        $dnsrecord = Resolve-DnsName $netlogondnsentry -Type SRv | Where-Object {$_.name -Like $dcName}
        #$dnsrecord
        if ($dnsrecord) {Write-Output "$dcName still published in $netlogondnsentry, Entry times $($dnsrecord.count)"}
        #if ($dnsrecord) {Write-Output "$netlogondnsentry"}
        #Resolve-DnsName $netlogondnsentry -Type SRV        
        }
}

checkDcDnsEntries
