include ../makefile.includes

SRC=module-functions functions qos-functions

install:
	install -d -m 0755 $(DESTDIR)$(SHAREDIR)/blackhole/includes
	install -m 0644 -t $(DESTDIR)$(SHAREDIR)/blackhole/includes/ $(SRC)

remove:
	rm -rf $(DESTDIR)$(SHAREDIR)/blackhole/includes

dev-package:
	install -d -m 0755 $(DESTDIR)/includes
	install -m 0644 -t $(DESTDIR)/includes/ $(SRC) Makefile
