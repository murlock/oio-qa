FROM centos:7
MAINTAINER jfsmig (jean-francois.smigielski@openio.io)
ENV TMPDIR=/tmp \
    PATH="$PATH:$TMPDIR/install/bin" \
    LD_LIBRARY_PATH="$TMPDIR/install/lib" \
	LD_LIBDIR=lib64 \
    APACHE2_INCDIR="/usr/include/httpd" \
    APACHE2_LIBDIR="/usr/${LD_LIBDIR}/httpd" \
    APACHE2_MODDIR="$TMPDIR/${LD_LIBDIR}/httpd/modules" \
    YUM="yum --disableplugin=fastestmirror"

# System dependencies specific to the distribution, and common to all the
# components being tested.
RUN if [ -n "${http_proxy}" ] ; then echo "proxy=${http_proxy}" >> /etc/yum.conf ; fi \
 && $YUM install -y epel-release.noarch \
 && rpm -iv http://mirror.openio.io/pub/repo/openio/sds/16.10/centos/openio-sds-release-16.10-1.el.noarch.rpm \
 && $YUM clean -y all \
 && $YUM update -y \
 && $YUM install -y \
		bash \
		make cmake imake automake autoconf libtool gcc gcc-c++ \
        git-svn python-virtualenv python puppet \
 && $YUM install -y \
		bison flex glib2 glib2-devel \
		libcurl libcurl-devel \
		json-c json-c-devel \
		leveldb leveldb-devel \
		python-devel \
		liberasurecode liberasurecode-devel \
		libattr libattr-devel \
		sqlite sqlite-devel \
		zookeeper-lib zookeeper-lib-devel \
		apr apr-devel \
		apr-util apr-util-devel \
		zeromq3 zeromq3-devel \
		beanstalkd \
		redis \
		python-pip \
		lzo lzo-devel \
		openssl openssl-libs openssl-devel \
		httpd httpd-devel \
 && $YUM install -y \
		libevent libevent-devel \
 && $YUM install -y \
		libffi libffi-devel \
 && $YUM install -y \
		java-1.8.0-openjdk-devel java-1.8.0-openjdk \
 && $YUM install -y \
		jansson jansson-devel \
		libicu libicu-devel \
		perl-ExtUtils-MakeMaker \
 && $YUM clean -y all \
 && useradd -m oio

RUN su - oio \
 && git config --global user.email "bot@openio.io" \
 && git config --global user.name "openiobot" \
 && virtualenv "/home/oio/.python/env" \
 && source "/home/oio/.python/env/bin/activate" \
 && pip install --upgrade pip virtualenv tox \
 && pip install six packaging appdirs \
 && pip install --upgrade setuptools

# For testing purposes only, to spare iteration time thanks to aufs layers.
# this should be included in the test script.
RUN cd /home/oio \
 && git clone https://github.com/jfsmig/oio-qa.git \
 && source "/home/oio/.python/env/bin/activate" \
 && source /home/oio/oio-qa/components \
 && source /home/oio/oio-qa/releases/3.x \
 && cd oio-qa \
 && make -f Install.makefile pull

# Don't parallelize when everything is installed in the same virtualenv
RUN cd /home/oio \
 && source "/home/oio/.python/env/bin/activate" \
 && source /home/oio/oio-qa/components \
 && source /home/oio/oio-qa/releases/3.x \
 && cd oio-qa \
 && make -f Install.makefile deps

RUN cd /home/oio \
 && source "/home/oio/.python/env/bin/activate" \
 && source /home/oio/oio-qa/components \
 && source /home/oio/oio-qa/releases/3.x \
 && cd oio-qa \
 && make -f Install.makefile install

#CMD ["/home/oio/oio-qa/qa.sh", "/home/oio/oio-qa", "3.x"]
RUN su - oio \
 && /home/oio/oio-qa/qa.sh "/home/oio/oio-qa/components" "/home/oio/oio-qa/releases/3.x"

CMD ["bash"]
