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
