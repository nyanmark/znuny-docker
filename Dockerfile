FROM nginx:1.23.4-alpine3.17-perl

MAINTAINER nyanmark

WORKDIR /opt

RUN apk add --no-cache supervisor postgresql15-client fcgiwrap certbot certbot-nginx gcc make jq perl-fcgi perl-app-cpanminus perl-package-stash perl-dbi perl-archive-zip perl-authen-sasl perl-namespace-clean perl-moo perl-math-random-mt-auto perl-crypt-random perl-yaml-libyaml perl-xml-parser perl-xml-libxml perl-xml-libxslt perl-text-csv_xs perl-template-toolkit perl-spreadsheet-xlsx perl-ldap perl-net-dns perl-authen-ntlm perl-mail-imapclient perl-json-xs perl-data-uuid perl-datetime perl-date-format perl-crypt-jwt perl-crypt-openssl-x509 perl-css-minifier-xs perl-dbd-pg perl-dbd-mysql perl-dbd-odbc perl-javascript-minifier-xs perl-encode-hanextra perl-data-optlist perl-io-gzip &&\
cp /usr/share/zoneinfo/UTC /etc/localtime &&\
echo "UTC" >  /etc/timezone &&\
cpanm CPAN::Audit Crypt::Random::Source Hash::Merge Jq iCal::Parser&&\
wget https://download.znuny.org/releases/znuny-latest-6.5.tar.gz &&\
tar xfz znuny-latest-6.5.tar.gz &&\
mv /opt/znuny-6.5.1 /opt/otrs &&\
adduser -h /opt/otrs -G nginx -s /bin/sh -H -D otrs &&\
/opt/otrs/bin/otrs.SetPermissions.pl --otrs-user=otrs --web-group=nginx &&\
echo "*/5 * * * * /opt/otrs/bin/otrs.Daemon.pl start >> /dev/null" >> /var/spool/cron/crontabs/otrs &&\
echo "0 12 * * * /usr/bin/certbot renew --quiet" >> /var/spool/cron/crontabs/root

ADD supervisord.conf /etc/

EXPOSE 80 443

LABEL org.opencontainers.image.source="https://github.com/nyanmark/znuny-docker"

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
