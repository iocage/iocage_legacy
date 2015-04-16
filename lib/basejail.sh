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

__create_basejail () {
    local release
    release="${1}"
    local fs_list
    fs_list="bin
                   boot
                   lib
                   libexec
                   rescue
                   sbin
                   usr
                   usr/bin
                   usr/include
                   usr/lib
                   usr/libexec
                   usr/sbin
                   usr/share
                   usr/src
                   usr/libdata
                   usr/lib32"

    echo ""
    echo "Creating basejail ZFS datasets... please wait."

    for fs in ${fs_list} ; do
        zfs create -o compression=lz4 -p "${pool}/iocage/base/${release}/root/${fs}"
    done
}

__reclone_basejail () {
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

    if [ "$dataset" == "multiple" ] ; then
        echo "  ERROR: multiple matching UUIDs!"
        exit 1
    fi

    local fulluuid
    fulluuid="$(__check_name "${name}")"
    local jail_release
    jail_release="$(__get_jail_prop release "${fulluuid}")"

    zfs destroy -rRf "${pool}/iocage/base@${fulluuid}"
    zfs snapshot -r  "${pool}/iocage/base@${fulluuid}"

    echo "* ${fulluuid} is a basejail, re-cloning jail.."

    # Re-clone required filesystems
    for fs in $bfs_list ; do
        # echo "  re-cloning: $pool/iocage/jails/$fulluuid/root/$fs"
        zfs clone "${pool}/iocage/base/${jail_release}/root/${fs}@${fulluuid}" \
                  "${pool}/iocage/jails/${fulluuid}/root/${fs}"
    done
}
