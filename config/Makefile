include ../makefile.includes

SRC=blackhole.conf extopts.conf ipblock-input.conf \
	 ipblock-output.conf qos.conf

install:
	install -d -m 0755 $(DESTDIR)$(ETCDIR)/blackhole
	install -m 0644 -t $(DESTDIR)$(ETCDIR)/blackhole/ $(SRC)

remove:
	rm -rf $(DESTDIR)$(ETCDIR)/blackhole

dev-package:
	install -d -m 0755 $(DESTDIR)/config
	install -m 0644 -t $(DESTDIR)/config/ $(SRC) Makefile

