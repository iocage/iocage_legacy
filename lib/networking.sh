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

__networking () {
    action="${1}"
    name="${2}"
    jid="$(jls -j "ioc-${name}" jid)"
    ip4="$(__get_jail_prop ip4_addr "${name}")"
    ip6="$(__get_jail_prop ip6_addr "${name}")"
    defaultgw="$(__get_jail_prop defaultrouter "${name}")"
    defaultgw6="$(__get_jail_prop defaultrouter6 "${name}")"
    nics="$(__get_jail_prop interfaces "${name}" | sed -e 's/,/ /g')"
    ip4_list="$(echo "${ip4}" | sed 's/,/ /g')"
    ip6_list="$(echo "${ip6}" | sed 's/,/ /g')"

    if [ "${action}" == "start" ] ; then
        for i in ${nics} ; do
            nic="$(echo "${i}" | cut -d':' -f1)"
            bridge="$(echo "${i}" | cut -d':' -f2)"
	          memberif="$(ifconfig "${bridge}" | grep member | head -n1 | \
             cut -d' ' -f2)"
      	    brmtu="$(ifconfig "${memberif}" | head -n1 |cut -d' ' -f6)"
            epair_a="$(ifconfig epair create)"
            epair_b="$(echo "${epair_a}" | sed 's/a$/b/')"
            ifconfig "${epair_a}" name "${nic}:${jid}" mtu "${brmtu}"
            ifconfig "${nic}:${jid}" description "associated with jail: ${name}"
            ifconfig "${epair_b}" vnet "ioc-${2}"
            jexec "ioc-${2}" ifconfig "${epair_b}" name "${nic}" mtu "${brmtu}"
            ifconfig "${bridge}" addm "${nic}:${jid}" up
            ifconfig "${nic}:${jid}" up
        done

        if [ "${ip4}" != "none" ] ; then
            for i in ${ip4_list} ; do
                iface="$(echo "${i}" | cut -d'|' -f1)"
                ip="$(echo "${i}" | cut -d'|' -f2)"
                jexec "ioc-${2}" ifconfig "${iface}" "${ip}" up
            done
        fi

        if [ "${ip6}" != "none" ] ; then
            for i in $ip6_list ; do
                iface="$(echo "${i}" | cut -d'|' -f1)"
                ip="$(echo "${i}" | cut -d'|' -f2)"
                jexec "ioc-${2}" ifconfig "${iface}" inet6 "${ip}" up
            done
        fi

        if [ "${defaultgw}" != "none" ] ; then
            jexec "ioc-${2}" route add default "${defaultgw}" > /dev/null
        fi

	if [ "$defaultgw6" != "none" ] ; then
	    jexec "ioc-${2}" route add -6 default "${defaultgw6}" >/dev/null
	fi

    elif [ "${action}" == "stop" ] ; then
        for if in ${nics} ; do
            nic="$(echo "${if}" | cut -f 1 -d:)"
            ifconfig "${nic}:${jid}" destroy
        done
    fi
}

__stop_legacy_networking () {
    name="${1}"

    ip4_addr="$(__get_jail_prop ip4_addr "${name}")"
    ip6_addr="$(__get_jail_prop ip6_addr "${name}")"

    if [ "${ip4_addr}" != "none" ] ; then
        IFS=','
        for ip in ${ip4_addr} ; do
            iface="$(echo "${ip}" | cut -d'|' -f1)"
            ip4="$(echo "${ip}" | cut -d'|' -f2 | cut -d'/' -f1)"
            ifconfig "${iface}" "${ip4}" -alias
        done
    fi

    if [ "${ip6_addr}" != "none" ] ; then
        IFS=','
        for ip6 in ${ip6_addr} ; do
            iface="$(echo "${ip6}" | cut -d'|' -f1)"
            ip6="$(echo "${ip6}" | cut -d'|' -f2 | cut -d'/' -f1)"
            ifconfig "${iface}" inet6 "${ip6}" -alias
        done
    fi
}
