How to turn on auto boot
========================

**To enable auto starting of jails at boot time follow these steps:**

* Put the rc.d
  `iocage <https://github.com/pannon/iocage/blob/master/rc.d/iocage/>`_ script
  into your ``/usr/local/etc/rc.d/`` folder.

* Add ``iocage_enable="YES"`` to the hosts ``/etc/rc.conf``

* Set the boot property to on for jails you wish to auto-boot ``iocage set
  boot=on UUID``

* If you need to specify a boot order you can do it by setting the priority
  value ``iocage set priority=20 UUID | TAG`` . Lower value means higher boot
  priority.
