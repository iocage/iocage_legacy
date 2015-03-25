Known Issues
============

This is a short list of known issues.

**88 character mount path limitation**

There is a know mountpoint path length issue on FreeBSD which is set to a historical 88 character
limit.

This issue does not affect iocage jails from functioning properly, but can present challenges
when diving into ZFS snapshots (cd into .zfs/snapshots, tar, etc.).

ZFS snapshot creation and rollback is not affected.

To workaround this issue iocage allows short paths to be set (starting with version 1.5.0).

Example:

Shut down jail:

``iocage stop b863254d-d19b-11e4-9e7e-90b8d01b7245``

Get the current mount path.

``iocage get mountpoint b863254d-d19b-11e4-9e7e-90b8d01b7245``

``/iocage/jails/b863254d-d19b-11e4-9e7e-90b8d01b7245``

Set short path:

``iocage set mountpoint=/iocage/jails/b863254d b863254d``

Verify mountpoint:

``iocage get mountpoint b863254d-d19b-11e4-9e7e-90b8d01b7245``

``/iocage/jails/b863254d``

**Property validation**

iocage does not validate properties right now. Please refer to man page to see what is supported
for each property. By default iocage pre-configures each property with a safe default.

**VNET/VIMAGE issues**

VNET/VIMAGE can cause unexpected system crashes when VNET enabled jails are destroyed - that is when the
jail process is killed, removed, stopped.

As a workaround iocage allows a warm restart without destroying the jail.
By default the restart sub-command will execute a warm restart.

Example:

``iocage restart UUID``

FreeBSD 10.1-RELEASE is stable enough to run with VNET and warm restarts.
There are production machines with iocage and VNET jails running well beyond 100 days of uptime
running both PF and IPFW.

