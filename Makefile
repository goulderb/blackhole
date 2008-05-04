include makefile.includes

help:
	@echo 'Install targets:'
	@echo 'install                    - Install blackhole, (defaults are in makefile.include. default: DESTDIR/usr)'
	@echo 'install-service-crux:      - Install CRUX services files'
	@echo 'install-service-slackware  - Install Slackware services files'
	@echo

install:
	make -C config install
	make -C includes install
	make -C modules install
	install -d -m 0755 $(DESTDIR)$(BINDIR)
	install -m 0755 blackhole $(DESTDIR)$(BINDIR)/

install-service-crux:
	install -d $(DESTDIR)$(ETCDIR)/rc.d
	ln -s $(BINDIR)/blackhole $(DESTDIR)$(ETCDIR)/rc.d/blackhole
	@echo "Please add \"blackhole\" to the SERVICES array in /etc/rc.conf"

install-service-slackware:
	ln -s $(BINDIR)/blackhole $(DESTDIR)$(ETCDIR)/rc.d/rc.firewall
	ifeq ($(strip $(DESTDIR)),)
		@echo '/etc/rc.d/rc.firewall start' >> '/etc/rc.d/rc.local'
	else
		@echo "Please add \"echo '/etc/rc.d/rc.firewall start' >> '/etc/rc.d/rc.local'\" to a post-install file and include checking if already set."
	endfi			
