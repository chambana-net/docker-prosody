FROM chambana/base:latest

MAINTAINER Josh King <jking@chambana.net>

ENV PROSODY_DB_HOST="postgres" PROSODY_DB_PORT="5432" PROSODY_DB_USER="prosody" \
    PROSODY_DB_NAME="prosody" PROSODY_LDAP_HOST="ldap" PROSODY_LDAP_GROUP="xmpp" \
    PROSODY_ADMINS=""

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
                                               wget \
                                               openssl \
                                               ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd prosody
RUN useradd -g prosody prosody

# Pull specific nightly tarball
#RUN hg clone http://hg.prosody.im/trunk prosody-src
#RUN wget https://prosody.im/nightly/0.10/build198/prosody-0.10-1nightly198.tar.gz && \
#    mkdir prosody-src && \
#    tar -zxvf prosody-0.10-1nightly198.tar.gz -C prosody-src --strip-components=1 && \
#    rm prosody-0.10-1nightly198.tar.gz 
RUN wget http://packages.prosody.im/debian/pool/main/p/prosody-0.10/prosody-0.10_1nightly198-1~jessie_amd64.deb
RUN dpkg -i prosody-0.10_1nightly198-1~jessie_amd64.deb
RUN hg clone https://hg.prosody.im/prosody-modules/ prosody-modules

#RUN cd prosody-src && ./configure --ostype=debian --prefix=/usr --sysconfdir=/etc/prosody --datadir=/var/lib/prosody --require-config

#RUN cd prosody-src && make && make install

RUN cp -rf prosody-modules/* /usr/lib/prosody/modules/

# Workaround for library path issues
RUN cp prosody-modules/mod_lib_ldap/ldap.lib.lua /usr/lib/prosody/modules/

# Cleanup
#RUN rm -rf prosody-src prosody-modules 
RUN rm -rf prosody-modules 

RUN mkdir -p /etc/prosody/conf.d /var/log/prosody /var/run/prosody

ADD files/prosody/prosody.cfg.lua /etc/prosody/prosody.cfg.lua
ADD files/prosody/prosody-ldap.cfg.lua /etc/prosody/prosody-ldap.cfg.lua

RUN chown -R prosody:prosody /etc/prosody /var/lib/prosody /var/log/prosody /var/run/prosody

EXPOSE 5000 5222 5269 5347 5280 5281

## Add startup script.
ADD bin/init.sh /app/bin/init.sh
RUN chmod 0755 /app/bin/init.sh

CMD ["/app/bin/init.sh"]
