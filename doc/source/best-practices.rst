Best practices
--------------

**Use PF as a module**

  This is the default in ``GENERIC`` kernel. There seem to be bug which is only
  triggered when PF is directly compiled into the kernel.

**Always tag your jails and templates!**

  This will help you avoid mistakes and easily identify jails.

**Set the notes property**

  Set the ``notes`` property to something meaningful, especially for templates and jails you might disable.

**Use VNET!**

  ``VNET`` will give you more control and isolation. Also allows to run per jail firewalls.

**Don't mix RELEASES!!!**

  As best practice only run jails with the same ``RELEASE`` as the host system.

**Don't overuse resource limiting!**

  Unless really needed, let the OS decide how to do it best. Set limits with the "log action" before enforcing "deny". This way you can check the logs before creating any performance issues.

**Try a template!**

  Templates will make your life easy!

**Use the `restart` command instead of `start` `stop`**

  The ``restart`` command performs a soft restart. It leaves the ``VNET`` stack alone, less stressful for the kernel.

**Check your firewall rules**

  When using ``IPFW`` inside a ``VNET`` jail put ``firewall_enable="YES"``
  ``firewall_type="open"`` into ``/etc/rc.conf`` for start. This way you can exclude the firewall from blocking you right from the beginning! Lock it down once you've tested everything. Also check PF firewall rules on the host if you happen to mix both.

**Get rid of old snapshots**

  Remove snapshots you don't need, especially from jails where data is changing a lot!

**Don't change the hostname**

  Unless really needed, don't change the jail's UUID based hostname in
  ``/etc/rc.conf``. Rather add required entries to ``/etc/hosts``.

**Use the `chroot` sub-command**
 
  In case you need access/modify files in a template or a jail which is in
  stopped state, use ``iocage chroot UUID``. This way you don't need to spin up the jail or convert the template. 

  
