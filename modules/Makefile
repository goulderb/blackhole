include ../makefile.includes

SRC=bruteforce-defeat.bmod core.bmod flood-limiting.bmod \
	 input-allow.bmod input-qos.bmod ipblock-blackhole.bmod \
	 ipblock-nfqueue.bmod output-allow.bmod output-qos.bmod \
	 tcp-flag-inspection.bmod

install:
	install -d -m 0755 $(DESTDIR)$(SHAREDIR)/blackhole/modules
	install -m 0644 -t $(DESTDIR)$(SHAREDIR)/blackhole/modules/ $(SRC)

remove:
	rm -rf $(DESTDIR)$(SHAREDIR)/blackhole/includes/modules

dev-package:
	install -d -m 0755 $(DESTDIR)/modules
	install -m 0644 -t $(DESTDIR)/modules/ $(SRC) Makefile
