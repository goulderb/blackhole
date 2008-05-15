include makefile.includes

help:
	@echo 'Install targets:'
	@echo 'install                    - Install blackhole, (defaults are in makefile.include. default: DESTDIR/usr).'
	@echo 'install-service-crux:      - Install CRUX services files.'
	@echo 'install-service-slackware: - Install Slackware services files.'
	@echo
	@echo	'update                     - Update blackhole, (defaults are in makefile.include. default: DESTDIR/usr)'
	@echo
	@echo 'remove:                    - Remove blackhole.'
	@echo 'remove-service-crux:       - Remove CRUX services files.'
	@echo 'remove-service-slackware:  - Remove Slackware services files.'

install:
	make -C config install
	make -C includes install
	make -C modules install
	install -d -m 0755 $(DESTDIR)$(SBINDIR)
	install -m 0755 blackhole $(DESTDIR)$(SBINDIR)/

update:
	make -C includes install
	make -C modules install
	install -d -m 0755 $(DESTDIR)$(SBINDIR)
	install -m 0755 blackhole $(DESTDIR)$(SBINDIR)/

remove:
	make -C config remove
	make -C includes remove
	make -C modules remove
	rmdir $(DESTDIR)$(SHAREDIR)/blackhole
	rm $(DESTDIR)$(SBINDIR)/blackhole

install-service-crux:
	install -d $(DESTDIR)$(ETCDIR)/rc.d
	ln -s $(SBINDIR)/blackhole $(DESTDIR)$(ETCDIR)/rc.d/blackhole
	@echo "Please add \"blackhole\" to the SERVICES array in /etc/rc.conf"

remove-service-crux:
	rm $(DESTDIR)$(ETCDIR)/rc.d/blackhole
	@echo "Please remove \"blackhole\" from the SERVICES array in /etc/rc.conf"

install-service-slackware:
	ln -s $(SBINDIR)/blackhole $(DESTDIR)$(ETCDIR)/rc.d/rc.firewall
	ifeq ($(strip $(DESTDIR)),)
		@echo '/etc/rc.d/rc.firewall start' >> '/etc/rc.d/rc.local'
	else
		@echo "Please add \"echo '/etc/rc.d/rc.firewall start' >> '/etc/rc.d/rc.local'\" to a post-install file and include checking if already set."
	endfi

remove-service-slackware:
	rm $(DESTDIR)$(ETCDIR)/rc.d/rc.firewall
	ifeq ($(strip $(DESTDIR)),)
		@sed '|/etc/rc.d/rc.firewall start|d' '/etc/rc.d/rc.local' 2> /dev/null
	else
		@echo "Please add \"sed '|/etc/rc.d/rc.firewall start|d' '/etc/rc.d/rc.local' 2> /dev/null\" to a post-remove file."
	endfi

### Developer targets.
DATETIME=$(shell date +%Y%m%d-%0k%M)
PWD=$(shell pwd)

dev-package:
	 install -m 0644 -t $(DESTDIR) blackhole Makefile makefile.includes \
		 COPYING Credits About

dev-snapshot:
	-rm blackhole-$(DATETIME).tar.bz2
	mkdir blackhole-$(DATETIME)
	make -C config dev-package DESTDIR=$(PWD)/blackhole-$(DATETIME)
	make -C includes dev-package DESTDIR=$(PWD)/blackhole-$(DATETIME)
	make -C modules dev-package DESTDIR=$(PWD)/blackhole-$(DATETIME)
	make dev-package DESTDIR=$(PWD)/blackhole-$(DATETIME)
	tar -cf blackhole-$(DATETIME).tar blackhole-$(DATETIME)/*
	rm -r blackhole-$(DATETIME)
	bzip2 -9 blackhole-$(DATETIME).tar

dev-crux-package: dev-snapshot
	-rm -r build/packages/crux
	mkdir -p build/packages/crux
	cp src/packages/crux/Pkgfile build/packages/crux/
	cp src/packages/crux/Makefile build/packages/crux/
	ln blackhole-$(DATETIME).tar.bz2 build/packages/crux/blackhole-$(DATETIME).tar.bz2
	sed -i -e 's/@VERSION@/$(DATETIME)/' build/packages/crux/Pkgfile
	make -C build/packages/crux package
	rm build/packages/crux/Makefile

