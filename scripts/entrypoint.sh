#!/bin/bash

echo "Starting SoftEther VPN Server..." \
    && vpnserver start \
    && sleep 5 \
    && echo "SoftEther VPN Server started successfully."

# Function to configure and start the VPN server
configure_server() {
    # Check if configuration file exists
    echo "Initiating the VPN server configuration..."

    # Configure the VPN server
    # vpncmd localhost /SERVER /CMD HubCreate "${HUB_NAME}" /PASSWORD:"${HUB_PASSWORD}" \
    vpncmd localhost /SERVER /CMD HubCreate "${HUB_NAME}" \
        && echo "Hub (${HUB_NAME}) created successfully."

    vpncmd localhost /SERVER /CMD HubList
    vpncmd localhost /SERVER /CMD BridgeCreate "${BRIDGE_NAME}" /DEVICE:"${DEVICE_NAME}" /TAP:YES \
        && echo "Bridge (${BRIDGE_NAME}) created successfully."

    vpncmd localhost /SERVER /CMD SecureNatEnable "${HUB_NAME}" \
        && echo "SecureNAT enabled successfully."

    vpncmd localhost /SERVER /CMD UserCreate "${USERNAME}" /GROUP:none /REALNAME:none /NOTE:none \
        && echo "User (${USERNAME}) created successfully."

    # vpncmd localhost /SERVER /CMD UserPasswordSet "${USERNAME}" /PASSWORD:"${USER_PASSWORD}" \
    vpncmd localhost /SERVER /CMD UserPasswordSet "${USERNAME}" \
        && echo "User password set successfully."

    vpncmd localhost /SERVER /CMD ServerPasswordSet "${SERVER_PASSWORD}" \
        && echo "Server password set successfully."
}

# Function to configure and start the VPN client
configure_client() {
    # Check if configuration file exists
    if [ ! -f /mnt/vpn_server.config ]; then
        # Configure the VPN client
        vpncmd localhost /CLIENT /CMD AccountCreate "${VPN_ACCOUNT_NAME}" /SERVER:"${VPN_SERVER_ADDRESS}" /HUB:"${HUB_NAME}" /USERNAME:"${USERNAME}" /NICNAME:"${NIC_NAME}"
        vpncmd localhost /CLIENT /CMD AccountPasswordSet "${VPN_ACCOUNT_NAME}" /PASSWORD:"${PASSWORD}" /TYPE:standard
        vpncmd localhost /CLIENT /CMD AccountConnect "${VPN_ACCOUNT_NAME}"
    fi
}

# Determine the instance type and configure accordingly
echo "Configuring VPN ${INSTANCE_TYPE}..."
if [ "${INSTANCE_TYPE}" == "server" ]; then
    configure_server
elif [ "${INSTANCE_TYPE}" == "client" ]; then
    configure_client
else
    echo "Invalid INSTANCE_TYPE specified. Please set INSTANCE_TYPE to 'server' or 'client'."
    exit 1
fi
echo "VPN ${INSTANCE_TYPE} configured successfully."

# Keep the container running
tail -f /dev/null