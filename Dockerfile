FROM gilleslamiral/imapsync

USER root

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=048b95b48b708983effb2e5c935a1ef8483d9e3e

VOLUME /data

ADD sync.sh /usr/local/bin/sync
ADD crontab /data/crontab

# apk add --no-cache imapsync bash curl tzdata flock && \
RUN apt-get update && \
    apt-get install -y curl && \
    chmod +x /usr/local/bin/sync && \
    adduser --uid 999 --home /data --no-create-home --system syncer && \
    curl -fsSLO "$SUPERCRONIC_URL" && \
    echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - && \
    chmod +x "$SUPERCRONIC" && \
    mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
    ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic && \
    apt-get remove -y curl  && \
    apt-get autoremove -y && \
    apt-get autoclean -y

WORKDIR /data

USER syncer

ENTRYPOINT [ "/usr/local/bin/supercronic", "-quiet", "/data/crontab" ]
