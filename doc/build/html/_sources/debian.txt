Create a Debian squeeze jail (gnu kFreeBSD)
===========================================

**In this howto we will set up a Debian (gnu/kFreeBSD) jail. gnu/kFreeBSD is a
Debian userland tailored for FreeBSD kernel.**

Don't forget to replace UUID with your jail's full UUID!

**Create an empty jail with linux specifics:**

``iocage create -e tag=debian exec_start="/etc/init.d/rc 3"
exec_stop="/etc/init.d/rc 0"``

**Install debootstrap on the host:**

``pkg install debootstrap``

**Grab the mountpoint for our empty jail, append /root/ to it and run
debootstrap:**

``iocage get mountpoint UUID``

``debootstrap squeeze /iocage/jails/UUID/root/`` (you can replace squeeze with wheezy if that is what you need)

**Edit the jail's fstab and add these lines:**

``/iocage/jails/UUID/root/fstab``

     ::

        linsys   /iocage/jails/UUID/root/sys         linsysfs  rw          0 0
        linproc  /iocage/jails/UUID/root/proc        linprocfs rw          0 0
        tmpfs    /iocage/jails/UUID/root/lib/init/rw tmpfs     rw,mode=777 0 0

**Start the jail and attach to it:**

``iocage start UUID``

``iocage console UUID``
