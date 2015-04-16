#-------------------------------------------------------------------------+
# Copyright (C) 2014 Peter Toth (pannon)
# All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted providing that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

__usage () {
    echo "usage:"
    echo "  iocage fetch [release=RELEASE | ftphost=ftp.hostname.org]"
    echo "  iocage create [-b|-c|-e] [release=RELEASE] [pkglist=file] [property=value]"
    echo "  iocage clone [UUID|TAG]@snapshot [property=value]"
    echo "  iocage destroy [UUID|TAG]"
    echo "  iocage list [-t]"
    echo "  iocage start [UUID|TAG]"
    echo "  iocage stop [UUID|TAG]"
    echo "  iocage restart [UUID|TAG]"
    echo "  iocage rcboot"
    echo "  iocage rcshutdown"
    echo "  iocage console [UUID|TAG]"
    echo "  iocage exec [-u username | -U username] [UUID|TAG] command [arg ...]"
    echo "  iocage chroot [UUID|TAG] [command]"
    echo "  iocage df"
    echo "  iocage show property"
    echo "  iocage get [property | all ] [UUID|TAG]"
    echo "  iocage set property=value [UUID|TAG]"
    echo "  iocage cap [UUID|TAG]"
    echo "  iocage limits [UUID|TAG]"
    echo "  iocage uncap [UUID|TAG]"
    echo "  iocage inuse [UUID|TAG]"
    echo "  iocage snapshot [UUID|TAG]@snapshotname"
    echo "  iocage snaplist [UUID|TAG]"
    echo "  iocage snapremove [UUID|TAG]@snapshotname"
    echo "  iocage rollback [UUID|TAG]@snapshotname"
    echo "  iocage promote [UUID|TAG]"
    echo "  iocage runtime [UUID|TAG]"
    echo "  iocage update [UUID|TAG]"
    echo "  iocage upgrade [UUID|TAG]"
    echo "  iocage record start|stop [UUID|TAG]"
    echo "  iocage package [UUID|TAG]"
    echo "  iocage export [UUID|TAG]"
    echo "  iocage import UUID [property=value]"
    echo "  iocage defaults"
    echo "  iocage version | --version"
    echo "  iocage help"
    echo " "
    echo "  Hint:  you can use shortened UUIDs!"
    echo " "
    echo "  e.g. for  adae47cb-01a8-11e4-aa78-3c970ea3222f"
    echo "       use  adae47cb or just adae"
}

