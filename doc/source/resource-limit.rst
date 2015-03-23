Resource limiting
=================

iocage can enable optional resource limits for a jail. The outlined procedure should provide enough for a decent starting point.

**Limit jail to a single hardware thread or core (CPU affinity).**

1. pin jail to a single thread or core number 1 ``iocage set cpuset=1 UUID | TAG``
2. start jail ``iocage start UUID | TAG``
3. list applied limits ``iocage limits UUID | TAG``, you should see ``CPU affinity:  1``, jail is only allowed to run on core/thread number 1.

**Limit RSS memory use** (can be done on-the-fly)

1. limit to 4G DRAM memory use ``iocage set memoryuse=4G:deny UUID | TAG``
2. turn on resource limiting for jail ``iocage set rlimits=on UUID | TAG``
3. apply limit on-the-fly ``iocage cap UUID | TAG``
4. check active limits ``iocage limits UUID | TAG``, should list ``jail:ioc-UUID:memoryuse:deny=4096M``

**Limit CPU execution to 20%**

1. ``iocage set pcpu=20:deny UUID | TAG``
2. ``iocage cap UUID | TAG``
3. check limits ``iocage limits UUID | TAG``
