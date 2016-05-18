#!/bin/bash -

. /app/lib/common.sh

CHECK_BIN sed
CHECK_BIN prosodyctl
CHECK_VAR XMPP_DOMAIN
CHECK_VAR DB_PASS
CHECK_VAR LDAP_DN
CHECK_VAR LDAP_PASS
CHECK_VAR LDAP_USER_BASE
CHECK_VAR LDAP_GROUP_BASE

ADMINS=${ADMINS:-""}
DB_HOST=${DB_HOST:-"postgres"}
DB_PORT=${DB_PORT:-"5432"}
DB_USER=${DB_USER:-"prosody"}
DB_NAME=${DB_NAME:-"prosody"}
LDAP_HOST=${LDAP_HOST:-"ldap"}
LDAP_GROUP=${LDAP_GROUP:-"xmpp"}

MSG "Configuring Prosody..."

sed -i -e "s/{{ADMINS}}/${ADMINS}/" \
	-e "s/{{XMPP_DOMAIN}}/${XMPP_DOMAIN}/" \
	-e "s/{{DB_HOST}}/${DB_HOST}/" \
	-e "s/{{DB_PORT}}/${DB_PORT}/" \
	-e "s/{{DB_NAME}}/${DB_NAME}/" \
	-e "s/{{DB_USER}}/${DB_USER}/" \
	-e "s/{{DB_PASS}}/${DB_PASS}/" \
	/etc/prosody/prosody.cfg.lua

sed -i -e "s/{{LDAP_HOST}}/${LDAP_HOST}/" \
	-e "s/{{LDAP_DN}}/${LDAP_DN}/" \
	-e "s/{{LDAP_PASS}}/${LDAP_PASS}/" \
	-e "s/{{LDAP_GROUP}}/${LDAP_GROUP}/" \
	-e "s/{{LDAP_USER_BASE}}/${LDAP_USER_BASE}/" \
	-e "s/{{LDAP_GROUP_BASE}}/${LDAP_GROUP_BASE}/" \
	/etc/prosody/prosody.cfg.lua
  

echo VirtualHost \"${XMPP_DOMAIN}\" >> /etc/prosody/conf.d/domain.cfg.lua
echo "	ssl = {" >> /etc/prosody/conf.d/domain.cfg.lua
echo "		key = \"/etc/letsencrypt/key.pem\";" >> /etc/prosody/conf.d/domain.cfg.lua
echo "		certificate = \"/etc/letsencrypt/fullchain.pem\";" >> /etc/prosody/conf.d/domain.cfg.lua
echo "	}" >> /etc/prosody/conf.d/domain.cfg.lua
echo Component \"chat.${XMPP_DOMAIN}\" \"muc\" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    name = \"The ${XMPP_DOMAIN} chatrooms server\"" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    restrict_room_creation = \"local\"" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    max_history_messages = 50;" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    max_archive_query_results = 50;" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    muc_log_by_default = true;" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    muc_log_all_rooms = true;" >> /etc/prosody/conf.d/domain.cfg.lua

chmod 755 /etc/prosody/conf.d/domain.cfg.lua
mkdir -p /var/run/prosody
chown -R prosody:prosody /var/lib/prosody /var/log/prosody /var/run/prosody

MSG "Waiting for certs..."
while [[ ! -e /etc/letsencrypt/fullchain.pem ]]; do
	sleep 5
done

MSG "Starting Prosody..."
while true; do sleep 1; done

su - prosody -c /usr/bin/prosody
