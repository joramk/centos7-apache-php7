#!/bin/bash
set -eo pipefail
shopt -s nullglob

setup() {
        if [ ! -z "$REMOVE_MOD_SSL" ]; then
                yum remove mod_ssl -y
        fi

	if [ ! -z "$REMOVE_PHP_XDEBUG" ]; then
                yum remove php-pecl-xdebug -y
        fi

        if [ ! -z "$SELFUPDATE" ]; then
		sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
                systemctl enable yum-cron
		yum update -y
        fi

        if [ ! -z "$HTTPD_SERVERADMIN" ]; then    
                sed -i "s/ServerAdmin root@localhost//g" /etc/httpd/conf/httpd.conf
                echo "ServerAdmin $HTTPD_SERVERADMIN" >>/etc/httpd/conf/httpd.conf
        fi

        if [ ! -z "$HTTPD_HARDENING" ]; then    
                sed -i 's/expose_php = On/expose_php = Off/g' /etc/php.ini
                echo "ServerTokens Prod" >>/etc/httpd/conf/httpd.conf
                echo "ServerSignature Off" >>/etc/httpd/conf/httpd.conf
                echo "TraceEnable Off" >>/etc/httpd/conf/httpd.conf
        fi

        if [ ! -z "$PMA_FORCESSL" ]; then
                sed -i 's/\?>/$cfg['ForceSSL'] = true;\n\?>/g' /etc/phpMyAdmin/config.inc.php
        fi

        if [ ! -z "$PMA_DBHOST" ]; then
                sed -i "s/localhost/$PMA_DBHOST/g" /etc/phpMyAdmin/config.inc.php
        fi

        if [ ! -z "$TIMEZONE" ]; then
                echo "date.timezone = $TIMEZONE" >>/etc/php.ini
                ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
        fi
}

answers() {
        echo --
        echo SomeState
        echo SomeCity
        echo SomeOrganization
        echo SomeOrganizationalUnit
        echo localhost.localdomain
        echo root@localhost.localdomain
}

if [ -e /firstrun ] && [ -z "$HTTPD_OMIT_FIRSTRUN" ]; then
        setup
        answers | /usr/bin/openssl req -newkey rsa:2048 -keyout /etc/pki/tls/private/localhost.key -nodes -x509 -days 730 -out /etc/pki/tls/certs/localhost.crt
        rm -f /firstrun
fi

exec "$@"
