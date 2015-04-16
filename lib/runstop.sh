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

__start_jail () {
    local name="${1}"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: ${name} not found"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local fulluuid="$(__check_name "${name}")"
    local jail_type="$(__get_jail_prop type "${fulluuid}")"
    local tag="$(__get_jail_prop tag "${fulluuid}")"
    local jail_hostid="$(__get_jail_prop hostid "${fulluuid}")"
    local jail_path="$(__get_jail_prop mountpoint "${fulluuid}")"
    local template="$(__get_jail_prop template "${fulluuid}")"
    local cpuset="$(__get_jail_prop cpuset "${fulluuid}")"
    local procfs="$(__get_jail_prop mount_procfs "${fulluuid}")"
    local jail_path="$(__get_jail_prop mountpoint "${fulluuid}")"
    local state="$(jls | grep "${jail_path}" | wc -l | sed -e 's/^  *//' \
              | cut -d' ' -f1)"
    local vnet="$(__get_jail_prop vnet "${fulluuid}")"
    local nics="$(__get_jail_prop interfaces "${fulluuid}" \
               |awk 'BEGIN { FS = "," } ; { print $1,$2,$3,$4 }')"

    if [ "${state}" -eq "1" ] ; then
        echo "* ${fulluuid}: is already up"
        exit 1
    fi

    if [ "${jail_type}" == "basejail" ] ; then
        # Re-clone required filesystems
        __reclone_basejail "${name}"
    fi

    for i in ${nics} ; do
        local nic="$(echo "${i}" | awk 'BEGIN { FS = ":" } ; { print $1 }')"
        local bridge="$(echo "${i}" | awk 'BEGIN { FS = ":" } ; { print $2 }')"

        if [ -z "${nic}" ] || [ -z "${bridge}" ] ; then
            echo "  ERROR  : incorrect interfaces property format"
            echo "  HINT   : check with \"iocage get interfaces ${fulluuid}\""
            echo "  Example: vnet0:bridge0"
            exit 1
        fi
    done

    if [ "${template}" == "yes" ] ; then
        return
    fi

    if [ "${jail_hostid}" != "${hostid}" ] ; then
        echo "ERROR: hostid mismatch, start failed!"
        echo "    jail hostid: ${jail_hostid}"
        echo "  hosts hostid: ${hostid}"
        exit 1
    fi

    if [ "${procfs}" == "1" ] ; then
        mount -t procfs proc "${iocroot}/jails/${fulluuid}/root/proc"
    fi

    local jzfs="$(__get_jail_prop jail_zfs "${fulluuid}")"
    local jzfs_dataset="$(__get_jail_prop jail_zfs_dataset "${fulluuid}")"

    if [ "${jzfs}" == "on" ] ; then
        __set_jail_prop allow_mount=1 "${fulluuid}"
        __set_jail_prop enforce_statfs=1 "${fulluuid}"
        __set_jail_prop allow_mount_zfs=1 "${fulluuid}"
        zfs set jailed=on "${pool}/${jzfs_dataset}"
    fi

    if [ "${vnet}" == "on" ] || [ "${vnet}" == "-" ] ; then
        if [ ! -z "$(sysctl -qn kern.features.vimage)" ] ; then
            echo "* Starting ${fulluuid} (${tag})"
            __vnet_start "${fulluuid}"

            if [ "${?}" -eq 1 ] ; then
                echo "  ! Start                FAILED"
                exit 1
            else
                echo "  + Started                  OK"
            fi

            echo -n "  + Configuring VNET"
            __networking start "${fulluuid}"

            if [ "${?}" -eq 1 ] ; then
                echo "         FAILED"
            else
                echo "         OK"
            fi
        else
            echo "  ERR: start failed for ${fulluuid}"
            echo "  vnet=on but kernel is not VNET capable!"
            echo "  Turn vnet off for this jail or recompile kernel with VNET."
            exit 1
        fi
    else
        echo "* Starting ${fulluuid} (${tag})"
        __legacy_start "${fulluuid}"
        if [ "${?}" -eq 1 ] ; then
            echo "  ! Start                FAILED"
        else
            echo "  + Started (shared IP mode) OK"
        fi
    fi

    cd "${jail_path}/root/dev" && ln -s ../var/run/log log

    __rctl_limits "${fulluuid}"

    if [ "${cpuset}" != "off" ] ; then
        echo -n "  + Appliyng CPU affinity"
        local jid="$(jls -j "ioc-${fulluuid}" jid)"
        cpuset -l "${cpuset}" -j "${jid}"
        if [ "${?}" -eq 1 ] ; then
            echo "    FAILED"
        else
            echo "    OK"
        fi
    fi

    echo -n "  + Starting services"
    jexec "ioc-${fulluuid}" $(__get_jail_prop exec_start "$fulluuid") \
     >> "${iocroot}/log/${fulluuid}-console.log" 2>&1

    if [ "${?}" -eq 1 ] ; then
        echo "        FAILED"
    else
        echo "        OK"
    fi

    if [ "${jzfs}" == "on" ] ; then
        zfs jail "ioc-${fulluuid}" "${pool}/${jzfs_dataset}"
    fi

    zfs set org.freebsd.iocage:last_started="$(date "+%F_%T")" "${dataset}"

}

