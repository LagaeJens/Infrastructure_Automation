import csv
from netmiko import ConnectHandler
import getpass
import ipaddress

# Prompt for device type (e.g., 'cisco_ios' for Cisco routers)
device_type = input("Enter the device type (e.g., cisco_ios): ")

# Prompt for device-specific information
ip_address = input("Enter the router IP address: ")
username = input("Enter your username: ")
password = getpass.getpass(prompt="Enter your password: ")
enable_password = getpass.getpass(prompt="Enter your enable password: ")

# Define the device dictionary
device = {
    'device_type': device_type,
    'ip': ip_address,
    'username': username,
    'password': password,
    'secret': enable_password,
    'session_log': 'netmiko_session.log'
}

# Establish an SSH connection to the router
connection = ConnectHandler(**device)

# Read VLAN configuration data from the CSV file and store it as a list of dictionaries
vlan_data = []

with open('Infrastructure_Automation\Python\oef_1_cisco.csv', mode='r') as file:
    csv_reader = csv.DictReader(file, delimiter=';')
    for row in csv_reader:
        vlan_data.append(row)

# Function to calculate first and last IP addresses in a subnet


def calculate_ip_range(subnet, netmask):
    try:
        if subnet and netmask:
            network = ipaddress.IPv4Network(
                f"{subnet}/{netmask}", strict=False)
            return str(network.network_address), str(network.broadcast_address)
        else:
            return None, None
    except ipaddress.AddressValueError as e:
        print(f"Error: {e}")
        return None, None

# Function to handle port ranges (leave it as in your original script)


def configure_ports(ports):
    for port in ports.split(","):
        print(port)
        if "-" in port:
            print(f"int range gi0/{port}")
            config_commands.append(f"interface range GigabitEthernet0/{port}")
        else:
            print(f"int gi0/{port}")
            config_commands.append(f"interface GigabitEthernet0/{port}")


# Create a log file for saving the configuration output
log_file = open('configuration_log.txt', 'w')

# Iterate over the VLAN data and configure the router
for entry in vlan_data:
    vlan_id = entry["Vlan"]
    vlan_name = entry["Name"]
    subnet = entry["Subnet"]
    netmask = entry["Netmask"]
    ports = entry["ports"]

    # Calculate the first and last IP addresses in the subnet
    first_ip, last_ip = calculate_ip_range(subnet, netmask)

    # Create VLAN
    config_commands = [
        f'vlan {vlan_id}',
        f'name {vlan_name}',
    ]

    # Configure IP address and subnet (if provided)
    if subnet and netmask:
        config_commands.extend([
            'interface Vlan' + vlan_id,
            f'ip address {subnet} {netmask}',
        ])
        print(f"First IP: {first_ip}")
        print(f"Last IP: {last_ip}")

    # Configure ports
    if ports:
        configure_ports(ports)

    # Send configuration commands to the router
    output = connection.send_config_set(config_commands)

    # Save the configuration output to the log file
    log_file.write(f"Configuration for VLAN {vlan_id}:\n")
    log_file.write(output)
    log_file.write("\n\n")
    print(f"Configuration for VLAN {vlan_id} applied successfully.")

# Close the log file
log_file.close()

# Save the configuration (optional)
connection.save_config()
print("Configuration saved.")

# Close the SSH connection
connection.disconnect()
