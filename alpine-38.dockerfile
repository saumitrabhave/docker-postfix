FROM tozd/postfix:alpine-38

 ENV CYRUS_SASL_VERSION=2.1.26 \
    TINI_VERSION=0.8.3

RUN set -x \
 && mkdir -p /srv/saslauthd.d /tmp/cyrus-sasl /var/run/saslauthd \
 && export BUILD_DEPS=" \
        autoconf \
        automake \
        curl \
        db-dev \
        g++ \
        gcc \
        gzip \
        heimdal-dev \
        libtool \
        make \
        tar \
    " \
 && apk add --update ${BUILD_DEPS} \
        mysql-dev \
 && curl -fL ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-${CYRUS_SASL_VERSION}.tar.gz -o /tmp/cyrus-sasl.tgz \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/cyrus-sasl/cyrus-sasl-2.1.25-avoid_pic_overwrite.patch?h=3.2-stable -o /tmp/cyrus-sasl-2.1.25-avoid_pic_overwrite.patch \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/cyrus-sasl/cyrus-sasl-2.1.26-size_t.patch?h=3.2-stable -o /tmp/cyrus-sasl-2.1.26-size_t.patch \
 && tar -xzf /tmp/cyrus-sasl.tgz --strip=1 -C /tmp/cyrus-sasl \
 && cd /tmp/cyrus-sasl \
 && patch -p1 -i /tmp/cyrus-sasl-2.1.25-avoid_pic_overwrite.patch || true \
 && patch -p1 -i /tmp/cyrus-sasl-2.1.26-size_t.patch || true \
 && ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-anon \
        --enable-cram \
        --enable-digest \
        --enable-login \
        --enable-ntlm \
        --enable-sql \
        --disable-otp \
        --enable-plain \
        --with-mysql="/usr/include/mysql/" \
        --with-devrandom=/dev/urandom \
        --with-saslauthd=/var/run/saslauthd \
        --mandir=/usr/share/man \
 && make -j1 \
 && make -j1 install \
# Clean up build-time packages
 && apk del --purge ${BUILD_DEPS} \
# Clean up anything else
 && rm -fr \
    /tmp/* \
    /var/tmp/* \
    /var/cache/apk/*