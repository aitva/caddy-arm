FROM armhf/alpine

ENV CADDY_PLUGINS git,hugo,ipfilter
ENV CADDY_SRC_URL https://caddyserver.com/download/build?os=linux&arch=arm&features=$CADDY_PLUGINS
ENV CADDYPATH /etc/caddy/.ssl

RUN apk add --no-cache ca-certificates

RUN set -ex \
        && apk add --no-cache --virtual .build-deps openssl libcap \
        && wget -q $CADDY_SRC_URL -O caddy.tar.gz \
        && tar -C /usr/local/bin -xzf caddy.tar.gz \
        && rm caddy.tar.gz \
        && setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

RUN set -ex \
        && addgroup -g 82 -S www-data \
        && adduser -u 82 -D -S -G www-data www-data \
        && mkdir /etc/caddy \
        && chown -R root:www-data /etc/caddy \
        && mkdir $CADDYPATH \
        && chown -R www-data:root $CADDYPATH \
        && chmod 0770 $CADDYPATH \
        && mkdir /var/www \
        && chown www-data:www-data /var/www \
        && chmod 555 /var/www

USER www-data
WORKDIR /var/www

EXPOSE 80 443 2015

COPY index.html /var/www
COPY Caddyfile /etc/caddy

ENTRYPOINT caddy -agree=true -conf=/etc/caddy/Caddyfile
