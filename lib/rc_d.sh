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

__rc_jails () {
    action="${1}"
    jails="$(__find_jail "ALL")"
    boot_list="/tmp/iocage.${$}"

    for jail in ${jails} ; do
        name="$(zfs get -H -o value org.freebsd.iocage:host_hostuuid \
                    "${jail}")"
        boot="$(zfs get -H -o value org.freebsd.iocage:boot "${jail}")"
        priority="$(zfs get -H -o value org.freebsd.iocage:priority \
                        "${jail}")"

        if [ "${boot}" == "on" ] ; then
            echo "${priority},${name}" >> "${boot_list}"
        fi
    done

    if [ -e "${boot_list}" ] ; then
        boot_order="$(sort -n "${boot_list}")"
        shutdown_order="$(sort -rn "${boot_list}")"
    else
        echo "  ERROR: None of the jails have boot on"
        exit 1
    fi

    if [ "${action}" == "boot" ] ; then
        echo "* [I|O|C] booting jails... "

        for i in ${boot_order} ; do
            jail="$(echo "${i}" | cut -f2 -d,)"
            jail_path="$(__get_jail_prop mountpoint "${jail}")"
            state="$(jls | grep "${jail_path}" | wc -l | sed -e 's/^  *//' \
                      | cut -d' ' -f1)"
            if [ "${state}" -lt "1" ] ; then
                __start_jail "${jail}"
            fi
        done

    elif [ "${action}" == "shutdown" ] ; then
        echo "* [I|O|C] shutting down jails... "

        for i in ${shutdown_order} ; do
            jail="$(echo "${i}" | cut -f2 -d,)"
            jail_path="$(__get_jail_prop mountpoint "${jail}")"
            state="$(jls | grep "${jail_path}" | wc -l | sed -e 's/^  *//' \
                      | cut -d' ' -f1)"
            if [ "${state}" -eq "1" ] ; then
                __stop_jail "${jail}"
            fi
        done

    fi

    rm "${boot_list}"
}
