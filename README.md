iocage
======

FreeBSD jail manager

iocage is a drop in jail manager amalgamating ZFS, RCTL, VNET, and jails.

usage:
-  iocage fetch [release=RELEASE]
-  iocage create [-c | property=value]
-  iocage clone UUID
-  iocage destroy UUID
-  iocage list [-t]
-  iocage start UUID
-  iocage stop UUID
-  iocage rcboot
-  iocage rcshutdown
-  iocage console UUID
-  iocage chroot UUID
-  iocage df
-  iocage get [property | all ] UUID
-  iocage set property=value UUID
-  iocage cap UUID
-  iocage uncap UUID
-  iocage inuse UUID
-  iocage snapshot UUID
-  iocage snaplist UUID
-  iocage snapremove snapshotname UUID
-  iocage defaults
-  iocage version | --version
-  iocage help

REQUIREMENTS
- FreeBSD 10.0-RELEASE amd64
- Kernel compiled with:
    options         VIMAGE # VNET/Vimage support
    options         RACCT  # Resource containers
    options         RCTL   # same as above

OTHER CONSIDERATIONS
- for resource limiting please read rctl(8)
- for the explanations on jail properties read jail(8)
- create bridge0 and bridge1 interfaces 

QUICK HOWTO
- 1. add bridge configuration to /etc/rc.conf on the host node
   cloned_interfaces="bridge0 bridge1"
- 2. run "iocage fetch" - this will fetch the current release and prepare the
   base jail environment. Optionally release can be overridden by issuing 
   "iocage fetch release=9.2-RELEASE" if you intend to run other releases.
- 3. execute "iocage create" - this will set up a jail from scratch. If needed
   The -c option will create a thin jail (ZFS clone) example: "iocage create -c"
   the tag=any_name can be used to tag a jail at creation.
- 4. issue "iocage list"
- 5. start the jail with "iocage start uuid"
- 6. drop into jail with "iocage console uuid"

OPTIONAL
- turn on resource caps with "iocage set rlimits=on uuid"
- reload limits on-the-fly "iocage cap uuid"
- list resource usage "iocage inuse uuid"
- release limits "iocage uncap uuid"

HINTS
- Use iocage set/get to modify properties
- To understand what most properties do read jail(8)
