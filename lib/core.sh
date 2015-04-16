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

unset LC_ALL
unset LANG

PATH=${PATH}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# Auto UUID
uuid="$(uuidgen)"

# pkg list, only used with the create subcommand
pkglist="none"

# Network defaults for jails start here

# detect VNET kernel and adjust jail default
# if supported turn it on by default
if [ ! -z "$(sysctl -qn kern.features.vimage)" ] ; then
    vnet="on"
else
    vnet="off"
fi

ipv6="on"

interfaces="vnet0:bridge0,vnet1:bridge1"
host_hostname="${uuid}"
exec_fib=0
hostname="${uuid}"
ip4_addr="none"
ip4_saddrsel="1"
ip4="new"
ip6_addr="none"
ip6_saddrsel="1"
ip6="new"
defaultrouter="none"
defaultrouter6="none"

# Standard jail properties
devfs_ruleset="4"
exec_start="/bin/sh /etc/rc"
exec_stop="/bin/sh /etc/rc.shutdown"
exec_prestart="/usr/bin/true"
exec_poststart="/usr/bin/true"
exec_prestop="/usr/bin/true"
exec_poststop="/usr/bin/true"
exec_clean=1
exec_timeout=60
stop_timeout=30
exec_jail_user=root
exec_system_jail_user=0
exec_system_user=root
mount_devfs=1
mount_fdescfs=1
enforce_statfs="2"
children_max="0"
login_flags='-f root'
securelevel="2"
host_hostuuid="${uuid}"
allow_set_hostname=1
allow_sysvipc=0
allow_raw_sockets=0
allow_chflags=0
allow_mount=0
allow_mount_devfs=0
allow_mount_nullfs=0
allow_mount_procfs=0
allow_mount_tmpfs=0
allow_mount_zfs=0
allow_quotas=0
allow_socket_af=0

# RCTL limits
cpuset="off"
rlimits="off"
memoryuse="8G:log"
memorylocked="off"
vmemoryuse="off"
maxproc="off"
cputime="off"
pcpu="off"
datasize="off"
stacksize="off"
coredumpsize="off"
openfiles="off"
pseudoterminals="off"
swapuse="off"
nthr="off"
msgqqueued="off"
msgqsize="off"
nmsgq="off"
nsemop="off"
nshm="off"
shmsize="off"
wallclock="off"

# Custom properties
iocroot="/iocage"
tag="$(date "+%F@%T")"
template="no"
boot="off"
notes="none"
owner="root"
priority="99"
last_started="none"
type="jail"
release="$(uname -r|cut -f 1,2 -d'-')"
hostid="$(cat /etc/hostid)"
jail_zfs="off"
jail_zfs_dataset="iocage/jails/${uuid}/root/data"
mount_procfs="0"

# Native ZFS properties
compression="lz4"
origin="readonly"
quota="none"
mountpoint="readonly"
compressratio="readonly"
available="readonly"
used="readonly"
dedup="off"
reservation="none"

# Sync properties
sync_state="none"
sync_target="none"
sync_tgt_zpool="none"

# FTP variables
ftphost="ftp.freebsd.org"
ftpfiles="base.txz doc.txz lib32.txz src.txz"

# Resource limits
CONF_RCTL="memoryuse
           memorylocked
           vmemoryuse
           maxproc
           cputime
           pcpu
           datasize
           stacksize
           coredumpsize
           openfiles
           pseudoterminals
           swapuse
           nthr
           msgqqueued
           msgqsize
           nmsgq
           nsemop
           nshm
           shmsize
           wallclock"

# Networking configuration
CONF_NET="interfaces
          vnet
          host_hostname
          hostname
          ip4_addr
          ip4_saddrsel
          ip4
          ip6_addr
          ip6_saddrsel
          ip6
          defaultrouter
          defaultrouter6
          exec_fib"

# Native jail properties
CONF_JAIL="devfs_ruleset
           mount_devfs
           exec_start
           exec_stop
           exec_prestart
           exec_prestop
           exec_poststop
           exec_poststart
           exec_clean
           exec_timeout
           stop_timeout
           exec_jail_user
           exec_system_jail_user
           exec_system_user
           mount_fdescfs
           mount_procfs
           enforce_statfs
           children_max
           login_flags
           securelevel
           allow_set_hostname
           allow_sysvipc
           allow_raw_sockets
           allow_chflags
           allow_mount
           allow_mount_devfs
           allow_mount_nullfs
           allow_mount_procfs
           allow_mount_tmpfs
           allow_mount_zfs
           allow_quotas
           allow_socket_af
           host_hostuuid"

