Migrating from ezjails to iocage
#jailname is the jail name on ezjails
pkg install iocage
iocage fetch
#(checked 10.1-RELEASE)
#re0 is the network adapter. 192.168.1.3/24 the ip of the jailname@ezjail
iocage create tag=jailname ip4_addr="lo1|127.0.1.1,re0|192.168.1.3/24"
#iocage list lists the newly created iocage jail and the old ezjail
iocage set host_hostname=jailname UUID/TAG
iocage set boot=on UUID/TAG
#had these options on /usr/local/etc/ezjail/jailname. If you are migrating from one box to another inside the archive there is a #prop* file which includes the jail configuration We can extract it
tar -xzvf jailname-201507062224.48.tar.gz -C /iocage/jails/UUID/root/ -s /ezjail// --include 'prop*'
#copying the directories from jailname on ezjail to the jail on iocage
#we have to stop the jail cause we dont shadow copy
#an iocage list will give us the UUID which is something like dda0b520-c500-11e4-9bc4-00259094119

#we extract all the directories except the /var/
pax -rznv -f jailname-201507062224.48.tar.gz -pop -s '=^ezjail/=/iocage/jails/UUID/root/=' ezjail/.profile ezjail/.cshrc ezjail/root ezjail/etc ezjail/tmp ezjail/home ezjail/usr/home ezjail/usr/local

#we extract all the contents from the /var/ except the /var/ports/. If you want the distfiles you change the ezjail/var/ports to #ezjail/var/ports/basejail
pax -rzvn -f jailname-201507062224.48.tar.gz -s '=^ezjail/=/iocage/jails/UUID/root/=' -pop -c ezjail/proc ezjail/basejail ezjail/dev ezjail/media ezjail/mnt ezjail/root ezjail/tmp ezjail/usr ezjail/var/ports ezjail/etc ezjail/libexec ezjail/sys ezjail/bin ezjail/lib ezjail/rescue ezjail/sbin ezjail/boot ezjail/.cshrc ezjail/.profile '*rnd*' ezjail/COPYRIGHT
