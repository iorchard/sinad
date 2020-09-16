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
      sinad


Provision
------------

If this is the first time to run sinad, you need to provision the sinad.
If you've already done it before, you do not need to provision it since
your settings are preserved in docker volumes.

Provision sinad.::

   $ docker exec -it sinad /sinad.sh --provision
   Realm:  <your realm>
   Domain [<domain>]: <your domain>
   Server Role (dc, member, standalone) [dc]:
   DNS backend (SAMBA_INTERNAL, BIND9_FLATFILE, BIND9_DLZ, NONE) [SAMBA_INTERNAL]:
   DNS forwarder IP address (write 'none' to disable forwarding) [8.8.8.8]:
   Administrator password:
   Retype password:

Status
--------

Check the status of sinad.::

   $ docker exec sinad /sinad.sh --status