# Start a VNET jail
__vnet_start () {
    local name="${1}"
    local jail_path="$(__get_jail_prop mountpoint "${name}")"
    local fdescfs="mount.fdescfs=$(__get_jail_prop mount_fdescfs "${name}")"
    local tmpfs="allow.mount.tmpfs=$(__get_jail_prop allow_mount_tmpfs "${name}")"


    if [ "$(uname -U)" == "903000" ];
    then
      fdescfs=""
      tmpfs=""
    fi

    jail -c vnet \
    name="ioc-$(__get_jail_prop host_hostuuid "${name}")" \
    host.hostname="$(__get_jail_prop hostname "${name}")" \
    path="${jail_path}/root" \
    securelevel="$(__get_jail_prop securelevel "${name}")" \
    host.hostuuid="$(__get_jail_prop host_hostuuid "${name}")" \
    devfs_ruleset="$(__get_jail_prop devfs_ruleset "${name}")" \
    enforce_statfs="$(__get_jail_prop enforce_statfs "${name}")" \
    children.max="$(__get_jail_prop children_max "${name}")" \
    allow.set_hostname="$(__get_jail_prop allow_set_hostname "${name}")" \
    allow.sysvipc="$(__get_jail_prop allow_sysvipc "${name}")" \
    allow.raw_sockets="$(__get_jail_prop allow_raw_sockets "${name}")" \
    allow.chflags="$(__get_jail_prop allow_chflags "${name}")" \
    allow.mount="$(__get_jail_prop allow_mount "${name}")" \
    allow.mount.devfs="$(__get_jail_prop allow_mount_devfs "${name}")" \
    allow.mount.nullfs="$(__get_jail_prop allow_mount_nullfs "${name}")" \
    allow.mount.procfs="$(__get_jail_prop allow_mount_procfs "${name}")" \
    ${tmpfs} \
    allow.mount.zfs="$(__get_jail_prop allow_mount_zfs "${name}")" \
    allow.quotas="$(__get_jail_prop allow_quotas "${name}")" \
    allow.socket_af="$(__get_jail_prop allow_socket_af "${name}")" \
    exec.poststart="$(__findscript "${name}" poststart)" \
    exec.prestop="$(__findscript "${name}" prestop)" \
    exec.stop="$(__get_jail_prop exec_stop "${name}")" \
    exec.clean="$(__get_jail_prop exec_clean "${name}")" \
    exec.timeout="$(__get_jail_prop exec_timeout "${name}")" \
    stop.timeout="$(__get_jail_prop stop_timeout "${name}")" \
    mount.fstab="${jail_path}/fstab" \
    mount.devfs="$(__get_jail_prop mount_devfs "${name}")" \
    ${fdescfs} \
    allow.dying \
    exec.consolelog="$iocroot/log/${name}-console.log" \
    persist
}

