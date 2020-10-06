FROM        debian:buster

RUN         apt update && \
            DEBIAN_FRONTEND=noninteractive apt install -y samba krb5-user \
                winbind libpam-winbind libnss-winbind \
                ldb-tools acl less vim-tiny && \
            touch /tmp/holding_stone

COPY        sinad /usr/local/bin/
COPY        nsswitch.conf /etc/

ENTRYPOINT  ["sinad"]
CMD         ["--run"]
