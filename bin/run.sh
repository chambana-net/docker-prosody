#!/bin/bash -

. /app/lib/common.sh

CHECK_BIN sed
CHECK_BIN prosodyctl
CHECK_VAR PROSODY_XMPP_DOMAIN
CHECK_VAR PROSODY_ADMINS
CHECK_VAR PROSODY_DB_USER
CHECK_VAR PROSODY_DB_PASS
CHECK_VAR PROSODY_DB_NAME
CHECK_VAR PROSODY_DB_HOST
CHECK_VAR PROSODY_DB_PORT
CHECK_VAR PROSODY_LDAP_DN
CHECK_VAR PROSODY_LDAP_PASS
CHECK_VAR PROSODY_LDAP_HOST
CHECK_VAR PROSODY_LDAP_GROUP
CHECK_VAR PROSODY_LDAP_USER_BASE
CHECK_VAR PROSODY_LDAP_GROUP_BASE

MSG "Configuring Prosody..."

sed -i -e "s/{{ADMINS}}/${PROSODY_ADMINS}/" \
	-e "s/{{DB_HOST}}/${PROSODY_DB_HOST}/" \
	-e "s/{{DB_PORT}}/${PROSODY_DB_PORT}/" \
	-e "s/{{DB_NAME}}/${PROSODY_DB_NAME}/" \
	-e "s/{{DB_USER}}/${PROSODY_DB_USER}/" \
	-e "s/{{DB_PASS}}/${PROSODY_DB_PASS}/" \
	/etc/prosody/prosody.cfg.lua

sed -i -e "s/{{LDAP_HOST}}/${PROSODY_LDAP_HOST}/" \
	-e "s/{{LDAP_DN}}/${PROSODY_LDAP_DN}/" \
	-e "s/{{LDAP_PASS}}/${PROSODY_LDAP_PASS}/" \
	-e "s/{{LDAP_GROUP}}/${PROSODY_LDAP_GROUP}/" \
	-e "s/{{LDAP_USER_BASE}}/${PROSODY_LDAP_USER_BASE}/" \
	-e "s/{{LDAP_GROUP_BASE}}/${PROSODY_LDAP_GROUP_BASE}/" \
	/etc/prosody/prosody-ldap.cfg.lua
  
echo VirtualHost \"${PROSODY_XMPP_DOMAIN}\" > /etc/prosody/conf.d/domain.cfg.lua
echo "	ssl = {" >> /etc/prosody/conf.d/domain.cfg.lua
echo "		key = \"/etc/letsencrypt/key.pem\";" >> /etc/prosody/conf.d/domain.cfg.lua
echo "		certificate = \"/etc/letsencrypt/fullchain.pem\";" >> /etc/prosody/conf.d/domain.cfg.lua
echo "		protocol = \"tlsv1_1+\";" >> /etc/prosody/conf.d/domain.cfg.lua
echo "	}" >> /etc/prosody/conf.d/domain.cfg.lua
echo Component \"chat.${PROSODY_XMPP_DOMAIN}\" \"muc\" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    name = \"The ${PROSODY_XMPP_DOMAIN} chatrooms server\"" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    restrict_room_creation = \"local\"" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    max_history_messages = 50;" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    max_archive_query_results = 50;" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    muc_log_by_default = true;" >> /etc/prosody/conf.d/domain.cfg.lua
echo "    muc_log_all_rooms = true;" >> /etc/prosody/conf.d/domain.cfg.lua
echo Component \"proxy.${PROSODY_XMPP_DOMAIN}\" \"proxy65\" >> /etc/prosody/conf.d/domain.cfg.lua

chown prosody:prosody /etc/prosody/conf.d/domain.cfg.lua
chmod 755 /etc/prosody/conf.d/domain.cfg.lua

MSG "Waiting for certs..."
while [[ ! -e /etc/letsencrypt/fullchain.pem ]]; do
	sleep 5
done

MSG "Starting Prosody..."

exec "$@"
