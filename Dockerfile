##
## knxd
##

## Use latest Alpine based images as starting point
FROM alpine

## Choose between branches
#ARG BRANCH=v0.14.17
ARG BRANCH=master
ARG HASH=358b87d6326925f7f3b7b2e0bb8e616e9d85b033

COPY entrypoint.sh /

RUN apk add --no-cache build-base gcc abuild binutils binutils-doc gcc-doc git libev-dev automake autoconf libtool argp-standalone linux-headers libusb-dev cmake cmake-doc dev86 \
    && mkdir -p /usr/local/src && cd /usr/local/src \
    && git clone https://github.com/knxd/knxd.git --single-branch --branch $BRANCH \
    && git -C knxd checkout $HASH \
    && cd knxd && ./bootstrap.sh \
    && ./configure --disable-systemd --enable-eibnetip --enable-eibnetserver --enable-eibnetiptunnel \
    && mkdir -p src/include/sys && ln -s /usr/lib/bcc/include/sys/cdefs.h src/include/sys \
    && make && make install && cd .. && rm -rf knxd && mkdir -p /etc/knxd \
    && addgroup -S knxd \
    && adduser -D -S -s /sbin/nologin -G knxd knxd \
    && chmod a+x /entrypoint.sh \
    && apk del --no-cache build-base abuild binutils binutils-doc gcc-doc git automake autoconf libtool argp-standalone cmake cmake-doc dev86


COPY knxd.ini.input /root

EXPOSE 3672 6720
VOLUME /etc/knxd

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/etc/knxd/knxd.ini"]
