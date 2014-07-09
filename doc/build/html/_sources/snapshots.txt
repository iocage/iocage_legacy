Snapshot management
===================

**You can create ZFS snapshots for your jails!**

iocage supports transparent ZFS snapshot management out of the box.
Snapshots are point-in-time copies of data, a safety point to which a jail can be reverted at any time. Initially snapshots take up almost no space as only changing data is recorded.

**You can list snapshots anytime for a jail with:**
 
  ``iocage snaplist UUID``

**To create a new snapshot run:**

  ``iocage snapshot UUID`` 

  This will create a snapshot based on current time.
  If you'd like to create a snapshot with custom naming run: 

  ``iocage snapshot UUID@mysnapshotname``

**To remove a snapshot use:**

  ``iocage snapremove UUID@snapshotname``

**To revert a jail's state to a snapshot run:**

  ``iocage rollback UUID@snapshotname``

Simple as that - don't need to know ZFS internals!
