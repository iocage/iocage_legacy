#
#	Makefile
#

PREFIX?= /usr/local

MAN=
BINDIR=$(PREFIX)/sbin
FILESDIR=$(PREFIX)/lib/iocage
RCDIR=$(PREFIX)/etc/rc.d
MANDIR=$(PREFIX)/man/man8
MKDIR=mkdir

PROG=	iocage
SCRIPTS=iocage
SCRIPTSDIR=${PREFIX}/BINDIR
MAN=	$(PROG).8

${PROG}:
	@echo Nothing needs to be done for iocage.

install:
	$(MKDIR) -p $(BINDIR)
	$(MKDIR) -p $(FILESDIR)
	$(INSTALL) -c -m $(BINMODE) ${.OBJDIR}/$(PROG) $(BINDIR)/
	$(INSTALL) -c ${.OBJDIR}/lib/* $(FILESDIR)/
	$(INSTALL) -c ${.OBJDIR}/rc.d/* $(RCDIR)/
	$(INSTALL) -c $(MAN).gz $(MANDIR)/

.include <bsd.prog.mk>
