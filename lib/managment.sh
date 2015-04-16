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

# This creates jails----------------------------------------------------
__create_jail () {
    local installed=$(zfs list -r "${pool}/iocage/releases"|grep "${release}")

    if [ -z "${installed}" ] ; then
        echo "Release ${release} not found locally, run fetch first"
        exit 1
    fi

    if [ "${2}" = "-c" ] ; then
        fs_list=$(zfs list -rH -o name "${pool}/iocage/releases/${release}")

        zfs snapshot -r "${pool}/iocage/releases/${release}@${uuid}"
        for fs in $fs_list ; do
            cfs="$(echo "$fs" | sed "s#/releases/${release}#/jails/${uuid}#g")"
            #echo "cloning $fs into $cfs"
            zfs clone "${fs}@${uuid}" "${cfs}"
        done
    elif [ "${2}" = "-e" ] ; then
        zfs create -o compression=lz4 -p "${pool}/iocage/jails/${uuid}/root"
    elif [ "${2}" = "-b" ] ; then
       export type=basejail
       zfs snapshot -r "${pool}/iocage/base@${uuid}"
       zfs create -o compression=lz4 -p "${pool}/iocage/jails/${uuid}/root/usr"

       for fs in $bfs_list ; do
           zfs clone -o compression=lz4 -o readonly=on \
           "${pool}/iocage/base/${release}/root/${fs}@${uuid}" \
           "${pool}/iocage/jails/${uuid}/root/${fs}"
       done

       for dir in $bdir_list ; do
           cp -a "${iocroot}/base/${release}/root/${dir}" \
                 "${iocroot}/jails/${uuid}/root/${dir}"
       done

    else
        zfs snapshot -r "${pool}/iocage/releases/${release}@${uuid}"
        zfs send     -R "${pool}/iocage/releases/${release}@${uuid}" | \
        zfs recv        "${pool}/iocage/jails/${uuid}"
        zfs destroy  -r "${pool}/iocage/releases/${release}@${uuid}"
        zfs destroy  -r "${pool}/iocage/jails/${uuid}@${uuid}"
    fi

    __configure_jail "${pool}/iocage/jails/${uuid}"
    touch "${iocroot}/jails/${uuid}/fstab"

    # at create time set the default rc.conf
    if [ "${2}" != "-e" ] ; then
        echo "hostname=\"${hostname}\"" > "${iocroot}/jails/${uuid}/root/etc/rc.conf"
        __jail_rc_conf >> \
        "${iocroot}/jails/${uuid}/root/etc/rc.conf"
        __resolv_conf > "${iocroot}/jails/${uuid}/root/etc/resolv.conf"
    elif [ "${2}" = "-e" ] ; then
        echo "${uuid}"
    fi

    zfs create -o compression=lz4 "${pool}/$jail_zfs_dataset"
    zfs set mountpoint=none "${pool}/$jail_zfs_dataset"
    zfs set jailed=on "${pool}/$jail_zfs_dataset"

    # Install extra packages
    # this requires working resolv.conf in jail
    if [ "${pkglist}" != "none" ] ; then
        __pkg_install "${iocroot}/jails/${uuid}/root"
    fi
}

# Cloning jails ----------------------------------------------------------
__clone_jail () {
    local name="$(echo "${1}" |  awk 'BEGIN { FS = "@" } ; { print $1 }')"
    local snapshot="$(echo "${1}" |  awk 'BEGIN { FS = "@" } ; { print $2 }')"

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

    local fs_list="$(zfs list -rH -o name "${dataset}")"

    if [ -z "$snapshot" ] ; then
        zfs snapshot -r "${dataset}@${uuid}"
        for fs in $fs_list ; do
            cfs="$(echo "${fs}" | sed "s#${dataset}#${pool}/iocage/jails/${uuid}#g")"
            zfs clone "${fs}@${uuid}" "${cfs}"
        done
    else
        for fs in $fs_list ; do
            cfs="$(echo "${fs}" | sed "s#${dataset}#${pool}/iocage/jails/${uuid}#g")"
            zfs clone "${fs}@${snapshot}" "${cfs}"
        done
    fi

    __configure_jail "${pool}/iocage/jails/${uuid}"
    mv "${iocroot}/jails/${uuid}/fstab" "${iocroot}/jails/${uuid}/fstab.${name}"
    touch "${iocroot}/jails/${uuid}/fstab"

    cat "${iocroot}/jails/${uuid}/root/etc/rc.conf" | \
    sed -E "s/[a-zA-Z0-9]{8,}-.*-.*-.*-[a-zA-Z0-9]{12,}/${uuid}/g" \
    > "${iocroot}/jails/${uuid}/rc.conf"

    mv "${iocroot}/jails/${uuid}/rc.conf" \
    "${iocroot}/jails/${uuid}/root/etc/rc.conf"
}

# Destroy jails --------------------------------------------------------------
__destroy_jail () {
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

    local origin="$(zfs get -H -o value origin "${dataset}")"
    local fulluuid="$(__check_name "${name}")"
    local jail_path="$(__get_jail_prop mountpoint "${fulluuid}")"
    local state="$(jls | grep "${jail_path}" | wc -l | sed -e 's/^  *//' \
              | cut -d' ' -f1)"
    local jail_type="$(__get_jail_prop type "${fulluuid}")"
    local jail_release="$(__get_jail_prop release "${fulluuid}")"

    echo " "
    echo "  WARNING: this will destroy jail ${fulluuid}"
    echo "  Dataset: ${dataset}"
    echo " "
    echo -n "  Are you sure ? Y[n]: "
    read answer

    if [ "${answer}" == "Y" ]; then
        if [ "${state}" -lt "1" ] ; then
            echo "  Destroying: ${fulluuid}"

            __unlink_tag "${dataset}"

            zfs destroy -fr "${dataset}"

            if [ "${origin}" != "-" ] ; then
                echo "  Destroying clone origin: ${origin}"
                zfs destroy -r "${origin}"
            fi

            if [ "${jail_type}" == "basejail" ] ; then
                zfs destroy -fr "${pool}/iocage/base/${jail_release}@${fulluuid}"
            fi

        elif [ "${state}" -eq "1" ] ; then
            echo "  ERROR: Jail is up and running ..exiting"
            exit 1
        fi
   else
       echo "  Command not confirmed.  No action taken."
   fi

}

# Configure properties -------------------------------------------------
__configure_jail () {
    local CONF="${CONF_NET}
                ${CONF_JAIL}
                ${CONF_RCTL}
                ${CONF_CUSTOM}
                ${CONF_SYNC}"

    echo "Configuring jail.."
    for prop in ${CONF} ; do
        prop_name="${prop}"
        eval prop="\$${prop}"
        if [ ! -z "${prop}" ] ; then
            echo "** ${prop_name}=${prop}"
            zfs set org.freebsd.iocage:"${prop_name}=${prop}" "${1}"
            if [ "${prop_name}" == "tag" ] ; then
                __link_tag "${1}"
            fi
        fi
    done

    for prop in ${CONF_ZFS} ; do
        prop_name="${prop}"
        eval prop="\$${prop}"
        if [ ! -z "${prop}" ] && [ "${prop}" != "readonly" ] ; then
            zfs set "${prop_name}=${prop}" "${1}"
        fi
    done
}
