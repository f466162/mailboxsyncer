FROM alpine:stable

ADD sync.sh /sync.sh

RUN apk add --no-cache imapsync && \
    apk cache clean && \
    chmod +x /sync.sh && \
    useradd -r -d /data syncer

VOLUME /data

WORKDIR /data

USER /data
