import csv
import datetime


def generate_cisco_config(input_csv, output_txt):
    try:
        with open(input_csv, 'r') as csvfile, open(output_txt, 'w') as outputfile:
            csvreader = csv.DictReader(csvfile, delimiter=';')

            access_list_name = "access-list 1"
            access_list_entries = []

            for row in csvreader:
                network = row['network']
                interface = row['interface']
                description = row['description']
                vlan = row['vlan']  # Read VLAN as a string
                ip_address = row['ipaddress']
                subnet_mask = row['subnetmask']
                default_gateway = row['defaultgateway']

                config = f"interface {interface}\n"
                config += f"description {description}\n"
                config += f"vlan {vlan}\n"
                config += f"ip address {ip_address} {subnet_mask}\n"
                if default_gateway:
                    config += f"ip default-gateway {default_gateway}\n"
                config += "no shutdown\n"

                config += "\n"
                outputfile.write(config)

                # Check if VLAN is not "WAN" to add an access list entry
                if vlan != "WAN":
                    access_list_entry = f"{access_list_name} permit {ip_address} {subnet_mask}"
                    access_list_entries.append(access_list_entry)

            # Write the access list entries to the output file
            for entry in access_list_entries:
                outputfile.write(entry + "\n")

        print(f"Configuration file generated as '{output_txt}'")
    except FileNotFoundError:
        print("The specified CSV file could not be found.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    # Replace these with your actual file paths
    input_csv = "D:\Howest\Infrastructure_Automation\Github_oefeningen\Infrastructure_Automation\Python\Week_2\Voorbeeld_1.csv"
    now = datetime.datetime.now()
    output_txt = f"Infrastructure_Automation/Python/Week_2/Configuratie_{now.strftime('%Y%m%d%H%M%S')}.txt"

    generate_cisco_config(input_csv, output_txt)
