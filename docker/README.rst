Sinad on docker
================

Run sinad on docker container engine.

Build
-------

Build sinad container image.::

   $ docker build -t sinad .

Prepare
---------

Create three volumes.::

   $ docker volume create etc_samba       # for samba config files
   $ docker volume create var_lib_samba   # for samba databases
   $ docker volume create srv_samba       # for samba share folders

Run
----

Run sinad container with --cap-add SYS_ADMIN option.::

   $ docker run --cap-add SYS_ADMIN --detach --name sinad --hostname sinad \
      --publish-all --network=host \
      --volume etc_samba:/etc/samba --volume var_lib_samba:/var/lib/samba \ 
      --volume srv_samba:/srv/samba \
      sinad

Put sinad command in .bash_aliases.::

   $ vi ~/.bash_aliases
   alias sinad="docker exec -it sinad sinad"
   $ source ~/.bash_aliases

Provision
------------

If this is the first time to run sinad, you need to provision it.
If you've already done it before, you do not need to provision it since
your settings are preserved in docker volumes.

Provision sinad.::

   $ sinad --provision
   Type samba admin password: <admin_password>
   Type samba admin password again: <admin_password>
   Type realm name (eg. iorchard.lan): <realm>
   Type Sinad host IP address: <host_ip>
   ...
   DOMAIN SID:            S-1-5-21-442372980-669482684-1411862968
   Remove ip addresses from DNS except <host_ip>
   Password for [IORCHARD\administrator]: <admin_password>
   Record deleted successfully
   ...
   Grant SeDiskOperatorPrivilege to BUILTIN\Administrators.
   Enter administrator's password:
   Successfully granted rights.

You may need to enter <admin_password> several times when removing ip
addresses from DNS. It depends on how many ip addresses are in Sinad host.

Status
--------

Check the status of sinad.::

   $ sinad --ping
   smbd: PONG from pid xxx
   winbindd: PONG from pid xxx


