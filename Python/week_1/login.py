from netmiko import ConnectHandler
import getpass

# Device information
device = {
    'device_type': 'cisco_ios',  # Change to your device type if needed
    'ip': '192.168.101.2',         # Change to your device's IP address
    'username': 'jens',  # Change to your SSH username
    'password': 'jens',  # Change to your SSH password
    'secret': 'jens',  # Change to your enable password
}

try:
    # Establish an SSH connection
    connection = ConnectHandler(**device)

    # Enter configuration mode
    connection.enable()

    print("Successfully entered configuration mode.")

    # Close the SSH connection
    connection.disconnect()

except Exception as e:
    print(f"An error occurred: {str(e)}")
