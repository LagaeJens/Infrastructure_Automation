# Define the drive letter to eject
$driveLetterToEject = "F" # Replace with the drive letter you want to eject

# Function to safely eject a drive by drive letter
function Eject-Drive($driveLetter) {
    try {
        $query = "SELECT * FROM Win32_DiskDrive WHERE DeviceID='\\.\\$($driveLetter):'"
        $drive = Get-WmiObject -Query $query
        $driveEjectionResult = $drive | ForEach-Object { $_.Eject() }

        if ($driveEjectionResult -eq 0) {
            Write-Host "Drive $($driveLetter) safely ejected."
        }
        else {
            Write-Host "Failed to safely eject drive $($driveLetter). You may need to eject it manually."
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Host "An error occurred while trying to eject drive $($driveLetter): $($errorMessage)"
    }
}

# Call the Eject-Drive function to eject the specified drive
Eject-Drive -driveLetter $driveLetterToEject
