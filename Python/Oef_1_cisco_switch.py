# cisco switch configuratie	layer 2 using netmiko

from colorama import Fore, Back, Style # make the colorama functions easier to call
import netmiko
import getpass




ports = "1-8,9-16,17-20.21-22,23"
for port in ports.split(","):
    print(port)
    if "-" in port:
        print(f"int range gi0/{port}")
    else:
        print(f"int gi0/{port}")