# Start a shared IP jail
__legacy_start () {
    local name="${1}"
    local jail_path="$(__get_jail_prop mountpoint "${name}")"
    local ip4_addr="$(__get_jail_prop ip4_addr "${name}")"
    local ip6_addr="$(__get_jail_prop ip6_addr "${name}")"

    local fdescfs="mount.fdescfs=$(__get_jail_prop mount_fdescfs "${name}")"
    local tmpfs="allow.mount.tmpfs=$(__get_jail_prop allow_mount_tmpfs "${name}")"

    if [ "$(uname -U)" == "903000" ];
    then
      fdescfs=""
      tmpfs=""
    fi


    if [ "${ip4_addr}" == "none" ] ; then
        ip4_addr=""
    fi

    if [ "${ip6_addr}" == "none" ] ; then
        ip6_addr=""
    fi

    if [ "${ipv6}" == "on" ] ; then
        jail -c \
        ip4.addr="${ip4_addr}" \
        ip4.saddrsel="$(__get_jail_prop ip4_saddrsel "${name}")" \
        ip4="$(__get_jail_prop ip4 "${name}")" \
        ip6.addr="${ip6_addr}" \
        ip6.saddrsel="$(__get_jail_prop ip6_saddrsel "${name}")" \
        ip6="$(__get_jail_prop ip6 "${name}")" \
        name="ioc-$(__get_jail_prop host_hostuuid "${name}")" \
        host.hostname="$(__get_jail_prop hostname "${name}")" \
        path="${jail_path}/root" \
        securelevel="$(__get_jail_prop securelevel "${name}")" \
        host.hostuuid="$(__get_jail_prop host_hostuuid "${name}")" \
        devfs_ruleset="$(__get_jail_prop devfs_ruleset "${name}")" \
        enforce_statfs="$(__get_jail_prop enforce_statfs "${name}")" \
        children.max="$(__get_jail_prop children_max "${name}")" \
        allow.set_hostname="$(__get_jail_prop allow_set_hostname "${name}")" \
        allow.sysvipc="$(__get_jail_prop allow_sysvipc "${name}")" \
        allow.raw_sockets="$(__get_jail_prop allow_raw_sockets "${name}")" \
        allow.chflags="$(__get_jail_prop allow_chflags "${name}")" \
        allow.mount="$(__get_jail_prop allow_mount "${name}")" \
        allow.mount.devfs="$(__get_jail_prop allow_mount_devfs "${name}")" \
        allow.mount.nullfs="$(__get_jail_prop allow_mount_nullfs "${name}")" \
        allow.mount.procfs="$(__get_jail_prop allow_mount_procfs "${name}")" \
        ${tmpfs} \
        allow.mount.zfs="$(__get_jail_prop allow_mount_zfs "${name}")" \
        allow.quotas="$(__get_jail_prop allow_quotas "${name}")" \
        allow.socket_af="$(__get_jail_prop allow_socket_af "${name}")" \
        exec.prestart="$(__findscript "${name}" prestart)" \
        exec.poststart="$(__findscript "${name}" poststart)" \
        exec.prestop="$(__findscript "${name}" prestop)" \
        exec.stop="$(__get_jail_prop exec_stop "${name}")" \
        exec.clean="$(__get_jail_prop exec_clean "${name}")" \
        exec.timeout="$(__get_jail_prop exec_timeout "${name}")" \
        stop.timeout="$(__get_jail_prop stop_timeout "${name}")" \
        mount.fstab="${jail_path}/fstab" \
        mount.devfs="$(__get_jail_prop mount_devfs "${name}")" \
        ${fdescfs} \
        allow.dying \
        exec.consolelog="${iocroot}/log/${name}-console.log" \
        persist
    else
        jail -c \
        ip4.addr="${ip4_addr}" \
        ip4.saddrsel="$(__get_jail_prop ip4_saddrsel "${name}")" \
        ip4="$(__get_jail_prop ip4 "${name}")" \
        name="ioc-$(__get_jail_prop host_hostuuid "${name}")" \
        host.hostname="$(__get_jail_prop hostname "${name}")" \
        path="${jail_path}/root" \
        securelevel="$(__get_jail_prop securelevel "${name}")" \
        host.hostuuid="$(__get_jail_prop host_hostuuid "${name}")" \
        devfs_ruleset="$(__get_jail_prop devfs_ruleset "${name}")" \
        enforce_statfs="$(__get_jail_prop enforce_statfs "${name}")" \
        children.max="$(__get_jail_prop children_max "${name}")" \
        allow.set_hostname="$(__get_jail_prop allow_set_hostname "${name}")" \
        allow.sysvipc="$(__get_jail_prop allow_sysvipc "${name}")" \
        allow.raw_sockets="$(__get_jail_prop allow_raw_sockets "${name}")" \
        allow.chflags="$(__get_jail_prop allow_chflags "${name}")" \
        allow.mount="$(__get_jail_prop allow_mount "${name}")" \
        allow.mount.devfs="$(__get_jail_prop allow_mount_devfs "${name}")" \
        allow.mount.nullfs="$(__get_jail_prop allow_mount_nullfs "${name}")" \
        allow.mount.procfs="$(__get_jail_prop allow_mount_procfs "${name}")" \
        ${tmpfs} \
        allow.mount.zfs="$(__get_jail_prop allow_mount_zfs "${name}")" \
        allow.quotas="$(__get_jail_prop allow_quotas "${name}")" \
        allow.socket_af="$(__get_jail_prop allow_socket_af "${name}")" \
        exec.prestart="$(__findscript "${name}" prestart)" \
        exec.poststart="$(__findscript "${name}" poststart)" \
        exec.prestop="$(__findscript "${name}" prestop)" \
        exec.stop="$(__get_jail_prop exec_stop "${name}")" \
        exec.clean="$(__get_jail_prop exec_clean "${name}")" \
        exec.timeout="$(__get_jail_prop exec_timeout "${name}")" \
        stop.timeout="$(__get_jail_prop stop_timeout "${name}")" \
        mount.fstab="${jail_path}/fstab" \
        mount.devfs="$(__get_jail_prop mount_devfs "${name}")" \
        ${fdescfs} \
        allow.dying \
        exec.consolelog="${iocroot}/log/${name}-console.log" \
        persist
    fi
}

