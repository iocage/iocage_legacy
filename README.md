iocage
======

**A FreeBSD jail manager.**

iocage is a zero dependency, drop in jail/container manager amalgamating some
of the best features and technologies the FreeBSD operating system has to offer.
It is geared for ease of use with a simple and easy to understand command syntax.

iocage is in the FreeBSD ports tree as sysutils/iocage.
To install using binary packages, simply run: `pkg install iocage`

- **[DOCUMENTATION](http://iocage.readthedocs.org/en/latest/index.html)**

**FEATURES:**
- Rapid thin provisioning (within seconds!)
- Templating
- Automatic package installation
- Ease of use (also supports shortened UUIDs and TAGs)
- Zero configuration files
- Virtual networking stacks (vnet)
- Shared IP based jails (non vnet)
- Fully writable clones
- Read only basejails
- Resource limits (CPU, MEMORY, etc.)
- Filesystem quotas and reservations
- ZFS jailing inside jails
- Transparent snapshot management
- Binary updates
- Differential jail packaging
- Export and import
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
-  iocage exec [-u username | -U username] [UUID|TAG] command [arg ...]
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
-  iocage upgrade [UUID|TAG] [release=RELEASE]
-  iocage record start|stop [UUID|TAG]
-  iocage package [UUID|TAG]
-  iocage export [UUID|TAG]
-  iocage import UUID [property=value]
-  iocage defaults
-  iocage version | --version
-  iocage help

**REQUIREMENTS**
- FreeBSD 9.3-RELEASE amd64 or newer
- ZFS file system
- Kernel compiled with:

        # This is optional and only needed if you need VNET and resource
        # limits

        options         VIMAGE # VNET/Vimage support
        options         RACCT  # Resource containers
        options         RCTL   # same as above

**OTHER CONSIDERATIONS**
- For resource limiting please read rctl(8)
- For the explanations on jail properties read jail(8)
- Create bridge0 and bridge1 interfaces 

**QUICK HOWTO**
- 1. Add bridge configuration to `/etc/rc.conf` on the host node
   `cloned_interfaces="bridge0 bridge1"`
- 2. Run `iocage fetch` - this will fetch the current release and prepare the
   base jail environment. Optionally release can be overridden by issuing 
   `iocage fetch release=9.2-RELEASE` if you intend to run other releases.
- 3. Execute `iocage create` - this will set up a jail from scratch. If needed
   The -c option will create a thin jail (ZFS clone) example: `iocage create -c`
   the `tag=any_name` can be used to tag a jail at creation.
- 4. Issue `iocage list`
- 5. Start the jail with `iocage start uuid`
- 6. Drop into jail with `iocage console uuid`

**OPTIONAL**
- Turn on resource caps with `iocage set rlimits=on uuid`
- Reload limits on-the-fly `iocage cap uuid`
- List resource usage `iocage inuse uuid`
- Release limits `iocage uncap uuid`

**HINTS**
- Use iocage set/get to modify properties
- To understand what most properties do read jail(8)
- Consider adding the following to `/etc/sysctl.conf` on the host:

        net.inet.ip.forwarding=1       # Enable IP forwarding between interfaces
        net.link.bridge.pfil_onlyip=0  # Only pass IP packets when pfil is enabled
        net.link.bridge.pfil_bridge=0  # Packet filter on the bridge interface
        net.link.bridge.pfil_member=0  # Packet filter on the member interface
