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

# Export every property specified on command line ----------------------
__export_props () {
    for i in "${@}" ; do
        if [ "$(echo "${i}" | grep -e ".*=.*")" ] ; then
            export "${i}"
        fi
    done
}

# Set properties ------------------------------------------------------
__set_jail_prop () {
    name="${2}"
    property="${1}"

    if [ -z "${name}" ] || [ -z "${property}" ] ; then
        echo "  ERROR: missing property or UUID"
        exit 1
    fi

    dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: ${name} not found"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    pname="$(echo "${property}"|awk 'BEGIN { FS = "=" } ; { print $1 }')"
    pval="$(echo "${property}"|awk 'BEGIN { FS = "=" } ; { print $2 }')"

    if [ -z "${pname}" ] || [ -z "${pval}" ] ; then
        echo "  ERROR: set failed, incorrect property syntax!"
        exit 1
    fi

    found="0"

    CONF="${CONF_NET}
                ${CONF_JAIL}
                ${CONF_RCTL}
                ${CONF_CUSTOM}
                ${CONF_SYNC}"

    for prop in ${CONF} ; do
        if [ "${prop}" == "${pname}" ] ; then
            found=1
            zfs set org.freebsd.iocage:"${prop}=${pval}" "${dataset}"
            if [ "${pname}" == "tag" ] ; then
                __unlink_tag "${dataset}"
                __link_tag "${dataset}"
            fi
        fi
    done

    for prop in ${CONF_ZFS} ; do
        if [ "${prop}" == "${pname}" ] ; then
            zfs set "${prop}=${pval}" "${dataset}"
            found=1
        fi
    done

    if [ "${found}" -ne "1" ] ; then
        echo "  ERROR: unsupported property: ${pname} !"
        exit 1
    fi
}

# Get properties -----------------------------------------------------
__get_jail_prop () {
    name="${2}"
    property="${1}"

    if [ -z "${property}" ] ; then
        echo "  ERROR: get failed, incorrect property syntax!"
        exit 1
    fi

    if [ -z "${name}" ] ; then
        echo "  ERROR: mising UUID!"
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

    found="0"

    CONF="${CONF_NET}
                ${CONF_JAIL}
                ${CONF_RCTL}
                ${CONF_CUSTOM}
                ${CONF_SYNC}"

    for prop in ${CONF} ; do
        if [ "${prop}" == "${property}" ] ; then
            found=1
            value="$(zfs get -H -o value org.freebsd.iocage:"${prop}" \
                         "${dataset}")"
            echo "${value}"
        elif [ "${property}" == "all" ] ; then
            found=1
            value="$(zfs get -H -o value org.freebsd.iocage:"${prop}" \
                         "${dataset}")"
            echo "${prop}:${value}"
        fi
    done

    for prop in ${CONF_ZFS} ; do
        if [ "${prop}" == "${property}" ] ; then
            found=1
            value="$(zfs get -H -o value "${prop}" "${dataset}")"
            echo "${value}"
        fi
    done

    if [ "${found}" -ne "1" ] ; then
        echo "  ERROR: unsupported property: ${property} !"
        exit 1
    fi
}

# reads tag property from given jail dataset
# creates symlink from $iocroot/tags/<tag> to $iocroot/jails/<uuid>
__link_tag () {
    dataset="${1}"

    if mountpoint="$(zfs get -H -o value mountpoint "${dataset}")" ; then
        if tag="$(zfs get -H -o value org.freebsd.iocage:tag "${dataset}")"; then
            mkdir -p "${iocroot}/tags"
            if [ ! -e "${iocroot}/tags/${tag}" ] ; then
                ln -s "${mountpoint}" "${iocroot}/tags/${tag}"
            else
                echo "  ERROR: tag already exists, can not symlink: ${tag}"
                exit 1
            fi
        fi
    else
        echo "  ERROR: no such dataset: ${dataset}"
        exit 1
    fi
}

# removes all symlinks found in $iocroot/tags pointing to the given jail dataset
__unlink_tag () {
    dataset="${1}"

    if mountpoint="$(zfs get -H -o value mountpoint "${dataset}")" ; then
        find "${iocroot}/tags" -type l -lname "${mountpoint}*" -exec rm -f \{\} \;
    fi
}
