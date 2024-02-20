FROM varnish:7.3

ARG VMOD_URL=
ARG VMOD_BUILD_DEPS=
ARG VMOD_RUN_DEPS=
ARG SKIP_CHECK=

USER root
RUN set -e; \
    # get the dependencies
    apt-get update; \
    apt-get -y install /pkgs/*.deb $VMOD_DEPS $VMOD_BUILD_DEPS $VMOD_RUN_DEPS git libpcre2-dev libedit-dev; \
    # grab and compile the right commit of the Varnish source
    git clone https://github.com/varnishcache/varnish-cache.git /tmp/varnish-cache; \
    cd /tmp/varnish-cache; \
    # make sure to check out the exact same version that's already compiled and installed
    git checkout $(varnishd -V 2>&1 | grep -o '[0-9a-f]\{40\}*'); \
    ./autogen.sh; \
    ./configure --with-persistent-storage; \
    make -j 16; \
    export VARNISHSRC=/tmp/varnish-cache; \
    # build and install
    install-vmod $VMOD_URL; \
    apt-get -y purge --auto-remove $VMOD_DEPS varnish-dev git libpcre2-dev libedit-dev; \
    rm -rf /var/lib/apt/lists/* /tmp/varnish-cache
USER varnish