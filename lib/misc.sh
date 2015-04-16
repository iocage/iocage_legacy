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

__record () {
    local name="${2}"
    local action="${1}"

    if [ -z "${action}" ] ; then
        echo "  ERROR: missing action or UUID"
        exit 1
    fi

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing action or UUID"
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
    local union_mount="$(mount -t unionfs | grep "$fulluuid" | wc -l | \
                        sed -e 's/^  *//' | cut -d' ' -f1)"
    if [ ! -d "${mountpoint}/recorded" ] ; then
        mkdir "${mountpoint}/recorded"
    fi


    if [ "${action}" == "start" ] ; then
        echo "* Recording to: ${mountpoint}/recorded"

        if [ "${union_mount}" -lt 1 ] ; then
            mount -t unionfs -o noatime,copymode=transparent \
            "${mountpoint}/recorded/" "${mountpoint}/root"
        fi

    elif [ "${action}" == "stop" ] ; then
        umount -ft unionfs "${iocroot}/jails/${fulluuid}/root" > /dev/null 2>&1
        echo "* Stopped recording to: ${mountpoint}/recorded"

        find "${mountpoint}/recorded/" -type d -empty -exec rm -rf {} \; \
        > /dev/null 2>&1
        find "${mountpoint}/recorded/" -type f -size 0 -exec rm -f {} \; \
        > /dev/null 2>&1
        find "${mountpoint}/recorded/" -name "utx.*" -exec rm -f {} \; \
        > /dev/null 2>&1
        find "${mountpoint}/recorded/" -name .history -exec rm -f {} \; \
        > /dev/null 2>&1
    fi
}
