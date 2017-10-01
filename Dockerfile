FROM centos:7
MAINTAINER mareeek@gmail.com
ENV container docker
LABEL name="CentOS 7 - CodeIT Apache 2.4 / Remi PHP 7.1" \
    vendor="CentOS" \
    license="GPLv2" \
    build-date="20171001"

RUN {   yum install yum-utils epel-release -y; \
        curl https://repo.codeit.guru/codeit.el7.repo >/etc/yum.repos.d/codeit.el7.repo; \
        yum install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm -y; \
        yum install httpd php71-php \ 
        php71-php-json \
        php71-php-cli \
        php71-php \
        php71-php-mbstring \
        php71-php-mysqlnd \
        php71-php-gd \
        php71-php-xml \
        php71-php-bcmath \
        php71-runtime \
        php71-php-common \
        php71-php-pdo \
        php71-php-process \
        php71-php-tidy \
        jwhois bind-utils -y; \
        yum --enablerepo=remi,remi-php71 install -y phpMyAdmin; \
        yum update -y; yum clean all; rm -rf /var/cache/yum; \
}

RUN {   ln -sf ../usr/share/zoneinfo/Europe/Berlin /etc/localtime; \
        sed -i 's/localhost/db1.docker1.dmz.lonet.org/g' /etc/phpMyAdmin/config.inc.php; \
        sed -i 's/;date.timezone =/date.timezone = Europe\/Berlin/g' /etc/opt/remi/php71/php.ini; \
        sed -i 's/expose_php = On/expose_php = Off/g' /etc/opt/remi/php71/php.ini; \
        sed -i 's/;date.timezone =/date.timezone = Europe\/Berlin/g' /etc/php.ini; \
        sed -i 's/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/g' /etc/httpd/conf.modules.d/00-mpm.conf; \
        sed -i 's/LoadModule mpm_worker_module modules\/mod_mpm_worker.so/#LoadModule mpm_worker_module modules\/mod_mpm_worker.so/g' /etc/httpd/conf.modules.d/00-mpm.conf; \
        echo "$cfg['ForceSSL'] = true;" >>/etc/phpMyAdmin/config.inc.php; \
        systemctl enable httpd; \
}

HEALTHCHECK CMD systemctl -q is-active httpd || exit 1
VOLUME ["/var/www", "/etc/httpd/certs", "/etc/httpd/conf.d"]
EXPOSE 80
CMD ["/sbin/init"]
