#!/bin/bash

# Function to find IP by MAC address
find_ip_by_mac() {
  local target_mac="08:EA:40:F7:11:57"
  local interface="en0"
  local subnet=$(ipconfig getifaddr $interface)/24

  sudo nmap -sV $subnet | awk -v mac="$target_mac" '
    /Nmap scan report for/ {ip=$NF}
    /MAC Address: / && $3 == mac {print ip}
  '
}

# Function to update SSH config
update_ssh_config() {
  local ip_address=$1
  local ssh_config_file="$HOME/.ssh/config"
  local temp_file=$(mktemp)

  if [ -z "$ip_address" ]; then
    echo "No IP address found for the specified MAC address."
    exit 1
  fi

  # Update the HostName for the 'port' host
  awk -v ip="$ip_address" '
    $1 == "Host" && $2 == "port" {in_port_host=1}
    in_port_host && $1 == "HostName" {$2=ip; in_port_host=0}
    {print}
  ' "$ssh_config_file" > "$temp_file"

  # Backup the original SSH config file
  cp "$ssh_config_file" "$ssh_config_file.bak"

  # Replace the original SSH config file with the updated one
  mv "$temp_file" "$ssh_config_file"

  echo "Updated SSH config file with new IP address: $ip_address"
}

# Main script execution
main() {
  # Check if nmap is installed
  if ! command -v nmap &> /dev/null; then
    echo "nmap is not installed. Please install nmap and try again."
    exit 1
  fi

  # Find the IP address by MAC address and trim newlines and whitespace
  ip_address=$(find_ip_by_mac | tr -d '\n' | xargs)

  # Ensure only the IP address is captured
  ip_address=$(echo "$ip_address" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')

  # Update the SSH config with the found IP address
  update_ssh_config "$ip_address"
}

# Run the main function
main
