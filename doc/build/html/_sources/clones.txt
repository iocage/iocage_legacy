Dealing with clones
===================

When a jail is cloned, iocage creates a ZFS clone filesystem.
In a nutshell clones are cheap lightweight writable snapshots.

A clone depends on its source snapshot and filesystem.
If you'd like to destroy the source jail and preserve its clones
you need to promote the clone first, otherwise the source jail cannot be destroyed.

**To promote a cloned jail, simply run:**

``iocage promote UUID``

The above step will reverse the clone and source jail relationship.
Basically the clone will become the source and the source jail will be demoted to a clone.

**Now you can remove the demoted jail with:**

``iocage destroy UUID``
