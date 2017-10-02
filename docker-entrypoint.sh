#!/bin/bash
set -eo pipefail
shopt -s nullglob

setup() {   
        if [ ! -z "$HTTPD_SERVERADMIN" ]; then
                sed -i "s/ServerAdmin root@localhost//g" /etc/httpd/conf/httpd.conf                              
                echo "ServerAdmin $HTTPD_SERVERADMIN" >>/etc/httpd/conf/httpd.conf 
        fi

        if [ ! -z "$HTTPD_HARDENING" ]; then
                sed -i 's/expose_php = On/expose_php = Off/g' /etc/opt/remi/php71/php.ini
                sed -i 's/expose_php = On/expose_php = Off/g' /etc/php.ini
                echo "ServerTokens Prod" >>/etc/httpd/conf/httpd.conf
                echo "ServerSignature Off" >>/etc/httpd/conf/httpd.conf
                echo "TraceEnable Off" >>/etc/httpd/conf/httpd.conf
        fi

        if [ ! -z "$PMA_FORCESSL" ]; then
                echo "$cfg['ForceSSL'] = true;" >>/etc/phpMyAdmin/config.inc.php  
        fi

        if [ ! -z "$PMA_DBHOST" ]; then  
                sed -i "s/localhost/$PMA_DBHOST/g" /etc/phpMyAdmin/config.inc.php               
        fi

        if [ ! -z "$TIMEZONE" ]; then  
                echo "date.timezone = $TIMEZONE" >>/etc/opt/remi/php71/php.ini                          
        fi
}

if [ -e /firstrun ] && [ -z "$HTTPD_OMIT_FIRSTRUN" ]; then
        setup
        rm -f /firstrun    
fi

exec "$@"
