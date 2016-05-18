FROM chambana/base:latest

MAINTAINER Josh King <jking@chambana.net>

RUN apt-get -qq update && \
    apt-get install -y --no-install-recommends prosody \
                                               prosody-modules \
                                               lua-zlib \
                                               lua-sec \
                                               lua-dbi-postgresql \
                                               mercurial \
                                               ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD files/prosody/prosody.cfg.lua /etc/prosody/prosody.cfg.lua
ADD files/prosody/prosody-ldap.cfg.lua /etc/prosody/prosody-ldap.cfg.lua
RUN hg clone https://hg.prosody.im/prosody-modules/ /opt/prosody-modules

EXPOSE 5000 5222 5269 5347 5280 5281

## Add startup script.
ADD bin/init.sh /app/bin/init.sh
RUN chmod 0755 /app/bin/init.sh

#CMD ["/app/bin/init.sh"]
ENTRYPOINT ["/bin/bash"]
