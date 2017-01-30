# caddy-arm
A Docker container with a secure Caddy install for ARM.
I have built this container folowing the recommendation at [linux-systemd](https://github.com/mholt/caddy/tree/master/dist/init/linux-systemd).


# Usage
The Caddyfile is located at: `/etc/caddy` and Caddy is started in `/var/www`.

```bash
docker run -d \
    -v "$(pwd)/caddy":/etc/caddy \
    -v "$(pwd)/www":/var/www \
    -u "33:33" \
    -p 80:80 \
    -p 443:443 \
    --name caddy \
    aitva/caddy-arm
```
