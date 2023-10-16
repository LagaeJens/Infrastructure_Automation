#!/bin/bash

# This script will change the network interface from static to dhcp and vice versa.
interface="ens33"
file_path="/etc/network/interfaces"
#! Change the following variables to your own liking when using a static ip address
address="192.168.10.10"
netmask="255.255.255.0"
gateway="192.168.10.1"
addpendstring="\taddress $address\n\tnetmask $netmask\n\tgateway $gateway\n"

if [ "$(id -u)" -ne 0 ]; then
    printf "The script needs to run as root. Try running sudo\n"
    exit 1
fi

printf "> Getting current network interface\n"
status=$(grep -E "iface $interface inet (dhcp|static)" $file_path | awk '{print $NF}')
printf "> Huidige netwerk interface is: $status\n"

# Warning the user that the script will change the network interface settings
printf "> This script will change the network interface from static to dhcp and vice versa.\n"
printf "> The current network interface is: $interface\n"
printf "> The current network interface status is: $status\n"
read -n 1 -p $"Press any key to continue... [ctrl + c to exit]"

if [ "$status" = "static" ]; then
    printf "> Making interface dhcp\n"
    # Replace the line so it knows it's dhcp
    sed -i "s/iface $interface inet static/iface $interface inet dhcp/g" $file_path
    # remove the lines that are static
    sed -i "/address/d" $file_path
    sed -i "/gateway/d" $file_path
    sed -i "/netmask/d" $file_path

elif [ "$status" = "dhcp" ]; then
    printf "> Making interface static\n"
    # Replace the line so it knows it's static
    sed -i "s/iface $interface inet dhcp/iface $interface inet static\n$addpendstring/g" $file_path

fi

# Restart the network interface
printf "> Restarting network interface\n"
printf "> It is possible that you will lose connection if u are in a remote session\n"
read -n 1 -p $"Press any key to continue... [ctrl + c to exit]"
systemctl restart networking.service
if [ $? -eq 0 ]; then
    printf "> Network interface restarted\n"
else
    printf "> Network interface failed to restart\n"
    exit 1
fi

printf "> Testing connection\n"
# Check if the interface is up
if [ "$(ip a | grep $interface | grep -c "UP")" -eq 1 ]; then
    printf "> The interface is up\n"
else
    printf "> The interface is down\n"
    exit 1
fi
# check if there is internet connection using ping
if [ "$(ping -c 1 '8.8.8.8') -eq 0" ]; then
    printf "> There is internet connection\n"
else
    printf "> There is no internet connection\n"
    exit 1
fi

# If the script reaches here, it means the status is neither "static" nor "dhcp."
printf "> Device interface is unknown\n"
exit 1
