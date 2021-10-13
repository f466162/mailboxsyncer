FROM alpine

ADD sync.sh /sync.sh

RUN apk add --no-cache imapsync && \
    chmod +x /sync.sh && \
    useradd -r -d /data syncer

VOLUME /data

WORKDIR /data

USER /data
