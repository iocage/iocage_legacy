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

PATH=${PATH}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin ; export PATH

# Auto UUID
uuid="$(uuidgen)" ; export uuid

# pkg list, only used with the create subcommand
pkglist="none" ; export pkglist

# Network defaults for jails start here

# detect VNET kernel and adjust jail default
# if supported turn it on by default
if [ ! -z "$(sysctl -qn kern.features.vimage)" ] ; then
    vnet="on" ; export     vnet
else
    vnet="off" ; export     vnet
fi

ipv6="on" ; export ipv6

interfaces="vnet0:bridge0,vnet1:bridge1" ; export interfaces
host_hostname="${uuid}" ; export host_hostname
exec_fib=0 ; export exec_fib
hostname="${uuid}" ; export hostname
ip4_addr="none" ; export ip4_addr
ip4_saddrsel="1" ; export ip4_saddrsel
ip4="new" ; export ip4
ip6_addr="none" ; export ip6_addr
ip6_saddrsel="1" ; export ip6_saddrsel
ip6="new" ; export ip6
defaultrouter="none" ; export defaultrouter
defaultrouter6="none" ; export defaultrouter6

# Standard jail properties
devfs_ruleset="4" ; export devfs_ruleset
exec_start="/bin/sh /etc/rc" ; export exec_start
exec_stop="/bin/sh /etc/rc.shutdown" ; export exec_stop
exec_prestart="/usr/bin/true" ; export exec_prestart
exec_poststart="/usr/bin/true" ; export exec_poststart
exec_prestop="/usr/bin/true" ; export exec_prestop
exec_poststop="/usr/bin/true" ; export exec_poststop
exec_clean=1 ; export exec_clean
exec_timeout=60 ; export exec_timeout
stop_timeout=30 ; export stop_timeout
exec_jail_user=root ; export exec_jail_user
exec_system_jail_user=0 ; export exec_system_jail_user
exec_system_user=root ; export exec_system_user
mount_devfs=1 ; export mount_devfs
mount_fdescfs=1 ; export mount_fdescfs
enforce_statfs="2" ; export enforce_statfs
children_max="0" ; export children_max
login_flags='-f root' ; export login_flags
securelevel="2" ; export securelevel
host_hostuuid="${uuid}" ; export host_hostuuid
allow_set_hostname=1 ; export allow_set_hostname
allow_sysvipc=0 ; export allow_sysvipc
allow_raw_sockets=0 ; export allow_raw_sockets
allow_chflags=0 ; export allow_chflags
allow_mount=0 ; export allow_mount
allow_mount_devfs=0 ; export allow_mount_devfs
allow_mount_nullfs=0 ; export allow_mount_nullfs
allow_mount_procfs=0 ; export allow_mount_procfs
allow_mount_tmpfs=0 ; export allow_mount_tmpfs
allow_mount_zfs=0 ; export allow_mount_zfs
allow_quotas=0 ; export allow_quotas
allow_socket_af=0 ; export allow_socket_af

# RCTL limits
cpuset="off" ; export cpuset
rlimits="off" ; export rlimits
memoryuse="8G:log" ; export memoryuse
memorylocked="off" ; export memorylocked
vmemoryuse="off" ; export vmemoryuse
maxproc="off" ; export maxproc
cputime="off" ; export cputime
pcpu="off" ; export pcpu
datasize="off" ; export datasize
stacksize="off" ; export stacksize
coredumpsize="off" ; export coredumpsize
openfiles="off" ; export openfiles
pseudoterminals="off" ; export pseudoterminals
swapuse="off" ; export swapuse
nthr="off" ; export nthr
msgqqueued="off" ; export msgqqueued
msgqsize="off" ; export msgqsize
nmsgq="off" ; export nmsgq
nsemop="off" ; export nsemop
nshm="off" ; export nshm
shmsize="off" ; export shmsize
wallclock="off" ; export wallclock

# Custom properties
iocroot="/iocage" ; export iocroot
tag="$(date "+%F@%T")" ; export tag
template="no" ; export template
boot="off" ; export boot
notes="none" ; export notes
owner="root" ; export owner
priority="99" ; export priority
last_started="none" ; export last_started
type="jail" ; export type
release="$(uname -r|cut -f 1,2 -d'-')" ; export release
hostid="$(cat /etc/hostid)" ; export hostid
jail_zfs="off" ; export jail_zfs
jail_zfs_dataset="iocage/jails/${uuid}/root/data" ; export jail_zfs_dataset
mount_procfs="0" ; export mount_procfs

