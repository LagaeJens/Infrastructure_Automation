# Set the file path
$filePath = "F:/firstrun.sh"
$targetLine = "rm -f /boot/firstrun.sh"
$checkString = "DHCPCDEO"

# Read the existing contents of the file
$fileContents = Get-Content -Path $filePath

# Check if the content block exists in the file
$blockExists = $fileContents -match [regex]::Escape($checkString)

if ($blockExists) {
    Write-Host "The content block already exists in the file."
}
else {
    # Define the content to be added with Linux-style line endings
    $contentToAdd = @"
cat >>/etc/dhcpcd.conf <<'DHCPCDEOF'
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
DHCPCDEOF
"@

    # Replace Windows-style line endings (CRLF) with Linux-style line endings (LF)
    $contentToAdd = $contentToAdd -replace "`r`n", "`n"

    # Find the index of the target line
    $targetLineIndex = $fileContents.IndexOf($targetLine)

    # Check if the target line was found
    if ($targetLineIndex -ge 0) {
        # Insert the content before the target line
        $fileContents = $fileContents[0..($targetLineIndex - 1)] + $contentToAdd + $fileContents[$targetLineIndex..($fileContents.Length - 1)]

        # Write the updated content back to the file with Linux-style line endings
        $fileContents -join "`n" | Set-Content -Path $filePath
        Write-Host "Content added to the file."
    }
    else {
        Write-Host "Target line '$targetLine' not found in the file."
    }
}
