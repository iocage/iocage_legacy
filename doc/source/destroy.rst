Destroying jails
================

Destroy any jail with ``iocage destroy UUID | TAG``

**Warning this will irreversibly destroy the jail!**

**Example:**

     ::

        iocage destroy acfb86bf-0001-11e4-a88a-3c970ea3222f

        WARNING: this will destroy jail acfb86bf-0001-11e4-a88a-3c970ea3222f
        Dataset: zroot/iocage/jails/acfb86bf-0001-11e4-a88a-3c970ea3222f

        Are you sure ? Y[n]: Y
        Destroying: acfb86bf-0001-11e4-a88a-3c970ea3222f

Please note the capital "**Y**" - issuing a lowercase "y" will do nothing. This is to prevent accidental deletion.

Always double check the jail UUID before destroying any jails!