# Native ZFS properties
compression="lz4" ; export compression
origin="readonly" ; export origin
quota="none" ; export quota
mountpoint="readonly" ; export mountpoint
compressratio="readonly" ; export compressratio
available="readonly" ; export available
used="readonly" ; export used
dedup="off" ; export dedup
reservation="none" ; export reservation

# Sync properties
sync_state="none" ; export sync_state
sync_target="none" ; export sync_target
sync_tgt_zpool="none" ; export sync_tgt_zpool

# FTP variables
ftphost="ftp.freebsd.org" ; export ftphost
ftpfiles="base.txz doc.txz lib32.txz src.txz" ; export ftpfiles

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
export CONF_RCTL

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
export CONF_NET

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
export CONF_JAIL

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
export CONF_JAIL

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
export CONF_ZFS

# ZFS sync (not used yet)
CONF_SYNC="sync_stat
           sync_target
           sync_tgt_zpool"
export CONF_SYNC

# ftp properties
CONF_FTP="ftphost ftpdir" ; export CONF_FTP

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
export bfs_list

# Basejail directories
bdir_list="dev
           tmp
           var
           etc
           root
           proc
           mnt"
export bdir_list

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
    jails="$(__find_jail ALL)"
    switch="${1}"
    all_jids="$(jls -N -h jid | grep -v -x jid )"
    ioc_jids=""
    non_ioc_jids=""

    if [ ! -z "${switch}" ] && [ "${switch}" == "-r" ] ; then
        echo "Downloaded releases:"
        releases="$(zfs list -o name -Hr "${pool}/iocage/releases" \
                        | grep 'RELEASE$' | cut -d '/' -f 4)"
        for rel in ${releases} ; do
            printf "%15s\n" "${rel}"
        done
        exit 0
    fi

    printf "%-4s  %-36s  %s  %s  %s\n" "JID" "UUID"  "BOOT"\
           "STATE" "TAG"
    for jail in ${jails} ; do
        uuid="$(zfs get -H -o value org.freebsd.iocage:host_hostuuid "${jail}")"
        boot="$(zfs get -H -o value org.freebsd.iocage:boot "${jail}")"
        tag="$(zfs get -H -o value org.freebsd.iocage:tag "${jail}")"
        jail_path="$(zfs get -H -o value mountpoint "${jail}")"
        state="$(jls | grep "${jail_path}" | cut -w -f1)"
        template="$(zfs get -H -o value org.freebsd.iocage:template "${jail}")"
        # get jid for iocage jails
        jid="$(jls -j "ioc-${uuid}"  -h jid 2> /dev/null | grep -v -x "jid")"
        if [ -z "${jid}"  ] ; then
            jid="-"
        fi
        ioc_jids="${ioc_jids} ${jid}"

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
                temp_loop_var=""
                break
            else
                temp_loop_var="${all_jail}"

            fi
        done
    if [ -n "${temp_loop_var}" ] ; then
        non_ioc_jids="${non_ioc_jids} ${temp_loop_var}"
    fi
    done

    # output non iocage jails currently active
    if [ -n "${non_ioc_jids}" ] ; then
        if [ "${switch}" != "-t" ] ; then
            printf "%-+40s\n" "--- non iocage jails currently active ---"
            printf "%-4s  %-36s  %-15s  %s \n" "JID" "PATH"\
                  "IP4" "HOSTNAME"
            for jid in ${non_ioc_jids} ; do
                path="$(jls -j "${jid}"  -h path | grep -v -x "path")"
                ip4="$(jls -j "${jid}"  -h ip4.addr | grep -v -x "ip4.addr")"
                host_hostname="$(jls -j "${jid}"  -h host.hostname | grep -v -x "host.hostname")"
                printf "%-4s  %-36.36s  %-15s  %s\n" "${jid}" "${path}"  \
                        "${ip4}" "${host_hostname}"
            done
        fi
    fi
}

__show () {
    jails="$(__find_jail ALL)"
    prop="${1}"

    printf "%-36s  %s\n" "UUID" "${prop}"

    for jail in ${jails} ; do
        name="$(zfs get -H -o value org.freebsd.iocage:host_hostuuid \
                    "${jail}")"
        value="$(__get_jail_prop "${prop}" "${name}")"

        printf "%-+.36s  %s\n" "${name}"  "${value}"
    done
}

__check_name () {
    name="${1}"

    if [ -z "${name}" ] ; then
        echo "ERROR"
        exit 1
    fi

    dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: jail ${name} not found!"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    uuid="$(__get_jail_prop host_hostuuid "${name}")"

    echo "${uuid}"

}
