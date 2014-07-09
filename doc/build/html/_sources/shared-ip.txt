Non VNET jails (shared IP)
==========================

**To start a jail with a shared IP based networking (non VNET) follow these
steps:**

**Assumptions:**

You either have a working NAT or shared IP set up which is part of your LAN.

**Turn VNET off**

``iocage set vnet=off UUID``

**Set the shared IP and pin it to the right interface:**

``iocage set ip4_addr="em0|10.1.1.10/24"``

**Start jail:**

``iocage start UUID``

**Drop into jail and try to install some package:**

``iocage console UUID``

``pkg install tmux``

**Notes:**

If your network is set up the right way pkg will fetch the package from an online repo.
For non VNET jails you don't need to specify a default gateway.

**Consider adding these entries to ``/etc/rc.conf`` for shared IP jails:**

     ::

        hostname=UUID
        cron_flags="$cron_flags -J 15"

        # Disable Sendmail by default
        sendmail_enable="NONE"
        sendmail_submit_enable="NO"
        sendmail_outbound_enable="NO"
        sendmail_msp_queue_enable="NO"

        # Run secure syslog
        syslogd_flags="-c -ss"

Comment out ``adjkerntz -a`` in ``/etc/crontab`` as well (time cannot be controlled from a jail).

Also make sure SSH on the host is binding to a single IP only (snip below)!

``/etc/ssh/sshd_config``
     
     ::

        ListenAddress YOUR-HOST-IP

