#!/bin/bash

set -e -o pipefail

execute_sinad () {
    samba-tool $@
}
clear_holding_stone () {
    # remove config stone.
    rm -f /tmp/hold_to_run
}
provision_sinad () {
    mv /etc/krb5.conf /etc/krb5.conf.orig
    mv /etc/samba/smb.conf /etc/samba/smb.conf.orig
    samba-tool domain provision --use-rfc2307 --interactive
    cp /var/lib/samba/private/krb5.conf /etc/
    # Add some lines to smb.conf
    cat <<EOF > /tmp/smb.tmp
        # added
        template shell = /bin/bash
        winbind use default domain = true
        winbind offline logon = false
        winbind nss info = rfc2307
        winbind enum users = yes
        winbind enum groups = yes
EOF
    sed -Ei '/idmap_ldb:/r /tmp/smb.tmp' /etc/samba/smb.conf
    if [ -f /var/run/samba/samba.pid ]
    then
        /bin/kill -HUP $(cat /var/run/samba/samba.pid)
    fi
    # remove stone.
    clear_holding_stone
    # Change /etc/resolv.conf
    # get IP address of me.
    IP=$(hostname -i)
    # Get DOMAIN of me
    while :
    do
        if ps x |grep samba |grep -qv grep
        then
            DOMAIN=$(samba-tool domain info $IP |grep Domain|cut -d':' -f2|tr -d ' ')
            echo -e "search $DOMAIN\nnameserver $IP" > /etc/resolv.conf
            break
        fi
        sleep 10
    done
}
run_sinad () {
    while :
    do
        if [ -f /tmp/hold_to_run ]
        then
            sleep 5
        else
            break
        fi
    done
    /usr/sbin/samba --foreground --no-process-group --debuglevel=5
}
status_sinad () {
    samba-tool domain level show
}
USAGE() {
    echo "Usage: $0 {-h|-p|-s}" 1>&2
    echo " "
    echo "  -h  --help          Display this help message."
    echo "  -e  --execute       Execute command."
    echo "  -p  --provision     Provision Sinad."
    echo "  -r  --run           Run Sinad."
    echo "  -s  --status        Show the status of Sinad."
}

if [ $# -lt 1 ]
then
    USAGE
    exit 0
fi

OPT=$1
shift
# Get argument
while :
do
    case "$OPT" in
        -e | --execute)
            execute_sinad $1
            break
            ;;
        -p | --provision)
            provision_sinad
            break
            ;;
        -r | --run)
            run_sinad
            break
            ;;
        -s | --status)
            status_sinad
            break
            ;;
        *)
            echo Error: unknown option: "$OPT" 1>&2
            echo " "
            USAGE
            break
            ;;
    esac
done
