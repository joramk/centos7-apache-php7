FROM    centos:7
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="CentOS 7 - Latest Apache / PHP / phpMyAdmin" \
        vendor="CentOS" \
        license="GPLv2" \
        build-date="20171002" \
        maintainer="joramk@gmail.com"

RUN {   yum update -y; yum install systemd yum-utils yum-cron epel-release -y; \
        curl https://repo.codeit.guru/codeit.el7.repo >/etc/yum.repos.d/codeit.el7.repo; \
        yum install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm -y; \
	yum-config-manager --enable remi-php71 --enable remi; \
        yum install httpd mod_ssl openssl php \ 
        php71-php-json php71-php-cli \
        php71-php-mbstring php71-php-mysqlnd \
        php71-php-gd php71-php-xml \
        php71-php-bcmath php71-runtime \
        php71-php-common php71-php-pdo \
        php71-php-process php71-php-tidy phpMyAdmin -y; \
        yum clean all; rm -rf /var/cache/yum; \
}

RUN {   (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
        rm -f /lib/systemd/system/multi-user.target.wants/*; \
        rm -f /etc/systemd/system/*.wants/*; \
        rm -f /lib/systemd/system/local-fs.target.wants/*; \
        rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
        rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
        rm -f /lib/systemd/system/basic.target.wants/*; \
        rm -f /lib/systemd/system/anaconda.target.wants/*; \
        sed -i 's/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/g' /etc/httpd/conf.modules.d/00-mpm.conf; \
        sed -i 's/LoadModule mpm_worker_module modules\/mod_mpm_worker.so/#LoadModule mpm_worker_module modules\/mod_mpm_worker.so/g' /etc/httpd/conf.modules.d/00-mpm.conf; \
}

COPY    ./docker-entrypoint.sh /
RUN {   systemctl enable httpd crond; \
        touch /firstrun; \
        chmod +rx /docker-entrypoint.sh; \
}

HEALTHCHECK CMD systemctl -q is-active httpd || exit 1

VOLUME  [ “/sys/fs/cgroup”, "/var/www", "/etc/httpd/conf.d" ]

EXPOSE  80 443
STOPSIGNAL SIGRTMIN+3
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/sbin/init" ]
