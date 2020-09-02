Sinad on docker
================

Run sinad on docker container engine.

Build
-------

Build sinad container image.::

   $ docker build -t sinad .

Prepare
---------

Create two volumes.::

   $ docker volume create etc_samba
   $ docker volume create var_lib_samba

Run
----

Run sinad container with --cap-add SYS_ADMIN option.::

   $ docker run --cap-add SYS_ADMIN --detach --name sinad --hostname sinad \
      --publish-all --network=host \
      --volume etc_samba:/etc/samba --volume var_lib_samba:/var/lib/samba \   
      sinad


Provision
------------

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





