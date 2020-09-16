#!/bin/bash

set -e -o pipefail

execute_sinad () {
    samba-tool $@
}
clear_holding_stone () {
    # remove config stone.
    rm -f /tmp/holding_stone
}
provision_sinad () {
    mv /etc/krb5.conf /etc/krb5.conf.orig
    mv /etc/samba/smb.conf /etc/samba/smb.conf.orig
    # Get samba admin password.
    while :
    do
        read -s -p 'Type samba admin password: ' ADMINPW1
        echo
        read -s -p 'Type samba admin password again: ' ADMINPW2
        echo
        if [ x"$ADMINPW1" == x"$ADMINPW2" ]
        then
            break
        else
            echo "Passwords are not matched. Try again."
            sleep 0.5
        fi
    done
    # Get realm
    read -p 'Type realm name (eg. iorchard.lan): ' REALM
    echo
    # Get domain from realm
    DOMAIN=${REALM%.*}
    # Get Sinad host IP address.
    read -p 'Type Sinad host IP address: ' HOST_IP
    echo
    samba-tool domain provision --use-rfc2307 --realm=$REALM --domain=$DOMAIN \
        --host-name=$HOSTNAME --host-ip=$HOST_IP --adminpass=$ADMINPW1 \
        --dns-backend=SAMBA_INTERNAL --server-role=dc
    cp /var/lib/samba/private/krb5.conf /etc/
    # Create public/profiles/users folder in /srv/samba
    mkdir -p /srv/samba/{public,profiles,users}
    # Add some lines to smb.conf
    cat <<EOF > /tmp/smb.tmp
        # added
        template shell = /bin/bash
        winbind use default domain = true
        winbind offline logon = false
        winbind nss info = rfc2307
        winbind enum users = yes
        winbind enum groups = yes
[users]
	path = /srv/samba/users
	read only = no

[profiles]
	path = /srv/samba/profiles
	read only = no

EOF
    sed -Ei '/idmap_ldb:/r /tmp/smb.tmp' /etc/samba/smb.conf
    #smbcontrol all reload-config
    # remove stone.
    clear_holding_stone
    sleep 7
    # Change /etc/resolv.conf
    echo -e "search $REALM\nnameserver $HOST_IP" > /etc/resolv.conf
    # Update pam auth
    pam-auth-update --enable mkhomedir unix winbind 2>/dev/null
    # Remove ip address from DNS except $HOST_IP.
    set +e
    IP_LIST=($(hostname -I))
    for i in ${IP_LIST[*]}
    do
        if [ x"${i}" != x"${HOST_IP}" ]
        then
            samba-tool dns delete $HOSTNAME $REALM $HOSTNAME A $i -U administrator
            samba-tool dns delete $HOSTNAME $REALM $REALM A $i -U administrator
        fi
    done
    set -e
}
run_sinad () {
    while :
    do
        if [ -f /tmp/holding_stone ]
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
