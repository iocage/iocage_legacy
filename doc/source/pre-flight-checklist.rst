Pre-flight checklist
====================

#. If you need VNET make sure your kernel is ``VIMAGE/VNET`` enabled (check
    man page for details)

#. Enable IP forwarding with: ``sysctl net.inet.ip.forwarding=1``

#. Add the physical interface to ``bridge0`` and assign an IP address.

    Example:
    
    ``ifconfig bridge0 addm em0 192.168.1.254 up``

    In this case the IP ``192.168.1.254`` will become the default gateway for all
    jails attached to ``bridge0``

#. Configure either **routing** or **NAT** to handle jail traffic

#. Configure interfaces inside jail, example:

   ``ifconfig vnet0 192.168.1.10/24 up``

   ``route add default 192.168.1.254``

#. Test whether you can ping the default gateway and reach any external hosts

**Gotchas!**

* Important: for VNET to work, don't compile PF directly into the kernel - use
  it as a module (this is the default in GENERIC kernel)!

* Watch out for PF or IPFW! Traffic originating from jails needs to be allowed
  in/out!

* If IPFW is turned on don't forget to add ``firewall_enable="YES"``
  ``firewall_type="open"`` to ``/etc/rc.conf`` inside the jail to test connectivity

* In case both PF and IPFW is enabled make sure you execute ``pfctl -f
  /etc/pf.conf`` on the host after jail is started

* Also consider configuring the following to allow traffic to bypass firewall
  for the bridge:

        ``net.link.bridge.pfil_onlyip=0``

        ``net.link.bridge.pfil_bridge=0``

        ``net.link.bridge.pfil_member=0``

