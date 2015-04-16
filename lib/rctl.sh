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

__rctl_limits () {
    local name="${1}"
    local failed=0

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

    local rlimits="$(__get_jail_prop rlimits "${fulluuid}")"

    if [ "${rlimits}" == "on" ] ; then
        echo -n "  + Applying resource limits"
        for prop in ${CONF_RCTL} ; do
            value="$(__get_jail_prop "${prop}" "${fulluuid}")"
            limit=$(echo "${value}" | awk 'BEGIN { FS = ":" } ; { print $1 }')
            action=$(echo "${value}" | awk 'BEGIN { FS = ":" } ; { print $2 }')

            if [ "${limit}" == "off" ] ; then
                continue
            else
                if [ -z "${limit}" ] || [ -z "${action}" ] ; then
                    echo -n "  ERROR: incorrect resource limit: ${limit} action: "
                    echo "${action} for property: ${prop}"
                    echo "  HINT : check man page for syntax."
                else
                    rctl -a "jail:ioc-${fulluuid}:${prop}:${action}=${limit}"
                    if [ "${?}" -eq 1 ] ; then
                        echo "    FAILED to apply ${prop}=${action}:${limit}"
                        failed=1
                    fi
                fi
            fi
        done
        if [ "${failed}" -ne 1 ] ; then
            echo " OK"
        fi
    fi
}

__rctl_list () {
    local name="${1}"

    if [ -z "${name}" ] ; then
        echo "* All active limits:"
        rctl | grep jail
    else
        local fulluuid="$(__check_name "${name}")"
        local jid="$(jls -j "ioc-${fulluuid}" jid)"
        local limits="$(rctl -h | grep "${fulluuid}")"

        echo "* Active limits for jail: ${fulluuid}"

        for i in ${limits} ; do
            limit=$(echo "${i}" | cut -f 3,4 -d:)
            echo "  - ${limit}"
        done

        if [ ! -z "${jid}" ] ; then
            echo "* CPU set: $(cpuset -g -j "${jid}" | cut -f2 -d:)"
        fi
    fi
}

__rctl_uncap () {
    local name="${1}"

    if [ -z "${name}" ] ; then
        echo "  ERROR: missing UUID"
        exit 1
    fi

    local fulluuid="$(__check_name "${name}")"

    echo "  Releasing resource limits.."
    rctl -r "jail:ioc-${fulluuid}"
    echo "  Listing active rules for jail:"
    rctl | grep "${fulluuid}"
}


__rctl_used () {
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

    echo "Consumed resources:"
    echo "-------------------"
    rctl -hu "jail:ioc-${fulluuid}"
}
