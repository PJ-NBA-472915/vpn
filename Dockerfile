FROM softethervpn/vpnserver:stable

# Copy the configuration files
RUN mkdir -p /usr/local/vpnserver
COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "sh", "/entrypoint.sh" ]
