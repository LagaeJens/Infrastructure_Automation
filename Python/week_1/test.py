import csv
from netmiko import ConnectHandler
import getpass
import ipaddress

# Prompt for device type (e.g., 'cisco_ios' for Cisco routers)
device_type = input("Enter the device type (e.g., cisco_ios): ")

# Prompt for device-specific information
ip_address = input("Enter the router IP address: ")
username = input("Enter your username: ")
password = getpass.getpass(prompt="Enter your SSH password: ")
enable_password = getpass.getpass(prompt="Enter your enable password: ")

# Define the device dictionary with enable password
device = {
    'device_type': device_type,
    'ip': ip_address,
    'username': username,
    'password': password,
    'secret': enable_password  # Enable password for privilege mode
}

try:
    # Establish an SSH connection
    connection = ConnectHandler(**device)

    # Enable privilege mode
    connection.enable()

    print("Successfully enabled privilege mode.")

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

    # Function to handle port ranges and individual ports
    def configure_ports(ports):
        config_commands = []  # Initialize the config_commands list
        for port in ports.split(","):
            if "-" in port:
                start_port, end_port = port.split("-")
                for p in range(int(start_port), int(end_port) + 1):
                    config_commands.append(f"interface GigabitEthernet0/{p}")
            else:
                config_commands.append(f"interface GigabitEthernet0/{port}")

        # Send configuration commands to the router
        output = connection.send_config_set(config_commands)

        # Return the configuration output
        return output

    # Create a log file for saving the configuration output
    log_file = open('configuration_log.txt', 'w')

    # Initialize a dictionary to store the intended configuration for each VLAN
    intended_configs = {}

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
            output = configure_ports(ports)
            log_file.write(f"Configuration for VLAN {vlan_id} Ports:\n")
            log_file.write(output)
            log_file.write("\n\n")

        # Send VLAN configuration commands to the router
        output = connection.send_config_set(config_commands)

        # Save the intended configuration for this VLAN
        intended_configs[vlan_id] = config_commands

        # Save the configuration output to the log file
        log_file.write(f"Configuration for VLAN {vlan_id}:\n")
        log_file.write(output)
        log_file.write("\n\n")
        print(f"Configuration for VLAN {vlan_id} applied successfully.")

    # Retrieve the running configuration from the device
    running_config = connection.send_command("show running-config")

    # Compare the intended configuration with the actual running configuration
    for vlan_id, intended_config in intended_configs.items():
        print(f"Checking configuration for VLAN {vlan_id}")
        if all(command in running_config for command in intended_config):
            print(f"Configuration for VLAN {vlan_id} is as intended.")
        else:
            print(
                f"Configuration for VLAN {vlan_id} has discrepancies. Overwriting...")

            # Overwrite the configuration for VLAN with discrepancies
            overwrite_output = connection.send_config_set(intended_config)

            # Save the overwrite output to the log file
            log_file.write(f"Overwriting configuration for VLAN {vlan_id}:\n")
            log_file.write(overwrite_output)
            log_file.write("\n\n")

    # Close the log file
    log_file.close()

    # Save the configuration (optional)
    connection.save_config()
    print("Configuration saved.")

    # Close the SSH connection
    connection.disconnect()

except KeyboardInterrupt:
    print("Script execution interrupted by the user.")
except Exception as e:
    print(f"An error occurred: {str(e)}")
