Real world example with VNET, NAT, PF, IPFW and port forwarding
===============================================================

This is a tested real world set up with VNET jails running IPFW and the host running both PF and IPFW. IPFW was set to allow all traffic to simplify this example.

After making the following changes make sure the host can restart cleanly.


**The host**

The host has the following relevant configuration needed to support VNET jails
(`these are relevant snippets only`):

``/etc/sysctl.conf``

      ::

        net.inet.ip.forwarding=1
        net.link.bridge.pfil_onlyip=0
        net.link.bridge.pfil_bridge=0
        net.link.bridge.pfil_member=0
        security.bsd.unprivileged_read_msgbuf=0
        # This is only for routing tables if any
        # (do not create default routing tables for all FIB's)
        net.add_addr_allfibs=0

``/etc/rc.conf``:

     ::

        cloned_interfaces="bridge0 bridge1"
        ifconfig_bridge0="addm em0 10.1.1.254/24 up"

        pf_enable="YES"
        pflog_enable="YES"
        firewall_enable="YES"
        firewall_type="open"
        iocage_enable="YES"

``/etc/pf.conf``:

     ::

        # MACROS --------------------------------
        if  = "{" em0 "}"
        int_if = "{" bridge epair vnet "}"

        # TABLES --------------------------------
        table <abusive_hosts> persist
        # don't filter on the loopback, VNET and bridge
        set skip on lo
        set skip on vnet
        set skip on bridge
        set skip on epair

        set loginterface em0

        # TRAFFIC NORMALIZATION ------------------
        scrub on $if all fragment reassemble

        # QUEUEING -------------------------------

        # TRANSLATION ----------------------------
        nat on em0 inet from ! em0 to any -> em0

        # port forward http to jail (varnish)
        rdr on $if inet proto tcp to port 80 -> 10.1.1.10 port 80

        # PACKET FILTERING -----------------------
        # setup a default deny policy
        block log all
        block in quick from <abusive_hosts>

        # pass all traffic to and from the local network.
        pass out quick on $if from any to any modulate state

        # allow SSH and http/https
        pass log on $if proto { tcp udp } from any to any port { ssh http 445 } keep state

        # allow ping
        pass in inet proto icmp all icmp-type echoreq


**For IPFW to work inside a jail set the securelevel property to "2":**

``iocage set securelevel=2 UUID | TAG``


**The jail**

``/etc/rc.conf``:

     ::

        hostname=UUID
        cron_flags="$cron_flags -J 15"
        
        # Configure vnet0
        ifconfig_vnet0="10.1.1.10/24"

        # Set default GW to point to bridge0 IP
        defaultrouter="10.1.1.254"

        # Disable Sendmail by default
        sendmail_enable="NONE"
        sendmail_submit_enable="NO"
        sendmail_outbound_enable="NO"
        sendmail_msp_queue_enable="NO"

        # Run secure syslog
        syslogd_flags="-c -ss"

        # Set IPFW to allow all
        firewall_enable="YES"
        firewall_type="open"

``/etc/resolv.conf``:

     ::

        nameserver 46.246.46.246
        nameserver 194.132.32.32