__stop_jail () {
    local name="${1}"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: ${name} not found"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local fulluuid="$(__check_name "${name}")"
    local jail_path="$(__get_jail_prop mountpoint "${name}")"
    local tag="$(__get_jail_prop tag "${fulluuid}")"
    local exec_prestop="$(__findscript "${fulluuid}" prestop)"
    local exec_stop="$(__get_jail_prop exec_stop "${fulluuid}")"
    local exec_poststop="$(__findscript "${fulluuid}" poststop)"
    local vnet="$(__get_jail_prop vnet "${fulluuid}")"
    local state="$(jls | grep "${jail_path}" | wc -l | sed -e 's/^  *//' \
              | cut -d' ' -f1)"


    if [  "${state}" -lt "1" ] ; then
        echo "* ${fulluuid}: is already down"
        exit 1
    fi

    echo "* Stopping ${fulluuid} (${tag})"

    echo -n "  + Running pre-stop"
    echo "${exec_prestop}" | sh
    if [ "${?}" -ne 1 ] ; then
        echo "         OK"
    else
        echo "     FAILED"
    fi

    echo -n "  + Stopping services"

    jexec "ioc-${fulluuid}" ${exec_stop} >> "${iocroot}/log/${fulluuid}-console.log" 2>&1

    if [ "${?}" -ne 1 ] ; then
        echo "        OK"
    else
        echo "    FAILED"
    fi

    if [ "${vnet}" == "on" ] ; then
        echo -n "  + Tearing down VNET"
        __networking stop "${fulluuid}"
        if [ "${?}" -eq 1 ] ; then
            echo "        FAILED"
        else
            echo "        OK"
        fi
    else
        __stop_legacy_networking "${name}"
    fi

    echo -n "  + Removing jail process"
    jail -r "ioc-${fulluuid}"

    if [ "${?}" -ne 1 ] ; then
        echo "    OK"
    else
        echo "FAILED"
    fi

    echo -n "  + Running post-stop"
    echo "${exec_poststop}" | sh
    if [ "${?}" -ne 1 ] ; then
        echo "        OK"
    else
        echo "    FAILED"
    fi

    umount -afvF "${jail_path}/fstab" > /dev/null 2>&1
    umount "${jail_path}/root/dev/fd" > /dev/null 2>&1
    umount "${jail_path}/root/dev"    > /dev/null 2>&1
    umount "${jail_path}/root/proc"   > /dev/null 2>&1

    if [ -d "${iocroot}/jails/${fulluuid}/recorded" ] ; then
        umount -ft unionfs "${iocroot}/jails/${fulluuid}/root" > /dev/null 2>&1
    fi

    if [ ! -z $(sysctl -qn kern.features.rctl) ] ; then
        local rlimits="$(rctl | grep "$fulluuid" | wc -l | sed -e 's/^  *//' \
                | cut -d' ' -f1)"
        if [ "${rlimits}" -gt "0" ] ; then
            rctl -r "jail:ioc-${fulluuid}"
        fi
    fi
}

# Soft restart
__restart_jail () {
    local name="${1}"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: ${name} not found"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local fulluuid="$(__check_name "${name}")"
    local exec_stop="$(__get_jail_prop exec_stop "${fulluuid}")"
    local exec_start="$(__get_jail_prop exec_start "${fulluuid}")"
    local jid="$(jls -j "ioc-${fulluuid}" jid)"
    local tag="$(__get_jail_prop tag "${fulluuid}")"

    echo "* Soft restarting ${fulluuid} (${tag})"
    jexec "ioc-${fulluuid}" ${exec_stop} >> \
      "${iocroot}/log/${fulluuid}-console.log" 2>&1

    if [ "${?}" -ne "1" ] ; then
        pkill -j "${jid}"
        jexec "ioc-${fulluuid}" ${exec_start} >> \
          "${iocroot}/log/${fulluuid}-console.log" 2>&1
        zfs set org.freebsd.iocage:last_started="$(date "+%F_%T")" "${dataset}"
    else
        echo "  ERROR: soft restart failed.."
        exit 1
    fi
}

__runtime () {
    local name="${1}"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: ${name} not found"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local fulluuid="$(__check_name "${name}")"

    local state="$(jls -n -j "ioc-${fulluuid}" | wc -l | sed -e 's/^  *//' \
              | cut -d' ' -f1)"

    if [ "${state}" -eq "1" ] ; then
        local params="$(jls -nj "ioc-${fulluuid}")"
        for i in ${params} ; do
            echo "  ${i}"
        done
    else
        echo " ERROR: jail ${fulluuid} is not up.."
    fi
}
