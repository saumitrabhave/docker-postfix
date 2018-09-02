FROM tozd/postfix:alpine-38

RUN apk update && \
 apk add cyrus-sasl
