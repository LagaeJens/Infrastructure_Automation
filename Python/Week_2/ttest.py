import csv
import datetime


def generate_router_config(input_csv, output_txt):
    try:
        with open(input_csv, 'r') as csvfile, open(output_txt, 'w') as outputfile:
            csvreader = csv.DictReader(csvfile, delimiter=';')

            current_router = None  # Keep track of the current router name

            for row in csvreader:
                network = row['network']
                interface = row['interface']
                description = row['description']
                vlan = row['vlan']
                ip_address = row['ipaddress']
                subnet_mask = row['subnetmask']
                default_gateway = row['defaultgateway']

                # Check if the router has changed, and if so, create a new router section
                if network != current_router:
                    if current_router is not None:
                        outputfile.write("\n")

                    outputfile.write(f"//ROUTER {network}\n")
                    outputfile.write("conf t\n")
                    current_router = network

                config = f"int {interface}\n"
                config += f"descr {description}\n"
                config += f"vlan {vlan}\n"
                config += f"ip address {ip_address} {subnet_mask}\n"
                config += f"no shut\n"

                if default_gateway:
                    config += f"ip default-gateway {default_gateway}\n"

                config += "\n"

                outputfile.write(config)

        print(f"Configuration file generated as '{output_txt}'")
    except FileNotFoundError:
        print("The specified CSV file could not be found.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    # Replace these with your actual file paths
    input_csv = "Infrastructure_Automation\Python\Week_2\Voorbeeld_4.csv"
    now = datetime.datetime.now()
    output_txt = f"Infrastructure_Automation/Python/Week_2/Configuratie_{now.strftime('%Y%m%d%H%M%S')}.txt"

    generate_router_config(input_csv, output_txt)
