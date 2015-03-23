Updating jails
==============

Updates are handled with the freebsd-update(8) utility. Jails can be updated
while they are stopped or running. 

**To update a jail to latest patch level run:**

  ``iocage update UUID | TAG``

This will create a back-out snapshot of the jail automatically.

**When finished with updating and the jail is working OK, simply remove the
snapshot:**

  ``iocage snapremove UUID|TAG@snapshotname``

**In case the update breaks the jail, simply revert back to the snapshot:**

  ``iocage rollback UUID|TAG@snapshotname``

If you'd like to test updating without affecting a jail, create a clone and
update the clone the same way as outlined above.

**To clone run:**

  ``iocage clone UUID|TAG tag=testupdate``

