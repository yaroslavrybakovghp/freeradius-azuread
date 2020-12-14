#!/bin/sh
set -e

PATH=/opt/sbin:/opt/bin:$PATH
export PATH

cat >> /etc/raddb/proxy.conf <<EOF
realm $AzureAdDomain {
    oauth2 {
        discovery = "https://login.microsoftonline.com/%{Realm}/v2.0"
        client_id = "$AzureAdClientId"
        client_secret = "$AzureAdSecret"
        cache_password = no
    }
}
EOF

cat >> /etc/raddb/clients.conf <<EOF
client $NASName {
    ipaddr = $NASNetwork
    secret = $NASSecret
}
EOF

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- radiusd "$@"
fi

# check for the expected command
if [ "$1" = 'radiusd' ]; then
    shift
    exec radiusd -f "$@"
fi

# debian people are likely to call "freeradius" as well, so allow that
if [ "$1" = 'freeradius' ]; then
    shift
    exec radiusd -f "$@"
fi

# else default to run whatever the user wanted like "bash" or "sh"
exec "$@"
