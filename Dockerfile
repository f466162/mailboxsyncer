FROM alpine

ADD sync.sh /sync.sh

RUN apk add --no-cache imapsync && \
    chmod +x /sync.sh && \
    adduser --home /data --no-create-home --system syncer

VOLUME /data

WORKDIR /data

USER /data
