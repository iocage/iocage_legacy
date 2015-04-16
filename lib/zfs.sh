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

# Find and return the jail's top level ZFS dataset
__find_jail () {
    local name="${1}"
    local jlist="/tmp/iocage-jail-list.${$}"
    local jails="$(zfs list -rH -o name "${pool}/iocage/jails" \
                 | grep -E \
              "^$pool/iocage/jails/[a-zA-Z0-9]{8,}-.*-.*-.*-[a-zA-Z0-9]{12,}$")"

    if [ "${name}" == "ALL" ] ; then
        for jail in ${jails} ; do
            echo "${jail}"
        done
    else
        for jail in $jails ; do
            found="$(echo "${jail}" |grep -iE "^${pool}/iocage/jails/${name}"|\
                    wc -l|sed -e 's/^  *//')"
            local tag="$(zfs get -H -o value org.freebsd.iocage:tag "${jail}")"

            if [ "${found}" -eq 1 ] ; then
                echo "${jail}" >> "${jlist}"
            fi

            if [ "${tag}" == "${name}" ] ; then
                echo "${jail}" >> "${jlist}"
            fi
        done

        if [ ! -e "${jlist}" ] ; then
            exit 0
        fi

        if [ "$(wc -l "${jlist}" | sed -e 's/^  *//' \
                | cut -d' ' -f1)" -eq "1" ] ; then
            cat $jlist
        elif [ "$(wc -l "${jlist}" | sed -e 's/^  *//' \
                  | cut -d' ' -f1)" -gt "1" ] ; then
            echo "multiple"
        fi
    fi

    rm  -f "${jlist}"
}

__print_disk () {
    local jails="$(__find_jail ALL)"

    printf "%-36s  %-6s  %-5s  %-5s  %-5s  %-5s\n" "UUID" "CRT" "RES" "QTA" "USE" "AVA"

    for jail in ${jails} ; do
        uuid="$(zfs get -H -o value org.freebsd.iocage:host_hostuuid "${jail}")"
        crt="$(zfs get -H -o value compressratio "${jail}")"
        res="$(zfs get -H -o value reservation "${jail}")"
        qta="$(zfs get -H -o value quota "${jail}")"
        use="$(zfs get -H -o value used "${jail}")"
        ava="$(zfs get -H -o value available "${jail}")"

        printf "%-36s  %-6s  %-5s  %-5s  %-5s  %-5s\n" "${uuid}" "${crt}" "${res}" "${qta}" \
               "${use}" "${ava}"
    done
}

__find_mypool () {
    pools="$(zpool list -H -o name)"
    found="0"

    for i in ${pools} ; do
        mypool="$(zpool get comment "${i}" | grep -v NAME | awk '{print $3}')"

        if [ "${mypool}" == "iocage" ] ; then
            export pool="${i}"
            found=1
            break
        fi
    done

    if [ "${found}" -ne 1 ] ; then
        if [ -n "${RC_PID}" ]; then
            # RC_PID set means we are running from rc
            echo "ERROR: No pool for iocage jails found on boot ..exiting"
            exit 1
        else
            echo -n "  please select a pool for iocage jails [${i}]: "
            read answer

            if [ -z "${answer}" ] ; then
                answer="${i}"
            fi

            zpool set comment=iocage "${answer}"
            export pool="${answer}"
        fi
    fi
}

__snapshot () {
    local name="$(echo "${1}" |  awk 'BEGIN { FS = "@" } ; { print $1 }')"
    local snapshot="$(echo "${1}" |  awk 'BEGIN { FS = "@" } ; { print $2 }')"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local dataset="$(__find_jail "${name}")"

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local date="$(date "+%F_%T")"

    if [ ! -z "${snapshot}" ] ; then
        zfs snapshot -r "${dataset}@${snapshot}"
    else
        zfs snapshot -r "${dataset}@ioc-${date}"
    fi
}


__snapremove () {
    local name="$(echo "${1}" |  awk 'BEGIN { FS = "@" } ; { print $1 }')"
    local snapshot="$(echo "${1}" |  awk 'BEGIN { FS = "@" } ; { print $2 }')"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: jail dataset not found"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    if [ ! -z "${snapshot}" ] ; then
        echo "* removing snapshot: ${snapshot}"
        zfs destroy -r "${dataset}@${snapshot}"
    else
        echo "  ERROR: snapshot not found"
        exit 1
    fi
}

__snaplist () {
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
    local snapshots="$(zfs list -Hrt snapshot -d1 "${dataset}" | awk '{print $1}')"

    printf "%-36s  %-21s  %s   %s\n" "NAME" "CREATED"\
            "RSIZE" "USED"

    for i in ${snapshots} ; do
        local snapname="$(echo "${i}" |cut -f 2 -d \@)"
        local creation="$(zfs get -H -o value creation "${i}")"
        local used="$(zfs get -H -o value used "${i}")"
        local referenced="$(zfs get -H -o value referenced "${i}")"

        printf "%-36s  %-21s  %s    %s\n" "${snapname}" "${creation}"\
                   "${referenced}" "${used}"
    done

}

__rollback () {
    local name="$(echo "${1}" |  awk 'BEGIN { FS = "@" } ; { print $1 }')"
    local snapshot="$(echo "${1}" |  awk 'BEGIN { FS = "@" } ; { print $2 }')"
    local dataset="$(__find_jail "${name}")"

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local fs_list="$(zfs list -rH -o name "${dataset}")"

    if [ ! -z "${snapshot}" ] ; then
        for fs in ${fs_list} ; do
            echo "* Rolling back to ${fs}@${snapshot}"
            zfs rollback -r "${fs}@${snapshot}"
        done
    fi
}


__promote () {
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

    local fs_list="$(zfs list -rH -o name "${dataset}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: dataset not found"
        exit 1
    fi

    for fs in ${fs_list} ; do
        local origin="$(zfs get -H -o value origin "${fs}")"

        if [ "${origin}" != "-" ] ; then
            echo "* promoting filesystem: ${fs}"
            zfs promote "${fs}"
            continue
        else
            echo "  INFO: filesystem ${fs} is not a clone"
        fi
    done
}
