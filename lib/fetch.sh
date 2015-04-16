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

# Fetch release and prepare base ZFS filesystems-----------
__fetch_release () {
    local exist="$(zfs list | grep -w "^${pool}/iocage")"
    __print_release
    echo -n "Please select a release [${release}]: "
    read answer
    if [ ! -z "$answer" ] ; then
        release="${answer}"
    else
        answer="${release}"
    fi

    for rel in ${supported} ; do
        if [ "${answer}" == "${rel}" ] ; then
            release="${rel}"
            match="1"
            break
        fi
    done

    if [ -z "${match}" ] ; then
        echo "Invalid release ${release} specified, exiting.."
        exit 1
    fi

    local exist="$(zfs list | grep -w "^${pool}/iocage")"
    local download_exist="$(zfs list | grep -w "^${pool}/iocage/download/${release}")"
    local rel_exist="$(zfs list | grep -w "^${pool}/iocage/releases/${release}")"

    if [ -z "${exist}" ] ; then
        zfs create -o compression=lz4 "${pool}/iocage"
        zfs set mountpoint="${iocroot}" "${pool}/iocage"
        zfs create -o compression=lz4 "${pool}/iocage/jails"
        zfs mount -a
    fi

    if [ -z "${download_exist}" ] ; then
        zfs create -o compression=lz4 -p "${pool}/iocage/download/${release}"
    fi

    ftpdir="/pub/FreeBSD/releases/amd64/${release}"

    cd "${iocroot}/download/${release}"
    for file in ${ftpfiles} ; do
        if [ ! -e "${file}" ] ; then
            fetch "http://${ftphost}${ftpdir}/${file}"
        fi
    done

    if [ -z "${rel_exist}" ] ; then
        zfs create -o compression=lz4 -p "${pool}/iocage/releases/${release}/root"
    fi

    for file in ${ftpfiles} ; do
        if [ -e "${file}" ] ; then
            echo "Extracting: ${file}"
            chflags -R noschg "${iocroot}/releases/${release}/root"
            tar -C "${iocroot}/releases/${release}/root" -xf "${file}"
        fi
    done

        echo "* Updating base jail.."
        sleep 2

        env UNAME_r="${release}" /usr/sbin/freebsd-update \
            -b "${iocroot}/releases/${release}/root" \
            -d "${iocroot}/releases/${release}/root/var/db/freebsd-update/" fetch
        env UNAME_r="${release}" /usr/sbin/freebsd-update \
            -b "${iocroot}/releases/${release}/root" \
            -d "${iocroot}/releases/${release}/root/var/db/freebsd-update/" install

    if [ ! -d "${iocroot}/log" ] ; then
        mkdir "${iocroot}/log"
    fi

    __create_basejail "${release}"
    chflags -R noschg "${iocroot}/base/${release}/root"
    tar --exclude \.zfs --exclude usr/sbin/chown -C "${iocroot}/releases/${release}/root" -cf - . | \

    if [ ! -e "${iocroot}/base/${release}/root/usr/sbin/chown" ] ; then
       cd "${iocroot}/base/${release}/root/usr/sbin" && ln -s ../bin/chgrp chown
    fi

    etcupdate extract -D "${iocroot}/base/${release}/root" \
    -s "${iocroot}/base/${release}/root/usr/src"
}

__update () {
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

    local mountpoint="$(__get_jail_prop mountpoint "${fulluuid}")"
    local date="$(date "+%F_%T")"
    local jail_type="$(__get_jail_prop type "${fulluuid}")"
    local jail_release="$(__get_jail_prop release "${fulluuid}")"

    if [ "${jail_type}" == "basejail" ] ; then
        # Re-clone required filesystems
        __reclone_basejail "${name}"
    else
        echo "* creating back-out snapshot.."
        __snapshot "${fulluuid}@ioc-update_${date}"

        echo "* Updating jail.."
        env UNAME_r="${release}" /usr/sbin/freebsd-update \
            -b "${mountpoint}/root" \
            -d "${mountpoint}/root/var/db/freebsd-update/" fetch
        env UNAME_r="${release}" /usr/sbin/freebsd-update \
            -b "${mountpoint}/root" \
            -d "${mountpoint}/root/var/db/freebsd-update/" install

        echo " "
        echo "* Once finished don't forget to remove the snapshot!"
    fi
}

__upgrade () {
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

    if [ ! -d "${iocroot}/download/${release}" ] ; then
        echo "  ERROR: ${release} not found."
        echo "  Please run iocage fetch first."
	exit 1
    fi

    local fulluuid="$(__check_name "${name}")"
    local jail_type="$(__get_jail_prop type "${fulluuid}")"
    local jail_release="$(__get_jail_prop release "${fulluuid}")"
    local mountpoint="$(__get_jail_prop mountpoint "${fulluuid}")"
    local date="$(date "+%F_%T")"
    local oldrelease="$(zfs get -H -o value org.freebsd.iocage:release "${dataset}")"

    if [ "${jail_type}" == "basejail" ] ; then
        zfs set org.freebsd.iocage:release="${release}" "${dataset}"
        # Re-clone required filesystems
        __reclone_basejail "${name}"
        cp -Rp "${mountpoint}/root/etc" "${mountpoint}/root/etc.old"
        etcupdate -D "${mountpoint}/root" -F \
        -s "${iocroot}/base/${release}/root/usr/src"
        chroot "${mountpoint}/root" /bin/sh -c "newaliases"

    if [ "${?}" -eq 0 ] ; then
        echo ""
        echo "  Upgrade successful. Please restart jail and inspect. Remove ${mountpoint}/root/etc.old if everything is OK."
        exit 0
    else
        echo ""
        echo "  Mergemaster failed! Backing out."
	zfs set org.freebsd.iocage:release="${oldrelease}" "${dataset}"
	rm -rf "${mountpoint}/root/etc"
	mv "${mountpoint}/root/etc.old" "${mountpoint}/root/etc"
        exit 1
      fi
    fi

    echo "* creating back-out snapshot.."
    __snapshot "${fulluuid}@ioc-upgrade_${date}"

    echo "* Upgrading jail.."

    env UNAME_r="${oldrelease}" /usr/sbin/freebsd-update \
    -b "${mountpoint}/root" \
    -d "${mountpoint}/root/var/db/freebsd-update/" \
    -r "${release}" upgrade

    if [ "${?}" -eq 0 ] ; then
        while [ "${?}" -eq 0 ] ; do
        env UNAME_r="${oldrelease}" /usr/sbin/freebsd-update \
        -b "${mountpoint}/root" \
        -d "${mountpoint}/root/var/db/freebsd-update/" \
        -r "${release}" install
    done

    # Set jail's zfs property to new release
    zfs set org.freebsd.iocage:release="${release}" "${dataset}"
    else
       echo "  Upgrade failed, aborting install."
       exit 1
    fi

    echo " "
    echo "* Once finished don't forget to remove the snapshot!"
}
