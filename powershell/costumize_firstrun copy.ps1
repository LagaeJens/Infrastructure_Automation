# Define the file name to search for
$fileName = "firstrun.sh"

# Get drive letters of attachable media (removable drives)
$driveLetters = Get-WmiObject -Query "SELECT * FROM Win32_DiskDrive WHERE MediaType='Removable Media'" | ForEach-Object {
    Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($_.DeviceID)'} WHERE AssocClass=Win32_DiskDriveToDiskPartition" | ForEach-Object {
        Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($_.DeviceID)'} WHERE AssocClass=Win32_LogicalDiskToPartition" | ForEach-Object {
            $_.DeviceID
        }
    }
}

# Variable to track if any modifications were made
$modificationsMade = $false

# Function to modify the file on a given drive
function ModifyFileOnDrive($driveLetter) {
    $filePath = Join-Path -Path $driveLetter -ChildPath $fileName

    if (Test-Path -Path $filePath -PathType Leaf) {
        Write-Host "Modifying $fileName on drive $driveLetter"
        
        # Define the content to be added or modified
        $contentToAddOrModify = @"
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
        $contentToAddOrModify = $contentToAddOrModify -replace "`r`n", "`n"

        # Read the existing contents of the file
        $fileContents = Get-Content -Path $filePath

        # Check if the content "DHCPCDEOF" exists in the file
        $blockExists = $fileContents -match "DHCPCDEOF"

        if ($blockExists) {
            Write-Host "The content block already exists in the file on drive $driveLetter. Already satisfied."
        }
        else {
            # Find the index of the line "rm -f /boot/firstrun.sh"
            $targetLineIndex = $fileContents.IndexOf("rm -f /boot/firstrun.sh")

            if ($targetLineIndex -ge 0) {
                # Insert the content before the target line
                $fileContents = $fileContents[0..($targetLineIndex - 1)] + $contentToAddOrModify + $fileContents[$targetLineIndex..($fileContents.Length - 1)]
            }
            else {
                # If the target line is not found, append the content to the end of the file
                $fileContents += $contentToAddOrModify
            }

            # Write the updated content back to the file with Linux-style line endings
            $fileContents -join "`n" | Set-Content -Path $filePath
            Write-Host "File modified on drive $driveLetter."
            $global:modificationsMade = $true
        }
    }
}

# Loop through each drive letter and modify the file
foreach ($driveLetter in $driveLetters) {
    ModifyFileOnDrive -driveLetter $driveLetter
}

# Display "File modification complete" or "Already satisfied"
if ($modificationsMade) {
    Write-Host "File modification complete."
}
else {
    Write-Host "Already satisfied."
}
