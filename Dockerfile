FROM armhf/alpine

ENV CADDY_PLUGINS git,hugo,ipfilter
ENV CADDY_SRC_URL https://caddyserver.com/download/build?os=linux&arch=arm&features=$CADDY_PLUGINS
ENV CADDYPATH /etc/caddy/.ssl

ENV HUGO_VERSION 0.18.1
ENV HUGO_SRC_URL https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux_ARM.tar.gz

RUN set -ex \
        && apk add --no-cache --virtual .build-deps \
            openssl \
            libcap \
            git \
        && wget -q $CADDY_SRC_URL -O caddy.tar.gz \
        && mkdir /usr/local/caddy \
        && tar -C /usr/local/caddy -xzf caddy.tar.gz \
        && ln -s /usr/local/caddy/caddy /usr/local/bin/caddy \
        && rm caddy.tar.gz \
        && setcap 'cap_net_bind_service=+ep' /usr/local/caddy/caddy \
        && wget -q $HUGO_SRC_URL -O hugo.tar.gz \
        && tar -C /usr/local -xzf hugo.tar.gz \
        && ln -s /usr/local/hugo_${HUGO_VERSION}_linux_arm/hugo_${HUGO_VERSION}_linux_arm /usr/local/bin/hugo \
        && rm hugo.tar.gz

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
