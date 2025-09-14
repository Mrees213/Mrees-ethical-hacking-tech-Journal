# Define your network prefix and DNS server directly in the script or pass them as variables
# $NetworkPrefix = "192.168.7"  # Replace with your desired network prefix
# $DnsServer = "192.168.4.4"    # Replace with your DNS server

param( 
    [string]$NetworkPrefix,   
    [string]$DnsServer  
)
if (-not $NetworkPrefix -or -not $DnsServer) {
    Write-Host "Usage: .\dns-resolver.ps1 -NetworkPrefix <NetworkPrefix> -DnsServer <DnsServer>"
    exit
}
# Loop through the IP range 1-254
for ($i = 1; $i -le 254; $i++) {
    $ip = "$NetworkPrefix.$i"  # Construct the IP address
    
    # Resolve DNS for each IP
    try {
        $result = Resolve-DnsName -DnsOnly $ip -Server $DnsServer -ErrorAction Ignore
        if ($result) {
            Write-Host "$ip resolved to $($result.NameHost)"
        }
        else {
         #  Write-Host "$ip could not be resolved"
        }
    }
    catch {
        Write-Host "Error resolving $ip"
    }
}


