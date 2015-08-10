# bhyve integration

This file is used to track how to currently test iocage's bhyve integration. 
It's all still a work in progress and will change as more and more is integrated. 

**Pre-Flight Checklist**

[Taken from the FreeBSD handbook https://www.freebsd.org/doc/en/books/handbook/virtualization-host-bhyve.html]


The first step to creating a virtual machine in bhyve is configuring the host system. First, load the bhyve kernel module:

    kldload vmm
    kldload nmdm

Then, create a tap interface for the network device in the virtual machine to attach to. In order for the network device to participate in the network, also 
create a bridge interface containing the tap 
interface ane the physical interface as members. In this example, the physical interface is igb0:

    ifconfig tap0 create
    sysctl net.link.tap.up_on_open=1
        net.link.tap.up_on_open: 0 -> 1
    ifconfig bridge0 create
    ifconfig bridge0 addm igb0 addm tap0
    ifconfig bridge0 up

Once you have created tap0, there is no need to create more tap interfaces, iocage will set them up for you. 


**Create FreeBSD bhyve guest**

Fetch the desired release (more releases to come). Just select the ISO version:

Ex: 10.1-RELEASE-ISO

    iocage fetch

If you ever forget what ISO's you have already downloaded, just run:

    iocage downloads

Create a new bhyve guest and set disk size:

Note: you cannot pass custom properties via iocage create yet, you must set them after creation. 

    iocage create 8G

Set not default tap nullmodem interfaces:

    iocage set con=nmdm4 UUID | TAG
    iocage set tap=tap4 UUID | TAG

In another terminal session, prepare the console for installation. (Uses cu(1), '~~.' to terminate.)

    iocage console UUID | TAG

Start the installation in the original (host) terminal:

Note: you must enter the full UUID for now. 

    iocage installvmm FULLUUID FreeBSD-10.1-RELEASE-amd64-bootonly.iso

You can then switch back to your console terminal and run the installation

When you are finished, drop the installation to command line and run:

Again, you must use the full UUID for now.

    iocage stopvmm FULLUUID

You may now start the bhyve guest as usual using the full UUID:

    iocage startvmm FULLUUID
