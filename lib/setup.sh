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

__jail_rc_conf () {
cat << EOT

cron_flags="${cron_flags} -J 15"

# Disable Sendmail by default
sendmail_enable="NONE"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"

# Run secure syslog
syslogd_flags="-c -ss"

# Enable IPv6
ipv6_activate_all_interfaces="YES"
EOT
}

# This is mostly for pkg autoinstall
__resolv_conf () {
    cat /etc/resolv.conf
}

# search for executable prestart|poststart|prestop|poststop in jail_dir first,
# else use jail exec_<type> property unchanged
__findscript () {
    local name="${1}"
    # type should be one of prestart|poststart|prestop|poststop
    local type="${2}"
    local jail_path="$(__get_jail_prop mountpoint "${name}")"

    if [ -x "${jail_path}/${type}" ]; then
        echo "${jail_path}/${type}"
    else
        echo "$(__get_jail_prop "exec_${type}" "${name}")"
    fi
}
