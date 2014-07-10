Configuring Network Interfaces
==============================

iocage handles network configuration for both, shared IP and VNET jails
transparently.

**Configuring a shared IPv4 jail:**

``iocage set ip4_addr="em0|192.168.0.10/24" UUID``

This will add an IP alias 192.168.0.10/24 to interface em0 for the shared IP jail at start time.

**A better approach using VNET:**

``iocage set ip4_addr="vnet0|192.168.0.10/24" UUID``

``iocage set defaultrouter=192.168.0.254 UUID``

For VNET jails a default route has to be specified too, just like for a normal
host system.

**Hints**

To start a jail with no IPv4 address whatsoever set these properties:

``iocage set ip4_addr=none UUID``

``iocage set defaultrouter=none UUID``
