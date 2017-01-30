FROM armhf/alpine

ENV CADDY_VERSION 0.9.5
ENV CADDY_SRC_URL https://github.com/mholt/caddy/releases/download/v$CADDY_VERSION/caddy_linux_arm7.tar.gz
ENV CADDYPATH /etc/ssl/caddy
#ENV CADDY_SRC_URL https://caddyserver.com/download/build?os=linux&arch=arm&features=

RUN apk add --no-cache ca-certificates

RUN set -ex \
        && apk add --no-cache --virtual .build-deps openssl libcap \
        && wget -q $CADDY_SRC_URL -O caddy.tar.gz \
        && tar -C /usr/local/bin -xzf caddy.tar.gz \
        && rm caddy.tar.gz \
        && setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy_linux_arm7

RUN set -ex \
        && addgroup -g 82 -S www-data \
        && adduser -u 82 -D -S -G www-data www-data \
        && mkdir /etc/caddy \
        && chown -R root:www-data /etc/caddy \
        && mkdir /etc/ssl/caddy \
        && chown -R www-data:root /etc/ssl/caddy \
        && chmod 0770 /etc/ssl/caddy \
        && mkdir /var/www \
        && chown www-data:www-data /var/www \
        && chmod 555 /var/www

USER www-data
WORKDIR /var/www

EXPOSE 80 443 2015

COPY index.html /var/www
COPY Caddyfile /etc/caddy

ENTRYPOINT caddy_linux_arm7 -agree=true -conf=/etc/caddy/Caddyfile
