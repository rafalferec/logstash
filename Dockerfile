<<<<<<< HEAD
FROM debian:stretch
MAINTAINER David Personette <dperson@gmail.com>

# Install logstash (skip logstash-contrib)
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export url='https://artifacts.elastic.co/downloads/logstash' && \
    export version='5.5.0' && \
    export sha1sum='d380e8cdefb4c0d5291d0243b8ab5a9f20811826' && \
    groupadd -r logstash && \
    useradd -c 'Logstash' -d /opt/logstash -g logstash -r logstash && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                openjdk-8-jre procps libzmq5 \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    file="logstash-${version}.tar.gz" && \
    echo "downloading $file ..." && \
    curl -LOSs ${url}/$file && \
    sha1sum $file | grep -q "$sha1sum" || \
    { echo "expected $sha1sum, got $(sha1sum $file)"; exit 13; } && \
    tar -xf $file -C /tmp && \
    mv /tmp/logstash-* /opt/logstash && \
    ln -s /usr/lib/*/libzmq.so.5 /usr/local/lib/libzmq.so && \
    chown -Rh logstash. /opt/logstash && \
    apt-get purge -qqy curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* $file
COPY logstash.conf /opt/logstash/config/
COPY logstash.sh /usr/bin/

EXPOSE 5140 5140/udp

VOLUME ["/opt/logstash"]

ENTRYPOINT ["logstash.sh"]
=======
FROM jeanblanchard/busybox-java

# Logstash version
ENV VERSION 1.5.0
ENV LOGSTASH_HOME /opt/logstash
ENV GEM_PATH "$LOGSTASH_HOME/vendor/bundle/jruby/1.9"

RUN opkg-install bash

RUN curl "http://download.elastic.co/logstash/logstash/logstash-$VERSION.tar.gz" \
        | gunzip -c - | tar -xf - -C /opt && \
        mv "/opt/logstash-$VERSION" "$LOGSTASH_HOME" && \
        mkdir "$LOGSTASH_HOME/conf.d" && \
        mkdir -p /usr/local/bin

ENV PATH "$PATH:$LOGSTASH_HOME/vendor/jruby/bin"

# Prerequisites for the logstash-webhdfs plugin
RUN echo "gem \"webhdfs\"" >> "$LOGSTASH_HOME/Gemfile"
RUN gem install -i "$GEM_PATH" webhdfs

COPY conf.d/* "$LOGSTASH_HOME/conf.d/"
COPY plugins/* "$GEM_PATH/gems/logstash-core-$VERSION-java/lib/logstash/outputs/"
COPY start.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/start.sh"]

CMD ["logstash"]
>>>>>>> 129b4dfdcafa30636759546d9cb8cf569b0afd5b
