.PHONY: \
	pull_asn1c pull_gridinit pull_oiosds pull_swift pull_oioswift \
		pull_puppet pull_docs pull_oiojava pull_cyrus \
	deps_oiosds deps_oioswift deps_swift deps_docs \
	build_gridinit build_asn2c build_oiosds \
	install_asn1c install_gridinit install_oiosds install_swift install_oioswift \
		install_puppet install_docs install_oiojava install_cyrus

default: install

pull: \
	pull_asn1c \
	pull_gridinit \
	pull_oiosds \
	pull_swift \
	pull_oioswift \
	pull_puppet \
	pull_docs \
	pull_oiojava \
	pull_cyrus
deps: \
	deps_oiosds \
	deps_oioswift \
	deps_swift \
	deps_docs
build: \
	build_asn1c \
	build_gridinit \
	build_oiosds \
	build_docs \
	build_oiojava \
	build_cyrus
install: \
	install_asn1c \
	install_gridinit \
	install_oiosds \
	install_swift \
	install_oioswift \
	install_puppet \
	install_docs \
	install_oiojava \
	install_cyrus

$(TMPDIR)/build/%:
	mkdir -p $@
$(TMPDIR)/src/%:
	mkdir -p $@

### OIO asn1c

pull_asn1c: $(TMPDIR)/src/asn1c
	./bin/fetch-git-repository.sh asn1c "$(ASN1C_URL)"
	cd $(TMPDIR)/src/asn1c && \
		git reset --hard $(ASN1C_ID) --

build_asn1c: $(TMPDIR)/build/asn1c
	cd $(TMPDIR)/build/asn1c && \
		lndir $(TMPDIR)/src/asn1c && \
		if ! [ -r ./configure ] ; then autoreconf -f -i ; fi && \
		if ! [ -r ./Makefile ] ; then ./configure --prefix=/usr ; fi
	$(MAKE) -C $(TMPDIR)/build/asn1c
install_asn1c: build_asn1c
	$(MAKE) -C $(TMPDIR)/build/asn1c install


### OIO gridinit

pull_gridinit: $(TMPDIR)/src/gridinit
	test -n "$(GRIDINIT_URL)"
	./bin/fetch-git-repository.sh gridinit "$(GRIDINIT_URL)"

build_gridinit: $(TMPDIR)/build/gridinit
	test -n "$(GRIDINIT_ID)"
	cd $(TMPDIR)/src/gridinit && \
		git reset --hard $(GRIDINIT_ID) --
	cd $(TMPDIR)/build/gridinit && \
		cmake \
			-D CMAKE_INSTALL_PREFIX=/usr \
		$(TMPDIR)/src/gridinit
	$(MAKE) -C $(TMPDIR)/build/gridinit
install_gridinit: build_gridinit
	$(MAKE) -C $(TMPDIR)/build/gridinit install


### OIO SDS

pull_oiosds: $(TMPDIR)/src/oio-sds
	test -n "$(OIOSDS_URL)"
	./bin/fetch-git-repository.sh oio-sds "$(OIOSDS_URL)"

deps_oiosds:
	test -n "$(OIOSDS_ID)"
	cd $(TMPDIR)/src/oio-sds && \
		git reset --hard $(OIOSDS_ID) --
	./bin/install-requirements.sh $(TMPDIR)/src/oio-sds

build_oiosds: $(TMPDIR)/build/oio-sds
	cd $(TMPDIR)/build/oio-sds && \
		rm -rf CMakeCache.txt CMakeFiles && \
		cmake \
			-D CMAKE_INSTALL_PREFIX=/usr \
			-D APACHE2_INCDIR=$(APACHE2_INCDIR) \
			-D APACHE2_LIBDIR=$(APACHE2_LIBDIR) \
			-D APACHE2_MODDIR=$(APACHE2_MODDIR) \
			-D ASN1C_LIBDIR=/usr/$(LD_LIBDIR) \
			$(TMPDIR)/src/oio-sds
		$(MAKE) -C $(TMPDIR)/build/oio-sds
install_oiosds: build_oiosds install_gridinit install_asn1c install_puppet
	$(MAKE) -C $(TMPDIR)/build/oio-sds install
	cd $(TMPDIR)/src/oio-sds && \
		python ./setup.py install


