import csv

vlan_data = []

# Read VLAN configuration data from the CSV file and store it as a list of dictionaries
with open('Infrastructure_Automation\Python\oef_1_cisco.csv', mode='r') as file:
    csv_reader = csv.DictReader(file, delimiter=';')
    for row in csv_reader:
        vlan_data.append(row)

# Print the VLAN data
for entry in vlan_data:
    print("VLAN ID:", entry["Vlan"])
    print("Name:", entry["Name"])
    print("Subnet:", entry["Subnet"])
    print("Netmask:", entry["Netmask"])
    print("Ports:", entry["ports"])
    print()

print(vlan_data)
