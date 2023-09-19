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

# Function to search for the file on a given drive
function SearchForFileOnDrive($driveLetter) {
    $filePath = Join-Path -Path $driveLetter -ChildPath $fileName

    if (Test-Path -Path $filePath -PathType Leaf) {
        Write-Host "File $fileName found on drive $driveLetter"
        # You can add additional actions here if needed
    }
}

# Loop through each drive letter and search for the file
foreach ($driveLetter in $driveLetters) {
    SearchForFileOnDrive -driveLetter $driveLetter
}

Write-Host "File search complete."
