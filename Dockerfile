FROM alpine:3.20 AS ssm-builder

RUN apk add dpkg curl; \
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"; \
    dpkg -x session-manager-plugin.deb session-manager-plugin


FROM alpine:3.20

RUN apk add --update --no-cache \
    curl \
    jq \
    ca-certificates \
    bash \
    aws-cli \
    gcompat \
    && rm -rf /var/cache/apk/*

COPY --from=ssm-builder /session-manager-plugin/usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/
RUN chmod +x /usr/local/bin/session-manager-plugin

COPY update.sh /bin/
COPY ecs-deploy /bin/

ENTRYPOINT ["/bin/bash"]

CMD ["/bin/update.sh"]
