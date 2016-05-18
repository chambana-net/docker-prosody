FROM chambana/base:latest

MAINTAINER Josh King <jking@chambana.net>

RUN apt-get -qq update && \
    apt-get install -y --no-install-recommends postgresql-client \
                                               lua5.1 \
                                               liblua5.1-dev \
                                               lua-bitop \
                                               lua-bitop-dev \
                                               lua-sec \
                                               lua-ldap \
                                               lua-dbi-postgresql \
                                               lua-expat \
                                               lua-socket \
                                               lua-filesystem \
                                               lua-zlib \
                                               lua-ldap \
                                               lua-event \
                                               libidn11-dev \
                                               libssl-dev \
                                               mercurial \
                                               bsdmainutils \
                                               make \
                                               openssl \
                                               build-essential \
                                               ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd prosody
RUN useradd -g prosody prosody

RUN hg clone http://hg.prosody.im/trunk prosody-trunk
RUN hg clone https://hg.prosody.im/prosody-modules/ prosody-modules

RUN cd prosody-trunk && ./configure --ostype=debian --prefix=/usr --sysconfdir=/etc/prosody --datadir=/var/lib/prosody --require-config

RUN cd prosody-trunk && make && make install

RUN cp -rf prosody-modules/* /usr/lib/prosody/modules/

# Workaround for library path issues
RUN cp prosody-modules/mod_lib_ldap/ldap.lib.lua /usr/lib/prosody/modules/

RUN mkdir -p /etc/prosody/conf.d /var/log/prosody /var/run/prosody

ADD files/prosody/prosody.cfg.lua /etc/prosody/prosody.cfg.lua
ADD files/prosody/prosody-ldap.cfg.lua /etc/prosody/prosody-ldap.cfg.lua

RUN chown -R prosody:prosody /etc/prosody /var/lib/prosody /var/log/prosody /var/run/prosody

EXPOSE 5000 5222 5269 5347 5280 5281

## Add startup script.
ADD bin/init.sh /app/bin/init.sh
RUN chmod 0755 /app/bin/init.sh

CMD ["/app/bin/init.sh"]
