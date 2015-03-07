iocage Pool Party
======

**FreeBSD jail manager**

iocage is a zero dependency drop in jail/container manager amalgamating some
of the best features and technologies the FreeBSD operating system has to offer.
It is geared for ease of use with a simple and easy to understand command syntax.

iocage is designed to wield the awesome power of iocage, but allow it to be installed on a
ZFS pool that has multiple types of virtualization platforms housing data in separte datasets. 

Basically, I am hacking at iocage as to allow it's use in the virtualization solution I use 
in all my FreeBSD virtualization servers. 

This iocage version might be out of date, so beware. 

In other words, everyone is invited to the zpool party! \o/
I'll see myself out...

For instance, my zpool named 'neuralnet' looks like this when zfs list:
(lololololol you get the idea)

        # zfs list
        NAME USED  AVAIL  REFER  MOUNTPOINT
        neuralnet	
        neuralnet/vbox
        neuralnet/ezjail
        neuralnet/iocage
        neuralnet/thewarden
        ZROOT                781M  93.2G   144K  none
        ZROOT/ROOT           777M  93.2G   144K  none
        ZROOT/ROOT/default   777M  93.2G   777M  /
        ZROOT/tmp            176K  93.2G   176K  /tmp
        ZROOT/usr            616K  93.2G   144K  /usr
        ZROOT/usr/home       184K  93.2G   184K  /usr/home
        ZROOT/usr/ports      144K  93.2G   144K  /usr/ports
        ZROOT/usr/src        144K  93.2G   144K  /usr/src
        ZROOT/var           1.20M  93.2G   608K  /var
        ZROOT/var/crash      148K  93.2G   148K  /var/crash
        ZROOT/var/log        178K  93.2G   178K  /var/log
        ZROOT/var/mail       144K  93.2G   144K  /var/mail
        ZROOT/var/tmp        152K  93.2G   152K  /var/tmp
 

**FEATURES:**
- rapid thin provisioning (within seconds!)
- templating
- automatic package installation
- ease of use (also supports shortened UUIDs and TAGs)
- zero configuration files
- virtual networking stacks (vnet)
- shared IP based jails (non vnet)
- fully writable clones
- resource limits (CPU, MEMORY, etc.)
- filesystem quotas and reservations
- ZFS jailing inside jails
- transparent snapshot management
- binary updates
- differential jail packaging
- export and import
- and many more!

**USAGE:**
-  iocage fetch [release=RELEASE | ftphost=ftp.hostname.org] 
-  iocage create [-c|-e] [release=RELEASE] [pkglist=file] [property=value]
-  iocage clone [UUID|TAG]@snapshot [property=value]
-  iocage destroy [UUID|TAG]
-  iocage list [-t]
-  iocage start [UUID|TAG]
-  iocage stop [UUID|TAG]
-  iocage restart [UUID|TAG]
-  iocage rcboot
-  iocage rcshutdown
-  iocage console [UUID|TAG]
-  iocage chroot [UUID|TAG]
-  iocage df
-  iocage get [property | all ] [UUID|TAG]
-  iocage set property=value [UUID|TAG]
-  iocage cap [UUID|TAG]
-  iocage limts [UUID|TAG]
-  iocage uncap [UUID|TAG]
-  iocage inuse [UUID|TAG]
-  iocage snapshot [UUID|TAG]@snapshotname
-  iocage snaplist [UUID|TAG]
-  iocage snapremove [UUID|TAG]@snapshotname
-  iocage rollback [UUID|TAG]@snapshotname
-  iocage promote [UUID|TAG]
-  iocage runtime [UUID|TAG]
-  iocage update [UUID|TAG]
-  iocage record start|stop [UUID|TAG]
-  iocage package [UUID|TAG]
-  iocage export [UUID|TAG]
-  iocage import UUID [property=value]
-  iocage defaults
-  iocage version | --version
-  iocage help

**REQUIREMENTS**
- FreeBSD 10.0-RELEASE amd64
- ZFS file system
- Kernel compiled with:

        # This is optional and only needed if you need VNET and resource
        # limits

        options         VIMAGE # VNET/Vimage support
        options         RACCT  # Resource containers
        options         RCTL   # same as above

**OTHER CONSIDERATIONS**
- for resource limiting please read rctl(8)
- for the explanations on jail properties read jail(8)
- create bridge0 and bridge1 interfaces 

**QUICK HOWTO**
- 1. add bridge configuration to `/etc/rc.conf` on the host node
   `cloned_interfaces="bridge0 bridge1"`
- 2. run `iocage fetch` - this will fetch the current release and prepare the
   base jail environment. Optionally release can be overridden by issuing 
   `iocage fetch release=9.2-RELEASE` if you intend to run other releases.
- 3. execute `iocage create` - this will set up a jail from scratch. If needed
   The -c option will create a thin jail (ZFS clone) example: `iocage create -c`
   the `tag=any_name` can be used to tag a jail at creation.
- 4. issue `iocage list`
- 5. start the jail with `iocage start uuid`
- 6. drop into jail with `iocage console uuid`

**OPTIONAL**
- turn on resource caps with `iocage set rlimits=on uuid`
- reload limits on-the-fly `iocage cap uuid`
- list resource usage `iocage inuse uuid`
- release limits `iocage uncap uuid`

**HINTS**
- Use iocage set/get to modify properties
- To understand what most properties do read jail(8)
- Consider adding the following to `/etc/sysctl.conf` on the host:

        net.inet.ip.forwarding=1       # Enable IP forwarding between interfaces
        net.link.bridge.pfil_onlyip=0  # Only pass IP packets when pfil is enabled
        net.link.bridge.pfil_bridge=0  # Packet filter on the bridge interface
        net.link.bridge.pfil_member=0  # Packet filter on the member interface
