FROM        debian:buster
COPY        sinad.sh /

RUN         apt update && \
            DEBIAN_FRONTEND=noninteractive apt install -y samba krb5-user \
                winbind libpam-winbind libnss-winbind && \
            touch /tmp/hold_to_run

EXPOSE      53 88 135 139 389 445 464 636 3268 3269
EXPOSE      53/udp 88/udp 137/udp 138/udp 389/udp 464/udp

ENTRYPOINT  ["/sinad.sh"]
CMD         ["--run"]
