docker-prosody
==============
A docker container for the Prosody XMPP server. This container's configuration is inspired by the https://github.com/digicoop/kaiwa-server container.

Usage
-----
This container runs Prosody. It is designed to use an LDAP server for roster and vcard storage, and a Postgres server for other storage. It uses a Prosody 0.10 snapshot with a number of newer modules from the prosody-modules repository. It is designed to work in tandem with a proxy providing LetsEncrypt certificates, and expects those certificates to be found in `/etc/letsencrypt`.

A sample `docker-compose` stanza demonstrating some of the available environment variables for configuration is below:
```
  prosody:
    image: chambana/prosody
    container_name: prosody
    hostname: chat.example.com
    restart: on-failure:5
    network_mode: bridge
    expose:
      - 80
    ports:
      - "5000:5000"
      - "5222:5222"
      - "5269:5269"
      - "5280:5280"
      - "5281:5281"
      - "3478:3478/udp"
    volumes:
      - /etc/letsencrypt/live/example.com:/etc/letsencrypt:ro
    environment:
      - XMPP_DOMAIN=example.com
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_NAME=prosody
      - DB_USER=prosody
      - DB_PASS=examplepassword1
      - LDAP_HOST=ldap
      - LDAP_USER_BASE=cn=users,cn=accounts,dc=example,dc=com
      - LDAP_GROUP_BASE=cn=groups,cn=accounts,dc=example,dc=com
      - LDAP_DN=uid=prosody,cn=sysaccounts,cn=etc,dc=example,dc=com
      - LDAP_PASS=examplepassword2
      - LDAP_GROUP=xmpp
    links:
      - postgres:postgres
      - ldap:ldap
```
