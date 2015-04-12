Configuring Network Interfaces
==============================

iocage handles network configuration for both, shared IP and VNET jails
transparently.

**Configuring a shared IPv4 jail:**

``iocage set ip4_addr="em0|192.168.0.10/24" UUID | TAG``

``iocage set ip6_addr="em0|2001:123:456:242::5/64" UUID | TAG``

This will add an IP alias 192.168.0.10/24 to interface em0 for the shared IP jail at start time,
as well as 2001:123:456::5/64.

**A better approach using VNET:**

``iocage set ip4_addr="vnet0|192.168.0.10/24" UUID | TAG``

``iocage set defaultrouter=192.168.0.254 UUID | TAG``

``iocage set ip6_addr="vnet0|2001:123:456:242::5/64" UUID | TAG``

``iocage set defaultrouter6="2001:123:456:242::1" UUID | TAG``

For VNET jails a default route has to be specified too, just like for a normal
host system.

**Hints**

To start a jail with no IPv4/6 address whatsoever set these properties:

``iocage set ip4_addr=none ip6_addr=none UUID | TAG``

``iocage set defaultrouter=none defaultrouter6=none UUID | TAG``
