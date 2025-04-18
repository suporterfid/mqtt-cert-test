# cert-generator/Dockerfile
FROM alpine:latest

RUN apk add --no-cache openssl

WORKDIR /certs

COPY generate-certs.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-certs.sh

CMD ["generate-certs.sh"]