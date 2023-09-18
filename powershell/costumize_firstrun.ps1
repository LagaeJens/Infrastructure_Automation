# Set the file path
$filePath = "E:/firstrun.sh"
$targetLine = "rm -f /boot/firstrun.sh"

# Define the content to be added
$contentToAdd = @"
#
# MCT - Computer Networks section
#
# DHCP fallback profile
profile static_eth0
static ip_address=192.168.168.168/24
# The primary network interface
interface eth0
arping 192.168.99.99
fallback static_eth0
#static ip_address=<IP address>/<prefix>
#static routers=<IP address default gateway>
#static domain_name_servers=<preferred DNS server> <alternate DNS server>

DHCPCDEO
"@

# Read the existing contents of the file
$fileContents = Get-Content -Path $filePath

# Find the index of the target line
$targetLineIndex = $fileContents.IndexOf($targetLine)

# Check if the target line was found
if ($targetLineIndex -ge 0) {
    # Insert the content before the target line
    $fileContents = $fileContents[0..($targetLineIndex - 1)] + $contentToAdd + $fileContents[$targetLineIndex..($fileContents.Length - 1)]

    # Write the updated content back to the file
    $fileContents | Set-Content -Path $filePath
}
else {
    Write-Host "Target line '$targetLine' not found in the file."
}
