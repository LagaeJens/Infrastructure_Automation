#!/bin/bash

# Set the network interface name
interface_name=ens33

# Set the static IP address
static_ip=192.168.204.5
subnet_mask=255.255.255.0
default_gateway=192.168.204.1

# Check if the network interface is configured with DHCP
if grep -q "iface $interface_name inet dhcp" /etc/network/interfaces; then
    dhcp_configured="true"
else
    dhcp_configured="false"
fi

# Check if the network interface is configured with a static IP address
if grep -q "iface $interface_name inet static" /etc/network/interfaces; then
    static_configured="true"
else
    static_configured="false"
fi

# Get the user's choice
echo "Do you want to switch to a static IP address or DHCP?"
echo "(1) Static IP address"
echo "(2) DHCP"
read choice

# Switch to a static IP address
if [ "$dhcp_configured" = "true" ] && [ "$choice" = "1" ]; then
    # Remove the DHCP configuration
    sed -i '\face $interface_name inet dhcp' /etc/network/interfaces

    # Add the static IP address configuration
    echo -e "\niface $interface_name inet static\naddress $static_ip\nnetmask $subnet_mask\ngateway $default_gateway" >>/etc/network/interfaces
fi

# Switch to DHCP
if [ "$static_configured" = "true" ] && [ "$choice" = "2" ]; then
    # Remove the static IP address configuration
    sed -i '/address/d' /etc/network/interfaces
    sed -i '/netmask/d' /etc/network/interfaces
    sed -i '/gateway/d' /etc/network/interfaces

    # Add the DHCP configuration
    echo -e "\niface $interface_name inet dhcp" >>/etc/network/interfaces
fi

# Restart the network service
sudo systemctl restart networking

# Display a message to the user
echo "The network interface has been switched to $choice."
