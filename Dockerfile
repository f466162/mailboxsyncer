FROM alpine

ADD sync.sh /sync.sh

RUN apk add --no-cache imapsync jq && \
    chmod +x /sync.sh && \
    adduser --uid 999 --gid 999 --home /data --no-create-home --system syncer

VOLUME /data

WORKDIR /data

USER /data
