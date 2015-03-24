Upgrading jails
===============

Upgrades are handled with the freebsd-update(8) utility.
By default the upgrade command will try to upgrade the jail
to the hosts RELEASE version (uname -r).

Based on the jail "type" property, upgrades are handled differently
for standard jails and basejails.

**To upgrade a normal jail (non basejail) to the hosts RELEASE run:**

  ``iocage upgrade UUID | TAG``

This will upgrade the jail to the same RELEASE as the host.

To upgrade to a specific release run:

  ``iocage upgrade UUID|TAG release=10.1-RELEASE``

**To upgrade a basejail:**

Verify whether the jail is a basejail:

  ``iocage get type UUID|TAG``

Should return type "basejail".

  ``iocage set release=10.1-RELEASE UUID|TAG``

This will cause the jail to re-clone its filesystems from 10.1-RELEASE on next jail start.
Also the upgrade can be forced while the jail is online with executing:

  ``iocage upgrade UUID|TAG``

This will forcibly re-clone the basejail filesystems while the jail is running (no downtime).
