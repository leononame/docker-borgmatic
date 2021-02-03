FROM alpine:3 as builder
MAINTAINER leononame
ARG BORG_VERSION=1.1.15
ARG BORGMATIC_VERSION=1.5.12
RUN apk upgrade --no-cache \
    && apk add \
    alpine-sdk \
    python3-dev \
    openssl-dev \
    lz4-dev \
    acl-dev \
    linux-headers \
    attr-dev \
    py-pip \
    && /usr/bin/pip3 install --upgrade pip \
    && /usr/bin/pip3 install --upgrade borgbackup==${BORG_VERSION} \
    && /usr/bin/pip3 install --upgrade borgmatic==${BORGMATIC_VERSION}

FROM alpine:3
MAINTAINER leononame
COPY entry.sh /entry.sh
COPY backup /usr/local/bin
COPY cronic /usr/local/bin
RUN apk upgrade --no-cache \
    && apk add --no-cache \
    tzdata \
    sshfs \
    python3 \
    openssl \
    ca-certificates \
    lz4-libs \
    libacl \
    bash \
    && rm -rf /var/cache/apk/* \
    && chmod 755 /entry.sh
# msmtp
RUN apk upgrade --no-cache \
    && apk add --no-cache \
    msmtp \
    && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
    && rm -rf /var/cache/apk/* \
    && chmod 755 /entry.sh

VOLUME /mnt/source
VOLUME /etc/borgmatic.d
VOLUME /root/.cache/borg
VOLUME /root/.config/borg
VOLUME /root/.ssh
COPY --from=builder /usr/lib/python3.8/site-packages /usr/lib/python3.8/
COPY --from=builder /usr/bin/borg /usr/bin/
COPY --from=builder /usr/bin/borgfs /usr/bin/
COPY --from=builder /usr/bin/borgmatic /usr/bin/
COPY --from=builder /usr/bin/generate-borgmatic-config /usr/bin/
COPY --from=builder /usr/bin/upgrade-borgmatic-config /usr/bin/

CMD ["/entry.sh"]