# Custom properties
CONF_CUSTOM="tag
             template
             rlimits
             boot
             notes
             owner
             priority
             last_started
             type
             hostid
             cpuset
             jail_zfs
             jail_zfs_dataset
             release"

# Native ZFS properties
CONF_ZFS="compression
          origin
          quota
          mountpoint
          compressratio
          available
          used
          dedup
          reservation"

# ZFS sync (not used yet)
CONF_SYNC="sync_stat
           sync_target
           sync_tgt_zpool"

# ftp properties
CONF_FTP="ftphost ftpdir"

# Basejail filesystems
bfs_list="bin
          boot
          lib
          libexec
          rescue
          sbin
          usr/bin
          usr/include
          usr/lib
          usr/libexec
          usr/sbin
          usr/share
          usr/src
          usr/libdata
          usr/lib32"

# Basejail directories
bdir_list="dev
           tmp
           var
           etc
           root
           proc
           mnt"


# Process command line options-------------------------
__parse_cmd () {
    while [ "${#}" -gt 0 ] ; do
        case "${1}" in
            list)       __list_jails "${2}"
                        exit
                ;;
            console)    __console "${2}"
                        exit
                ;;
            exec)       shift
                        __exec "${@}"
                        exit
                ;;
            chroot)     __chroot "${2}" "${3}"
                        exit
                ;;
            defaults)   __print_defaults
                        exit
                ;;
            create)     __export_props "${@}"
                        __create_jail "${@}"
                        exit
                ;;
            destroy)    __destroy_jail "${2}"
                        exit
                ;;
            clone)      __export_props "${@}"
                        __clone_jail "${2}"
                        exit
                ;;
            fetch)      __export_props "${@}"
                        __fetch_release
                        exit
                ;;
            get)        __get_jail_prop "${2}" "${3}"
                        exit
                ;;
            set)        __export_props "${@}"
                        __set_jail_prop "${2}" "${3}"
                        exit
                ;;
            start)      __start_jail "${2}"
                        exit
                ;;
            stop)       __stop_jail "${2}"
                        exit
                ;;
            restart)    __restart_jail "${2}"
                        exit
                ;;
            rcboot)     __rc_jails boot
                        exit
                ;;
            rcshutdown) __rc_jails shutdown
                        exit
                ;;
            df)         __print_disk
                        exit
                ;;
            snapshot)   __snapshot "${2}"
                        exit
                ;;
            snaplist)   __snaplist "${2}"
                        exit
                ;;
            snapremove) __snapremove "${2}"
                        exit
                ;;
            promote)    __promote "${2}"
                        exit
                ;;
            rollback)   __rollback "${2}"
                        exit
                ;;
            uncap)      __rctl_uncap "${2}"
                        exit
                ;;
            cap)        __rctl_limits "${2}"
                        exit
                ;;
            limits)     __rctl_list "${2}"
                        exit
                ;;
            inuse)      __rctl_used "${2}"
                        exit
                ;;
            runtime)    __runtime "${2}"
                        exit
                ;;
            update)     __update "${2}"
                        exit
                ;;
            upgrade)     __upgrade "${2}"
                        exit
                ;;
            record)     __record "${2}" "${3}"
                        exit
                ;;
            package)    __package "${2}"
                        exit
                ;;
            export)     __export "${2}"
                        exit
                ;;
            import)     __export_props "${@}"
                        __import "${2}"
                        exit
                ;;
            show)       __show "${2}"
                        exit
                ;;
            help)       __help
                        exit
                ;;
                *)      __usage
                        exit
                ;;
        esac
        shift
    done
}

# Print defaults set in this script---------------------------
__print_defaults () {
    CONF="${CONF_NET}
          ${CONF_JAIL}
          ${CONF_RCTL}
          ${CONF_CUSTOM}
          ${CONF_ZFS}
          ${CONF_SYNC}
          ${CONF_FTP}"

    for prop in ${CONF} ; do
        prop_name="${prop}"
        eval prop="\$${prop}"
        if [ ! -z "${prop}" ] ; then
            echo "${prop_name}=${prop}"
        fi
    done
}

# Print supported releases----------------------------------
__print_release () {
    supported="10.1-RELEASE
                9.3-RELEASE"

    echo "Supported releases are: "
    for rel in ${supported} ; do
        printf "%15s\n" "${rel}"
    done
}