### Official swift

pull_swift: $(TMPDIR)/src/swift
	test -n "$(SWIFT_URL)"
	./bin/fetch-git-repository.sh swift "$(SWIFT_URL)"

deps_swift:
	test -n "$(SWIFT_ID)"
	cd $(TMPDIR)/src/swift && \
		git reset --hard $(SWIFT_ID) --
	./bin/install-requirements.sh $(TMPDIR)/src/swift

install_swift:
	cd $(TMPDIR)/src/swift && \
		python ./setup.py install


### OpenIO Swift

pull_oioswift: $(TMPDIR)/src/oio-swift
	test -n "$(OIOSWIFT_URL)"
	./bin/fetch-git-repository.sh oio-swift "$(OIOSWIFT_URL)"

deps_oioswift:
	test -n "$(OIOSWIFT_ID)"
	cd $(TMPDIR)/src/oio-swift && \
		git reset --hard $(OIOSWIFT_ID) --
	./bin/install-requirements.sh $(TMPDIR)/src/oio-swift

install_oioswift: install_swift
	cd $(TMPDIR)/src/oio-swift && \
		python ./setup.py install


### OpenIO Puppet templates

pull_puppet: $(TMPDIR)/src/puppet-openiosds
	test -n "$(PUPPET_OIOSDS_URL)"
	./bin/fetch-git-repository.sh puppet-openiosds "$(PUPPET_OIOSDS_URL)"

install_puppet:
	test -n "$(PUPPET_OIOSDS_ID)"
	cd $(TMPDIR)/src/puppet-openiosds && \
		git reset --hard $(PUPPET_OIOSDS_ID) --
	cd $(TMPDIR)/src/puppet-openiosds && \
		cp -a * /usr/share


### OpenIO Docs

pull_docs: $(TMPDIR)/src/oio-docs
	test -n "$(OIODOCS_URL)"
	./bin/fetch-git-repository.sh oio-docs "$(OIODOCS_URL)"

deps_docs:
	test -n "$(OIODOCS_ID)"
	cd $(TMPDIR)/src/oio-docs && \
		git reset --hard $(OIODOCS_ID) --
	./bin/install-requirements.sh $(TMPDIR)/src/oio-docs

build_docs:
	cd $(TMPDIR)/src/oio-docs && \
		tox
install_docs: build_docs
	# TODO(jfs): take a snaphsot and join it as an artifact


## OpenIO Java API

pull_oiojava: $(TMPDIR)/src/oio-api-java
	test -n "$(OIOJAVA_URL)"
	./bin/fetch-git-repository.sh oio-api-java "$(OIOJAVA_URL)"

build_oiojava: $(TMPDIR)/build/oio-api-java
	test -n "$(OIOJAVA_ID)"
	cd $(TMPDIR)/src/oio-api-java && \
		git reset --hard $(OIOJAVA_ID) --
	cd $(TMPDIR)/src/oio-api-java && \
		./gradlew jar
install_oiojava: build_oiojava


### cyrus-imapd

pull_cyrus: $(TMPDIR)/src/cyrus-imapd
	test -n "$(CYRUS_URL)"
	./bin/fetch-git-repository.sh cyrus-imapd "$(CYRUS_URL)"

build_cyrus: install_oiosds $(TMPDIR)/build/cyrus-imapd
	test -n "$(CYRUS_ID)"
	cd $(TMPDIR)/src/cyrus-imapd && \
		git reset --hard "$(CYRUS_ID)" --
	cd $(TMPDIR)/build/cyrus-imapd && \
		lndir $(TMPDIR)/src/cyrus-imapd && \
		if ! [ -r ./configure ] ; then autoreconf -f -i ; fi && \
		if ! [ -r ./Makefile ] ; then \
			./configure --prefix=/usr \
				--enable-static --enable-shared \
				--enable-objectstore \
				--with-openio=yes \
				--with-openio-libdir=/usr/$(LD_LIBDIR) \
				--with-openio-incdir=/usr/include \
				; \
		fi
	$(MAKE) -C $(TMPDIR)/build/cyrus-imapd
install_cyrus: build_cyrus
	$(MAKE) -C $(TMPDIR)/build/cyrus-imapd install

