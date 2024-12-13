FROM alpine:latest
COPY portal /usr/local/bin/portal
ENTRYPOINT ["/usr/local/bin/portal"]