__get_jail_name () {
    for i in ${@}; do
        :;
    done

    echo "${i}"
}

__list_jails () {
    local jails=$(__find_jail ALL)
    local switch="${1}"
    local all_jids=$(jls -N -h jid | grep -v -x jid )
    local ioc_jids=""
    local non_ioc_jids=""

    if [ ! -z "${switch}" ] && [ "${switch}" == "-r" ] ; then
        echo "Downloaded releases:"
        local releases="$(zfs list -o name -Hr "${pool}/iocage/releases" \
                        | grep RELEASE$ | cut -d '/' -f 4)"
        for rel in ${releases} ; do
            printf "%15s\n" "${rel}"
        done
        exit 0
    fi

    printf "%-4s  %-36s  %s  %s  %s\n" "JID" "UUID"  "BOOT"\
           "STATE" "TAG"
    for jail in ${jails} ; do
        uuid=$(zfs get -H -o value org.freebsd.iocage:host_hostuuid "${jail}")
        boot=$(zfs get -H -o value org.freebsd.iocage:boot "${jail}")
        tag=$(zfs get -H -o value org.freebsd.iocage:tag "${jail}")
        jail_path=$(zfs get -H -o value mountpoint "${jail}")
        state=$(jls | grep "${jail_path}" | awk '{print $1}')
        template=$(zfs get -H -o value org.freebsd.iocage:template "${jail}")
        # get jid for iocage jails
        jid="$(jls -j "ioc-${uuid}"  -h jid 2> /dev/null | grep -v -x "jid")"
        if [ -z "${jid}"  ] ; then
            jid="-"
        fi
        local ioc_jids="${ioc_jids} ${jid}"

        if [ -z "${state}" ] ; then
            state=down
        else
            state=up
        fi

        if [ -z "${switch}" ] ; then
            switch=zero
        fi

        if [ "${switch}" == "-t" ] ; then
            if [ "${template}" == "yes" ] ; then
                printf "%-4s  %-+.36s  %-3s   %-4s   %s\n" "${jid}" "${uuid}" \
                "${boot}" "${state}" "${tag}"
            fi
        elif [ "${switch}" != "-t" ] ; then
            if [ "${template}" != "yes" ] ; then
                printf "%-4s  %-+.36s  %-4s  %-4s   %s\n" "${jid}" "${uuid}"  \
                "${boot}" "${state}" "${tag}"
            fi
        fi
    done

    # create list of active jids not registered in iocage
    for all_jail in ${all_jids} ; do
        for ioc_jail in ${ioc_jids} ; do
            if [ "$all_jail" == "${ioc_jail}" ] ; then
                local temp_loop_var=""
                break
            else
                local temp_loop_var="${all_jail}"

            fi
        done
    if [ -n "${temp_loop_var}" ] ; then
        local non_ioc_jids="${non_ioc_jids} ${temp_loop_var}"
    fi
    done

    # output non iocage jails currently active
    if [ -n "${non_ioc_jids}" ] ; then
        if [ "${switch}" != "-t" ] ; then
            printf "%-+40s\n" "--- non iocage jails currently active ---"
            printf "%-4s  %-36s  %-15s  %s \n" "JID" "PATH"\
                  "IP4" "HOSTNAME"
            for jid in ${non_ioc_jids} ; do
                path=$(jls -j "${jid}"  -h path | grep -v -x "path")
                ip4=$(jls -j "${jid}"  -h ip4.addr | grep -v -x "ip4.addr")
                host_hostname=$(jls -j "${jid}"  -h host.hostname | grep -v -x "host.hostname")
                printf "%-4s  %-36.36s  %-15s  %s\n" "${jid}" "${path}"  \
                        "${ip4}" "${host_hostname}"
            done
        fi
    fi
}

__show () {
    local jails="$(__find_jail ALL)"
    local prop="${1}"

    printf "%-36s  %s\n" "UUID" "${prop}"

    for jail in ${jails} ; do
        local name="$(zfs get -H -o value org.freebsd.iocage:host_hostuuid \
                    "${jail}")"
        local value="$(__get_jail_prop "${prop}" "${name}")"

        printf "%-+.36s  %s\n" "${name}"  "${value}"
    done
}

__check_name () {
    local name="${1}"

    if [ -z "${name}" ] ; then
        echo "ERROR"
        exit 1
    fi

    local dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: jail ${name} not found!"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local uuid="$(__get_jail_prop host_hostuuid "${name}")"

    echo "${uuid}"

}
