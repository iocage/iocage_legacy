Thin provision or thick provision?
==================================

iocage supports two provisioning types, thick (default) and thin. Thin is basically a ZFS clone of the base jail. If you plan to replicate the jail over the network with ZFS send/receive use the default thick provisioning! This will create a fully independent jail copy which can be sent over the network with ZFS send/receive.  

**Create a normal jail**

  ``iocage create tag=myjail`` or just ``iocage create``

**Create a thin jail**

  ``iocage create -c tag=myjail``

