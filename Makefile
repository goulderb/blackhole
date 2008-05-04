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
