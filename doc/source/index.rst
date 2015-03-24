.. iocage documentation master file, created by
   sphinx-quickstart on Wed Jul  9 10:19:09 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

=============================
iocage - FreeBSD jail manager
=============================

iocage is a zero dependency drop in jail/container manager amalgamating some
of the best features and technologies FreeBSD operating system has to offer.
It is geared for ease of use with a simple and easy to understand command
syntax.

**FEATURES:**

- rapid thin provisioning (within seconds!)

- templating

- base jails

- automatic package installation

- ease of use (also supports shortened UUIDs)

- zero configuration files

- virtual networking stacks (vnet)

- shared IP based jails (non vnet)

- fully writable clones

- resource limits (CPU, MEMORY, etc.)

- filesystem quotas and reservations

- ZFS jailing inside jails

- transparent snapshot management

- binary updates

- differential jail packaging

- export and import

- and many more!


Documentation:
--------------

.. toctree::
   :maxdepth: 2

   faq
   pre-flight-checklist
   best-practices
   using-uuids
   auto-boot
   automatic-package-installation
   configure-interfaces
   shared-ip
   help-no-internet
   jail-package
   clones
   destroy
   templates
   resource-limit
   snapshots
   thin-thick
   updating
   real-world
   debian

Indices and tables
==================
 
 * :ref:`genindex`
 * :ref:`modindex`
 * :ref:`search`

