Automatic package installation
------------------------------

Packages can be installed automatically at creation time!

Use the ``pkglist`` property at creation time which should point to a text file
containing one package name per line. Please note you need to have Internet
connection for this to work as pkg install will try to get the packages from
online repos.

Example:

Create a pkgs.txt file and add package names to it.

``pkgs.txt``:

        nginx
        tmux

Now create a jail and supply the pkgs.txt file:

``iocage create pkglist=/path-to/pkgs.txt tag=myjail``

This will install nginx and tmux in the new jail.
