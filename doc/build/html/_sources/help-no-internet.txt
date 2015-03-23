Help! My jail has no Internet connectivity!
===========================================

**The steps below are for a VNET jail.**

There are two options to get Internet connectivity for jails:

* NAT
* Routed traffic

NAT is probably the easiest method for most cases.

Follow these steps to get Internet connectivity inside a jail with NAT (handled in PF):

1. Enable the following sysctl's:
     ::

        net.inet.ip.forwarding=1       # Enable IP forwarding between interfaces
        net.link.bridge.pfil_onlyip=0  # Only pass IP packets when pfil is enabled
        net.link.bridge.pfil_bridge=0  # Packet filter on the bridge interface
        net.link.bridge.pfil_member=0  # Packet filter on the member interface

2. Assign an IP to your bridge0 ``ifconfig 10.1.1.254/24 up`` (this will become the default GW for the jail)

3. Add your physical interface (example em0) to bridge0 ``ifconfig bridge0 addm em0 up``

4. Configure jail Interfaces ``ifconfig vnet0 10.1.1.10/24 up``

5. Add nameservers to ``/etc/resolv.conf``
     ::

        nameserver 194.132.32.32
        nameserver 46.246.46.246

6. Exit from chroot

7. Configure outbound NAT ("Real world example with VNET, NAT, PF, IPFW and
   port forwarding")

8. Start jail ``iocage start UUID | TAG``

9. Drop into jail ``iocage console UUID | TAG``

10. ping default gateway 10.1.1.254, you should have a reply!

11. ping Internet addresses, if all is good you should have Internet access
    now!