__help () {
cat << 'EOT'
NAME
  iocage - jail manager amalgamating ZFS, VNET and resource limits
SYNOPSIS
  iocage fetch [release=RELEASE | ftphost=ftp.hostname.org]
  iocage create [-b|-c|-e] [release=RELEASE] [pkglist=file] [property=value]
  iocage clone UUID|TAG [UUID|TAG@snapshot] [property=value]
  iocage destroy UUID|TAG
  iocage list [-t|-r]
  iocage start UUID|TAG
  iocage stop UUID|TAG
  iocage restart UUID|TAG
  iocage rcboot
  iocage rcshutdown
  iocage console UUID|TAG
  iocage exec [-u username | -U username] UUID|TAG command [arg ...]
  iocage chroot UUID|TAG [command]
  iocage df
  iocage show property
  iocage get [property | all ] UUID|TAG
  iocage set property=value UUID|TAG
  iocage cap UUID|TAG
  iocage limits [UUID|TAG]
  iocage uncap UUID|TAG
  iocage inuse UUID|TAG
  iocage snapshot UUID|TAG [UUID|TAG@snapshotname]
  iocage snaplist UUID|TAG
  iocage snapremove UUID|TAG@snapshotname
  iocage rollback UUID|TAG@snapshotname
  iocage promote UUID|TAG
  iocage runtime UUID|TAG
  iocage update UUID|TAG
  iocage upgrade UUID|TAG [release=RELEASE]
  iocage record start|stop UUID|TAG
  iocage package UUID|TAG
  iocage export UUID|TAG
  iocage import UUID [property=value]
  iocage defaults
  iocage version | --version
  iocage help
DESCRIPTION
  iocage is a system administration tool for jails designed to simplify
  jail management tasks. It abstracts away the management of ZFS backed jails running VNET
  or shared IP networking with optional support for resource limits.

  Both, shared IP based jails and VNET enabled jails are supported.

  Each jail has a unique ID (UUID) automatically generated at creation time.
  Using the UUID as a jail identifier means that a jail can be replicated in a
  distributed environment with greater flexibility. This also eliminates
  potential naming clashes on large scale deployments and helps reduce
  operator error.

  Partial UUID calling is supported with every operation, e.g. for
  "adae47cb-01a8-11e4-aa78-3c970ea3222f" the use in the form of "adae47cb" or just "adae" works.
  In addition to partial UUID calling, jail TAG's can be used interchangeably.

  To ease jail identification a TAG field is included in list mode which can
  be set to any string (hostname, label, note, etc.). By default if unset the TAG field
  contains the creation date and time stamp.

  Properties are stored inside ZFS custom fields. This eliminates the need for
  any configuration files and jails can be easily moved with ZFS send and
  receive preserving all of their properties automatically.

  iocage relies on ZFS and at least one ZFS pool must be present on the host system.
  To enable all the features iocage supports,
  consider the following optional kernel options and system reqiurements:
    o   FreeBSD 10.0-RELEASE amd64 or higher
    o   bridge interfaces (bridge0,bridge1) add:

        cloned_interfaces="bridge0 bridge1" to /etc/rc.conf
    o  Kernel compiled with:

        options         VIMAGE
        options         RACCT
        options         RCTL

SUBCOMMANDS

  fetch [release=RELEASE | ftphost=ftp.hostname.org]

    Used for downloading and updating/patching releases.

    fetch must be executed as the first command on a pristine system. By
    default fetch will download the host node's RELEASE for deployment. If
    other releases are required, this can be changed by supplying the
    required release property or just selecting the appropriate RELEASE from
    the menu list.

    Example: iocage fetch release=9.2-RELEASE

    fetch is also used to update already downloaded releases. To update a local
    release already present in iocage (iocage list -r) run:

             iocage fetch release=10.1-RELEASE

    This example will apply latest patches to 10.1-RELEASE base.
    Newly created jails or basejails will automatically have the latest
    latest updates applied.

  create [-b|-c|-e] [release=RELEASE] [property=value] [property=value]

    By default create will deploy a new jail based on the host operating
    system's release. This can be changed by specifying the release option.
    If the -c switch is specified the jail will be cloned from the current
    hosts RELEASE (uname -r).
    Default is to create a fully independent jail set.
    The -e switch will create an empty jail which can be used for unsupported or
    custom jails.
    The -b flag will create a so called "basejail" with a common shared base.

    Example: iocage create tag=www01 pkglist=$HOME/my-pkgs.txt
             iocage create -b tag=mybasejail

  clone UUID|TAG [UUID|TAG@snapshot] [property=value]

    Clone jail identified by UUID (ZFS clone). All properties will be reset on
    the clone, defaults can be overridden by specifying properties on the fly.
    Custom point-in-time snapshots can be used as a source for cloning in the
    form of UUID@snapshot or TAG@snapshot.

    Examples:

    Clone the current state of the jail:
    iocage clone UUID tag=www02

    Clone a jail from a custom snapshot (snapshot taken previously):
    iocage clone UUID@snapshotname tag=www02

  destroy UUID|TAG

    Destroy given jail. This is irreversible, use with caution. If the jail is
    running destroy action will fail. Also a capital "Y" is required for confirmation.

  list [-t|-r]

    List all jails, if -t is specified list only templates, with -r list downloaded
    releases.
    Non iocage jail listed, only if jail in UP state.

  df

    List disk space related information. Available fields:

    CRT - compression ratio
    RES - reserved space
    QTA - disk quota
    USE - used space
    AVA - available space

  start UUID|TAG

    Start jail identified by UUID or TAG.

  stop UUID|TAG

    Stop jail identified by UUID or TAG.

  restart UUID|TAG

    Soft restart jail. Soft method will restart the jail without destroying
    the jail's networking and the jail process itself. All processes are gracefully
    restarted inside the jail. Useful for quick and graceful restarts.

  rcboot

    Start all jails with "boot" property set to "on". Intended for boot time
    execution. Jails will be started in an ordered fashion based on their
    "priority" property.

  rcshutdown

    Stop all jails with "boot" property set to "on". Intended for full host shutdown.
    Jails will be stopped in an ordered fashion based on their "priority"
    property.

  console UUID|TAG

    Console access, drop into jail.

  exec [-u username | -U username] UUID command [arg ...]

    Execute command inside the jail. This is simply an iocage UUID/tag wrapper
    for jexec(8).

  chroot UUID|TAG [command]

    Chroot into jail, without actually starting the jail itself. Useful for
    initial setup (set root password, configure networking). You can specify a
    command just like with the normal system chroot tool.

  show property

    Shows the given property for all jails and templates. Useful to compare
    settings/properties for all jails.

    To get the last successfull start time for all jails:

        iocage show last_started

  get property|all UUID|TAG

    Get named property or if "all" keyword is specified dump all properties known to
    iocage.

    To display whether resource limits are enforced for a jail:

    iocage get rlimits UUID|TAG

  set property=value UUID|TAG

    Set a property to value.

  cap UUID|TAG

    Reapply resource limits on jail while it is running.

  limits [UUID|TAG]

    Display active resource limits for a jail or all jails. With no UUID supplied
    display all limits active for all jail.

  uncap UUID|TAG

    Release all resource limits, disable limits on the fly.

  inuse UUID|TAG

    Display consumed resources for a jail.

  snapshot UUID|TAG [UUID|TAG@snapshotname]

    Create a ZFS snapshot for jail. If no snapshot name is specified defaults
    to auto snapshot name based on current date and time.

  snaplist UUID|TAG

    List all snapshots belonging to jail.

        NAME    - snapshot name
        CREATED - creation time
        RSIZE   - referenced size
        USED    - used space

  snapremove UUID|TAG@snapshotname

    Destroy specified jail snapshot.

  rollback UUID|TAG@snapshotname

    Rollback to an existing snapshot. Any intermediate snapshots will be
    destroyed. For more information on this functionality please read zfs(8).

  promote UUID|TAG

    Promote a cloned jail to a fully independent copy. For more details please
    read zfs(8).

  runtime UUID|TAG

    Show runtime configuration of a jail. Useful for debugging.

  update UUID|TAG

    Update jail to latest patch level. A back-out snapshot is created to allow
    safe update/rollback.

  upgrade UUID|TAG [release=RELEASE]

    By default this will upgrade jail RELEASE to match the host's RELEASE
    unless another RELEASE is specified with the "release" property.

    Please note: Upgrading basejails is done by setting the jail's "release"
    property to the required new RELEASE:

    iocage set release=10.1-RELEASE UUID|TAG

    For this the RELEASE must be locally available. The basejail
    will re-clone its filesystems from the new release either by issuing
    the upgrade command or at next jail start.

  record start|stop UUID|TAG

    The record function will record every changed file in a directory called
    /iocage/jails/UUID/recorded. This is achieved by using a unionfs overlay
    mount. Used for differential package creation.

  package UUID|TAG

    Package recorded jail session into /iocage/packages. Creates SHA256
    checksum and prunes empty directories, files and some residual files like
    utx.* and .history. Before packaging any jails, make sure no unwanted files
    contaminated or leaked into the recorded package.

  export UUID|TAG

    Export a complete jail. An archive file is created in /iocage/images with SHA256
    checksum. Jail must be in stopped state before exporting.

  import UUID [property=value]

    Import full jail images or differential packages. Images need to be
    present in /iocage/images and packages in /iocage/packages along with
    along with checksum files. You can use short UUIDs - do not specify the
    the full filename only the UUID.

  defaults

    Display all defaults set in iocage itself.

  version | --version

    List version number.

  help

    List quick help.
PROPERTIES
  For more information on properties please check the relevant man page which
  is noted under each property in the form of "Source: manpage". Source "local"
  marks iocage specific properties.

  pkglist=none | path-to-file

    A text file containing one package per line. These will be auto installed when
    a jail is created. Works only in combination with the create subcommand.

    Default: none
    Source: local

  vnet=on | off

    This controls whether to start the jail with VNET or a shared IP
    configuration. Default is to auto-guess from a sysctl. If you don't
    need a fully virtualized per jail network stack set it to off.

    Default: auto-guess
    Source: local

  ip4_addr="interface|ip-address/netmask"

    The IPv4 address for VNET and shared IP jails.

    Form is: interface|ip-address/netmask
    Multiple interfaces:
    "interface|ip-address/netmask,interface|ip-address/netmask"

    For shared IP jails if an interface is given before
    the IP address, an alias for the address will be added to that
    interface, as it is with the interface parameter.  If a netmask
    in either dotted-quad or CIDR form is given after IP address, it
    will be used when adding the IP alias.

    For VNET jails the interface will be configured with the IP addresses
    listed.

    Example: "vnet0|192.168.0.10/24,vnet1|10.1.1.10/24"
    This would configure interfaces vnet0 and vnet1 in a VNET jail. In this
    case no network configuration is necessary in the jail's rc.conf file.

    Default: none
    Source: jail(8)

  ip4_saddrsel=1 | 0

    Only takes effect when vnet=off.
    A boolean option to change the formerly mentioned behaviour and
    disable IPv4 source address selection for the prison in favour of
    the primary IPv4 address of the jail.  Source address selection
    is enabled by default for all jails and the ip4_nosaddrsel
    settting of a parent jail is not inherited for any child jails.

    Default: 1
    Source: jail(8)

  ip4=new | disable | inherit

    Only takes effect when vnet=off.
    Control the availability of IPv4 addresses.  Possible values are
    "inherit" to allow unrestricted access to all system addresses,
    "new" to restrict addresses via ip4.addr above, and "disable" to
    stop the jail from using IPv4 entirely.  Setting the ip4.addr
    parameter implies a value of "new".

    Default: new
    Source: jail(8)

  defaultrouter=none | ipaddress

    Setting this property to anything other than none will try to configure a
    default route inside a VNET jail.

  defaultrouter6=none | ip6address

    Setting this property to anything other than none will try to configure a
    default IPv6 route inside a VNET jail.

  ip6.addr, ip6.saddrsel, ip6
    A set of IPv6 options for the prison, the counterparts to
    ip4.addr, ip4.saddrsel and ip4 above.

  interfaces=vnet0:bridge0,vnet1:bridge1 | vnet0:bridge0

    By default there are two interfaces specified with their bridge
    association. Up to four interfaces are supported. Interface configurations
    are separated by commas. Format is interface:bridge, where left value is
    the virtual VNET interface name, right value is the bridge name where the
    virtual interface should be attached.

    Default: vnet0:bridge0,vnet1:bridge1
    Source: local

  host_hostname=UUID

    The hostname of the jail.

    Default: UUID
    Source: jail(8)

  exec_fib=0 | 1 ..

    The FIB (routing table) to set when running commands inside the jail.

    Default: 0
    Source: jail(8)

  devfs_ruleset=4 | 0 ..

    The number of the devfs ruleset that is enforced for mounting
    devfs in this jail.  A value of zero (default) means no ruleset
    is enforced.  Descendant jails inherit the parent jail's devfs
    ruleset enforcement.  Mounting devfs inside a jail is possible
    only if the allow_mount and allow_mount_devfs permissions are
    effective and enforce_statfs is set to a value lower than 2.
    Devfs rules and rulesets cannot be viewed or modified from inside
    a jail.

    NOTE: It is important that only appropriate device nodes in devfs
    be exposed to a jail; access to disk devices in the jail may permit
    processes in the jail to bypass the jail sandboxing by modifying
    files outside of the jail.  See devfs(8) for information on
    how to use devfs rules to limit access to entries in the per-jail
    devfs.  A simple devfs ruleset for jails is available as ruleset
    #4 in /etc/defaults/devfs.rules

    Default: 4
    Source: jail(8)

  mount_devfs=1 | 0

    Mount a devfs(5) filesystem on the chrooted /dev directory, and
    apply the ruleset in the devfs_ruleset parameter (or a default of
    ruleset 4: devfsrules_jail) to restrict the devices visible
    inside the jail.

    Default: 1
    Source: jail(8)

  exec_start="/bin/sh /etc/rc"

    Command(s) to run in the prison environment when a jail is created.
    A typical command to run is "sh /etc/rc".

    Default: /bin/sh /etc/rc
    Source: jail(8)

  exec_stop="/bin/sh /etc/rc.shutdown"

    Command(s) to run in the prison environment before a jail is
    removed, and after any exec_prestop commands have completed.
    A typical command to run is "sh /etc/rc.shutdown".

    Default: /bin/sh /etc/rc.shutdown
    Source: jail(8)

  exec_prestart="/usr/bin/true"

    Command(s) to run in the system environment before a jail is started.

    Default: /usr/bin/true
    Source: jail(8)

  exec_prestop="/usr/bin/true"

    Command(s) to run in the system environment before a jail is stopped.

    Default: /usr/bin/true
    Source: jail(8)

  exec_poststop="/usr/bin/true"

    Command(s) to run in the system environment after a jail is stopped.

    Default: /usr/bin/true
    Source: jail(8)

  exec_poststart="/usr/bin/true"

    Command(s) to run in the system environment after a jail is started,
    and after any exec_start commands have completed.

    Default: /usr/bin/true
    Source: jail(8)

  exec_clean=1 | 0

    Run commands in a clean environment.  The environment is discarded
    except for HOME, SHELL, TERM and USER.  HOME and SHELL are
    set to the target login's default values.  USER is set to the
    target login.  TERM is imported from the current environment.
    The environment variables from the login class capability database
    for the target login are also set.

    Default: 1
    Source: jail(8)

  exec_timeout=60 | 30 ..

    The maximum amount of time to wait for a command to complete.  If
    a command is still running after this many seconds have passed,
    the jail will be terminated.

    Default: 60
    Source: jail(8)

  stop_timeout=30 | 60 ..

    The maximum amount of time to wait for a jail's processes to
    exit after sending them a SIGTERM signal (which happens after the
    exec_stop commands have completed).  After this many seconds have
    passed, the jail will be removed, which will kill any remaining
    processes. If this is set to zero, no SIGTERM is sent and the
    prison is immediately removed.

    Default: 30
    Source: jail(8)

  exec_jail_user=root

    The user to run commands as, when running in the jail environment.

    Default: root
    Source:  jail(8)

  exec_system_jail_user=0 | 1

    This boolean option looks for the exec_jail_user in the system
    passwd(5) file, instead of in the jail's file.

    Default: 0
    Source: jail(8)

  exec_system_user=root

    The user to run commands as, when running in the system environment.
    The default is to run the commands as the current user.

    Default: root
    Source: jail(8)

  mount_fdescfs=1 | 0

    Mount a fdescfs(5) filesystem in the jail's /dev/fd directory.
    Note: This is not supported on FreeBSD 9.3.

    Default: 1
    Source: jail(8)

  mount_procfs=0 | 1

    Mount a procfs(5) filesystem in the jail's /dev/proc directory.

    Default: 0
    Source: local

  enforce_statfs=2 | 1 | 0

    This determines which information processes in a jail are able to
    get about mount points.  It affects the behaviour of the following
    syscalls: statfs(2), fstatfs(2), getfsstat(2) and fhstatfs(2)
    (as well as similar compatibility syscalls).  When set to 0, all
    mount points are available without any restrictions.  When set to 1,
    only mount points below the jail's chroot directory are visible
    In addition to that, the path to the jail's chroot directory
    is removed from the front of their pathnames.  When set to 2
    (default), above syscalls can operate only on a mount-point where
    the jail's chroot directory is located.

    Default: 2. jail(8)

  children_max=0 | ..

    The number of child jails allowed to be created by this jail (or
    by other jails under this jail). This limit is zero by default,
    indicating the jail is not allowed to create child jails.  See
    the Hierarchical Jails section for more information in jail(8).

    Default: 0
    Source: jail(8)

  login_flags="-f root"

    Supply these flags to login when logging in to jails with the console function.

    Default: -f root
    Source: login(1)

  jail_zfs=on | off

    Enables automatic ZFS jailing inside the jail. Assigned ZFS dataset will
    be fully controlled by the jail.
    NOTE: Setting this to "on" automatically enables allow_mount=1
    enforce_statfs=1 and allow_mount_zfs=1! These are dependent options
    required for ZFS management inside a jail.

    Default: off
    Source: local

  jail_zfs_dataset=iocage/jails/UUID/root/data | zfs_filesystem

    This is the dataset to be jailed and fully handed over to a jail. Takes
    the ZFS filesystem name without pool name.
    NOTE: only valid if jail_zfs=on. By default the mountpoint is set to none,
    to mount this dataset set its mountpoint inside the jail i.e. "zfs set
    mountpoint=/data full-dataset-name" and issue "mount -a".

    Default: iocage/jails/UUID/root/data
    Source: local

  securelevel=3 | 2 | 1 | 0 | -1

    The value of the jail's kern.securelevel sysctl.  A jail never
    has a lower securelevel than the default system, but by setting
    this parameter it may have a higher one.  If the system
    securelevel is changed, any jail securelevels will be at least as
    secure.

    Default: 2
    Source: jail(8)

  allow_set_hostname=1 | 0

    The jail's hostname may be changed via hostname(1) or sethostname(3).

    Default: 1
    Source: jail(8)

  allow_sysvipc=0 | 1

    A process within the jail has access to System V IPC
    primitives.  In the current jail implementation, System V
    primitives share a single namespace across the host and
    jail environments, meaning that processes within a jail
    would be able to communicate with (and potentially interfere
    with) processes outside of the jail, and in other jails.

    Default: 0
    Source: jail(8)

  allow_raw_sockets=0 | 1

    The prison root is allowed to create raw sockets.  Setting
    this parameter allows utilities like ping(8) and
    traceroute(8) to operate inside the prison.  If this is
    set, the source IP addresses are enforced to comply with
    the IP address bound to the jail, regardless of whether
    or not the IP_HDRINCL flag has been set on the socket.
    Since raw sockets can be used to configure and interact
    with various network subsystems, extra caution should be
    used where privileged access to jails is given out to
    untrusted parties.

    Default: 0
    Source: jail(8)

  allow_chflags=0 | 1

    Normally, privileged users inside a jail are treated as
    unprivileged by chflags(2).  When this parameter is set,
    such users are treated as privileged, and may manipulate
    system file flags subject to the usual constraints on
    kern.securelevel.

    Default: 0
    Source: jail(8)

  allow_mount=0 | 1

    privileged users inside the jail will be able to mount
    and unmount file system types marked as jail-friendly.
    The lsvfs(1) command can be used to find file system
    types available for mount from within a jail.  This permission
    is effective only if enforce_statfs is set to a
    value lower than 2.

    Default: 0
    Source: jail(8)

  allow_mount_devfs=0 | 1

    privileged users inside the jail will be able to mount
    and unmount the devfs file system.  This permission is
    effective only together with allow.mount and if
    enforce_statfs is set to a value lower than 2.  Please
    consider restricting the devfs ruleset with the
    devfs_ruleset option.

    Default: 0
    Source: jail(8)

  allow_mount_nullfs=0 | 1

    privileged users inside the jail will be able to mount
    and unmount the nullfs file system. This permission is
    effective only together with allow_mount and if
    enforce_statfs is set to a value lower than 2.

    Default: 0
    Source: jail(8)

  allow_mount_procfs=0 | 1

    privileged users inside the jail will be able to mount
    and unmount the procfs file system.  This permission is
    effective only together with allow.mount and if
    enforce_statfs is set to a value lower than 2.

    Default: 0
    Source: jail(8)

  allow_mount_tmpfs=0 | 1

    privileged users inside the jail will be able to mount
    and unmount the tmpfs file system.  This permission is
    effective only together with allow.mount and if
    enforce_statfs is set to a value lower than 2.
    Note: This is not support on FreeBSD 9.3.

    Default: 0
    Source: jail(8)

  allow_mount_zfs=0 | 1

    privileged users inside the jail will be able to mount
    and unmount the ZFS file system.  This permission is
    effective only together with allow.mount and if
    enforce_statfs is set to a value lower than 2.  See
    zfs(8) for information on how to configure the ZFS
    filesystem to operate from within a jail.

    Default: 0
    Source: jail(8)

  allow_quotas=0 | 1

    The jail root may administer quotas on the jail's
    filesystem(s). This includes filesystems that the jail
    may share with other jails or with non-jailed parts of
    the system.

    Default: 0
    Source: jail(8)

  allow_socket_af=0 | 1

    Sockets within a jail are normally restricted to IPv4,
    IPv6, local (UNIX), and route.  This allows access to
    other protocol stacks that have not had jail functionality
    added to them.

    Default: 0
    Source: jail(8)

  host_hostuuid=UUID

    Default: UUID
    Source: jail(8)

  tag="any string"

    Custom string for aliasing jails.

    Default: date@time
    Source: local

  template=yes | no

    This property controls whether the jail is a template. Templates are not
    started by iocage. Set to yes if you intend to convert jail into template.
    (See EXAMPLES section)

    Default: no
    Source: local

  boot=on | off

    If set to "on" jail will be auto-started at boot time (rcboot subcommand)
    and stopped at shutdown time (rcshutdown subcommand). Jails will be started
    and stopped based on their priority value.

    Default: off
    Source: local

  notes="any string"

    Custom notes for miscelanious tagging.

    Default: none
    Source: local

  owner=root

    The owner of the jail, can be any string.

    Default: root
    Source: local

  priority=99 | 50 ..

    Start priority at boot time, smaller value means higher priority.
    Also, for shutdown the order will be reversed.

    Default: 99.

  last_started

    Last successful start time. Auto set every time jail starts.

    Default: timestamp
    Source: local

  type=jail

    Currently only jail is supported - this is for future use.

    Default: jail
    Source: local

  hostid=UUID

    The UUID of the host node. Jails won't start if this property differs from the actual UUID
    of the host node. This is to safeguard jails from being started on
    different nodes in case they are periodically replicated across.

    Default: UUID of the host (taken from /etc/hostid)
    Source: local

  release=10.0-RELEASE | 9.2-RELEASE

    The RELEASE used at creation time. Can be set to any string if needed.

    Default: the host's RELEASE
    Source: local

  compression=on | off | lzjb | gzip | gzip-N | zle | lz4

    Controls the compression algorithm used for this dataset. The lzjb
    compression algorithm is optimized for performance while providing
    decent data compression. Setting compression to on uses the lzjb compression
    algorithm. The gzip compression algorithm uses the same compression
    as the gzip(1) command. You can specify the gzip level by
    using the value gzip-N where N is an integer from 1 (fastest) to 9
    (best compression ratio). Currently, gzip is equivalent to gzip-6
    (which is also the default for gzip(1)).  The zle compression algorithm
    compresses runs of zeros.

    The lz4 compression algorithm is a high-performance replacement for
    the lzjb algorithm. It features significantly faster compression and
    decompression, as well as a moderately higher compression ratio than
    lzjb, but can only be used on pools with the lz4_compress feature set
    to enabled.  See zpool-features(7) for details on ZFS feature flags
    and the lz4_compress feature.

    This property can also be referred to by its shortened column name
    compress.  Changing this property affects only newly-written data.

    Default: lz4
    Source: zfs(8)

  origin

    This is only set for clones. Read-only.
    For cloned file systems or volumes, the snapshot from which the clone
    was created. See also the clones property.

    Default: -
    Source: zfs(8)

  quota=15G | 50G | ..

    Quota for jail.
    Limits the amount of space a dataset and its descendents can consume.
    This property enforces a hard limit on the amount of space used. This
    includes all space consumed by descendents, including file systems
    and snapshots. Setting a quota on a descendent of a dataset that
    already has a quota does not override the ancestor's quota, but
    rather imposes an additional limit.

    Default: none
    Source: zfs(8)

  mountpoint

    Path for the jail's root filesystem. Don't tweak this or jail won't start!

    Default: set to jail's root
    Source: zfs(8)

  compressratio

    Compression ratio. Read-only.
    For non-snapshots, the compression ratio achieved for the used space
    of this dataset, expressed as a multiplier.  The used property
    includes descendant datasets, and, for clones, does not include the
    space shared with the origin snapshot.

    Source: zfs(8)

  available

    Available space in jail's dataset.
    The amount of space available to the dataset and all its children,
    assuming that there is no other activity in the pool. Because space
    is shared within a pool, availability can be limited by any number of
    factors, including physical pool size, quotas, reservations, or other
    datasets within the pool.

    Source: zfs(8)

  used

    Used space by jail. Read-only.
    The amount of space consumed by this dataset and all its descendents.
    This is the value that is checked against this dataset's quota and
    reservation. The space used does not include this dataset's reservation,
    but does take into account the reservations of any descendent
    datasets. The amount of space that a dataset consumes from its parent,
    as well as the amount of space that are freed if this dataset is
    recursively destroyed, is the greater of its space used and its
    reservation.

    When snapshots (see the "Snapshots" section) are created, their space
    is initially shared between the snapshot and the file system, and
    possibly with previous snapshots. As the file system changes, space
    that was previously shared becomes unique to the snapshot, and
    counted in the snapshot's space used. Additionally, deleting snapshots
    can increase the amount of space unique to (and used by) other
    snapshots.

    The amount of space used, available, or referenced does not take into
    account pending changes. Pending changes are generally accounted for
    within a few seconds. Committing a change to a disk using fsync(2) or
    O_SYNC does not necessarily guarantee that the space usage information
    is updated immediately.

    Source:  zfs(8)

  dedup=on | off | verify | sha256[,verify]

    Deduplication for jail.
    Configures deduplication for a dataset. The default value is off.
    The default deduplication checksum is sha256 (this may change in the
    future).  When dedup is enabled, the checksum defined here overrides
    the checksum property. Setting the value to verify has the same
    effect as the setting sha256,verify.

    If set to verify, ZFS will do a byte-to-byte comparsion in case of
    two blocks having the same signature to make sure the block contents
    are identical.

    Default: off.
    Source: zfs(8)

  reservation=size | none

    Reserved space for jail.
    The minimum amount of space guaranteed to a dataset and its descendents.
    When the amount of space used is below this value, the dataset
    is treated as if it were taking up the amount of space specified by
    its reservation. Reservations are accounted for in the parent
    datasets' space used, and count against the parent datasets' quotas
    and reservations.

    Default: none
    Source: zfs(8)

  sync_target

    This is for future use, currently not supported.

  sync_tgt_zpool

    This is for future use, currently not supported.

  rlimits=on | off

    If set to "on" resource limits will be enforced.

    Default: off
    Source: local

  cpuset=1 | 1,2,3,4 | 1-2 | off

    Controls the jail's CPU affinity. For more details please refer to cpuset(1).

    Default: off
    Source: cpuset(1)
RESOURCE LIMITS
  Resource limits (except cpuset and rlimits) use the following value
  field formatting in the property: limit:action.

  Limit defines how much of the resource a process can use before the
  defined action triggers.

  Action defines what will happen when a process exceeds the allowed
  amount.

  Valid actions are:
        deny    deny the allocation; not supported for cpu and
                wallclock
        log     log a warning to the console
        devctl  send notification to devd(8)
        sig*    e.g. sigterm; send a signal to the offending
                process

  To better understand what this means please read rctl(8)
  before enabling any limits.

  The following resource limits are supported:

  memoryuse=limit:action | off

    Limits the resident set size (DRAM).

    Default: 8G:log
    Source: rctl(8)

  memorylocked=limit:action | off

    Limits locked memory.

    Default: off
    Source: rctl(8)

  vmemoryuse=limit:action | off

    Virtual memory limit (swap + DRAM combined)

    Default: off
    Source: rctl(8)

  maxproc=limit:action | off

    Limit maximum number of processes.

    Default: off
    Source: rctl(8)

  cputime=limit:action | off

    Limit CPU time, in seconds.

    Default: off
    Source: rctl(8)

  pcpu=limit:action | off

    Limit %CPU, in percents of a single CPU core or hardware thread.

    Default: off
    Source: rctl(8)

  datasize=limit:action | off

    Limit data size.

    Default: off
    Source: rctl(8)

  stacksize=limit:action | off

    Limit stack size.

    Default: off
    Source: rctl(8)

  coredumpsize=limit:action | off

    Limit core dump size.

    Default: off
    Source: rctl(8)

  openfiles=limit:action | off

    Limit file descriptor table size (number of open files).

    Default: off
    Source: rctl(8)

  pseudoterminals=limit:action | off

    Limit number of PTYs.

    Default: off
    Source: rctl(8)

  swapuse=limit:action | off

    Limit swap usage.

    Default: off
    Source: rctl(8)

  nthr=limit:action | off

    Limit number of threads.

    Default: off
    Source: rctl(8)

  msgqqueued=limit:action | off

    Limit number of queued SysV messages.

    Default: off
    Source: rctl(8)

  msgqsize=limit:action | off

    Limit SysV message queue size.

    Default: off
    Source: rctl(8)

  nmsgq=limit:action | off

    Limit number of SysV message queues.

    Default: off
    Source: rctl(8)

  nsemop=limit:action | off

    Limit number of SysV semaphores modified in a single semop(2) call.

    Default: off
    Source: rctl(8)

  nshm=limit:action | off

    Limit number of SysV shared memory segments.

    Default: off
    Source: rctl(8)

  shmsize=limit:action | off

    Limit SysV shared memory size.

    Default: off
    Source: rctl(8)

  wallclock=limit:action | off

    Limit wallclock time.

    Default: off
    Source: rctl(8)

EXAMPLES
  Set up iocage from scratch:

    iocage fetch

  Create first jail:

    iocage create tag=myjail

  List jails:

    iocage list

  Start jail:

    iocage start UUID

  Turn on resource limits and apply them:

    iocage set rlimits=on UUID
    iocage cap UUID

  Display resource usage:

    iocage inuse UUID

  Convert jail into template:

    iocage set template=yes UUID

  List templates:

    iocage list -t

  Clone jail from template:

    iocage clone UUID-of-template tag=myjail

  Record all changeing files in a jail

    iocage record start UUID

  Stop recording

    iocage record stop UUID

  Create package from recorded session

    iocage package UUID

  Import package on another host

    iocage import UUID

  Get the last successful start time for all jails

    iocage show last_started
HINTS
  iocage marks a ZFS pool in the pool's comment field and identifies the
  active pool for use based on this string.

  If using VNET don't forget to add the node's physical NIC into one
  of the bridges if you need an outside connection. Also read bridge(4)
  to see how traffic is handled if you are not familiar with this concept
  (in a nutshell: bridge behaves like a network switch).

  PF firewall is not supported inside VNET jails as of July 2014. PF can be
  enabled for the host however. IPFW is fully supported inside a VNET jail.

  Property validation is not handled by iocage (to keep it simple) so please
  make sure your property values are supported before configuring any
  properties.

  The actual jail name in the jls(8) output is set to ioc-UUID. This is a
  required workaround as jails will refuse to start with jail(8) when name
  starts with a "0".

  To prevent dmesg leak inside jails apply the following sysctl:

    security.bsd.unprivileged_read_msgbuf=0

  If using VNET consider applying these sysctl's as well:

    net.inet.ip.forwarding=1
    net.link.bridge.pfil_onlyip=0
    net.link.bridge.pfil_bridge=0
    net.link.bridge.pfil_member=0

  For more information please visit:

    http://pannon.github.io/iocage/

SEE ALSO
  jail(8), ifconfig(8), epair(4), bridge(4), jexec(8), zfs(8), zpool(8),
  rctl(8), cpuset(1), freebsd-update(8), sysctl(8)
BUGS
  In case of bugs/issues/feature requests, please open an issue at
  https://github.com/pannon/iocage/issues
AUTHORS
  Peter Toth <peter.toth198@gmail.com>
  Brandon Schneider <brandonschneider89@gmail.com>
SPECIAL THANKS
  Sichendra Bista - for his ever willing attitude and ideas.
EOT
}
