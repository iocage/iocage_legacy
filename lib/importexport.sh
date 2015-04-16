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

__pkg_install () {
    local chrootdir
    chrootdir="${1}"

    if [ -e "${pkglist}" ] ; then
        echo "* Installing extra packages.."
        for i in $(cat "${pkglist}") ; do
            pkg -c "${chrootdir}" install -qy "${i}"
        done
    fi
}

__package () {
    # create package from recorded changes
    # sha256 too
    local name
    name="${1}"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local dataset
    dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: ${name} not found"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local fulluuid
    fulluuid="$(__check_name "${name}")"

    local mountpoint
    mountpoint="$(__get_jail_prop mountpoint "${fulluuid}")"

    if [ ! -d "${mountpoint}/recorded" ] ; then
        echo "  ERROR: nothing to package, missing recorded directory!"
        echo "  HINT: have you recorded the jail?"
        exit 1
    fi

    if [ ! -d "${iocroot}/packages" ] ; then
        mkdir "${iocroot}/packages"
    fi

    echo "* Creating package..."
    tar -cvJf "${iocroot}/packages/${fulluuid}.tar.xz" -C "${mountpoint}/recorded" . && \
    sha256 -q "${iocroot}/packages/${fulluuid}.tar.xz" > "${iocroot}/packages/${fulluuid}.sha256"
    echo "* Package saved to: ${iocroot}/packages/${fulluuid}.tar.xz"
    echo "* Checksum created: ${iocroot}/packages/${fulluuid}.sha256"
}

__import () {
    local name
    name="${1}"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing package UUID"
        exit 1
    fi

    local package
    package="$(find "${iocroot}/packages/" -name "${name}*.tar.xz")"
    local image
    image="$(find "${iocroot}/images/" -name "${name}*.tar.xz")"
    local pcount
    pcount="$(echo "$package"|wc -w | sed -e 's/^  *//' \
              | cut -d' ' -f1)"
    local icount
    icount="$(echo "$image"|wc -w | sed -e 's/^  *//' \
              | cut -d' ' -f1)"

    if [ "${pcount}" -gt 1 ] ; then
        echo "  ERROR: multiple matching packages, please narrow down UUID."
        exit 1
    elif [ "${pcount}" -eq 1 ] ; then
        local pcksum
        pcksum="$(find "${iocroot}/packages/" -name "${name}*.sha256")"
    fi

    if [ "${icount}" -gt 1 ] ; then
        echo "  ERROR: multiple matching images, please narrow down UUID."
        exit 1
    elif [ "${icount}" -eq 1 ] ; then
        local icksum
        icksum="$(find "${iocroot}/images/" -name "${name}*.sha256")"
    fi

    if [ "${pcount}" -gt 0 ] && [ "${icount}" -gt 0 ] ; then
        echo "  ERROR: same UUID is matching both a package and an image."
        exit 1
    fi

    if [ "${pcount}" -gt 0 ] ; then
        echo "* Found package ${package}"
        echo "* Importing package ${package}"

        if [ ! -f "${pcksum}" ] ; then
            echo "  ERROR: missing checksum file!"
            exit 1
        fi

        local new_cksum
        new_cksum="$(sha256 -q "${package}")"
        local old_cksum
        old_cksum="$(cat "${pcksum}")"
        local uuid
        uuid="$(__create_jail create | grep uuid | cut -f2 -d=)"
        local mountpoint
        mountpoint="$(__get_jail_prop mountpoint "${uuid}")"

        if [ "${new_cksum}" != "${old_cksum}" ] ; then
            echo "  ERROR: checksum mismatch ..exiting"
            exit 1
        else
            tar -xvJf "${package}" -C "${mountpoint}/root"
        fi

    elif [ "${icount}" -gt 0 ] ; then
        echo "* Found image ${image}"
        echo "* Importing image ${image}"

        if [ ! -f "${icksum}" ] ; then
            echo "  ERROR: missing checksum file!"
            exit 1
        fi

        local new_cksum
        new_cksum="$(sha256 -q "${image}")"
        local old_cksum
        old_cksum="$(cat "${icksum}")"
        local uuid
        uuid="$(__create_jail create -e|tail -1)"
        local mountpoint
        mountpoint="$(__get_jail_prop mountpoint "${uuid}")"

        if [ "${new_cksum}" != "${old_cksum}" ] ; then
            echo "  ERROR: checksum mismatch ..exiting"
            exit 1
        else
            tar -xvJf "${image}" -C "${mountpoint}/root"
        fi

    else
        echo "  ERROR: package or image ${name} not found!"
        exit 1
    fi

    cat "${iocroot}/jails/${uuid}/root/etc/rc.conf" | \
    sed -E "s/[a-zA-Z0-9]{8,}-.*-.*-.*-[a-zA-Z0-9]{12,}/${uuid}/g" \
    > "${iocroot}/jails/${uuid}/rc.conf"

    mv "${iocroot}/jails/${uuid}/rc.conf" \
    "${iocroot}/jails/${uuid}/root/etc/rc.conf"
}

__export () {
    # Export full jail
    # sha256
    local name
    name="${1}"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local dataset
    dataset="$(__find_jail "${name}")"

    if [ -z "${dataset}" ] ; then
        echo "  ERROR: ${name} not found"
        exit 1
    fi

    if [ "${dataset}" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local fulluuid
    fulluuid="$(__check_name "${name}")"
    local jail_path
    jail_path="$(__get_jail_prop mountpoint "${fulluuid}")"
    local state
    state="$(jls|grep "${jail_path}" | wc -l | sed -e 's/^  *//' \
              | cut -d' ' -f1)"

    if [ "${state}" -gt "0" ] ; then
        echo "  ERROR: ${fulluuid} is running!"
        echo "  Stop jail before exporting!"
        exit 1
    fi

    local mountpoint
    mountpoint="$(__get_jail_prop mountpoint "${fulluuid}")"

    if [ ! -d "${iocroot}/images" ] ; then
        mkdir "${iocroot}/images"
    fi

    echo "* Exporting ${fulluuid} .."
    tar -cvJf "${iocroot}/images/${fulluuid}.tar.xz" -C "${mountpoint}/root" . && \
    sha256 -q "${iocroot}/images/${fulluuid}.tar.xz" > "${iocroot}/images/${fulluuid}.sha256"
    echo "* Image saved to: ${iocroot}/images/${fulluuid}.tar.xz"
    echo "* Checksum created: ${iocroot}/images/${fulluuid}.sha256"

}
