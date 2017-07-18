FROM openjdk:8-jre

# install plugin dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		apt-transport-https \
		libzmq5 \
	&& rm -rf /var/lib/apt/lists/*

# the "ffi-rzmq-core" gem is very picky about where it looks for libzmq.so
RUN mkdir -p /usr/local/lib \
	&& ln -s /usr/lib/*/libzmq.so.3 /usr/local/lib/libzmq.so

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

RUN set -ex; \
# https://artifacts.elastic.co/GPG-KEY-elasticsearch
	key='46095ACC8548582C1A2699A9D27D666CD88E42B4'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/elastic.gpg; \
	rm -rf "$GNUPGHOME"; \
	apt-key list

# https://www.elastic.co/guide/en/logstash/5.0/installing-logstash.html#_apt
RUN echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' > /etc/apt/sources.list.d/logstash.list

ENV LOGSTASH_VERSION 5.5.0
ENV LOGSTASH_DEB_VERSION 1:5.5.0-1

RUN set -ex; \
	case "$LOGSTASH_VERSION" in \
# W: http://packages.elastic.co/logstash/2.4/debian/dists/stable/Release.gpg: Signature by key 46095ACC8548582C1A2699A9D27D666CD88E42B4 uses weak digest algorithm (SHA1)
# https://github.com/elastic/logstash/issues/5761
		2.*) apt-get update -o 'APT::Hashes::SHA1::Weak=yes' ;; \
		*) apt-get update ;; \
	esac; \
	apt-get install -y --no-install-recommends "logstash=$LOGSTASH_DEB_VERSION"; \
	rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/logstash/bin:$PATH

# necessary for 5.0+ (overriden via "--path.settings", ignored by < 5.0)
ENV LS_SETTINGS_DIR /etc/logstash
# comment out some troublesome configuration parameters
#   path.config: No config files found: /etc/logstash/conf.d/*
RUN set -ex; \
	if [ -f "$LS_SETTINGS_DIR/logstash.yml" ]; then \
		sed -ri 's!^path\.config:!#&!g' "$LS_SETTINGS_DIR/logstash.yml"; \
	fi; \
# if the "log4j2.properties" file exists (logstash 5.x), let's empty it out so we get the default: "logging only errors to the console"
	if [ -f "$LS_SETTINGS_DIR/log4j2.properties" ]; then \
		cp "$LS_SETTINGS_DIR/log4j2.properties" "$LS_SETTINGS_DIR/log4j2.properties.dist"; \
		truncate --size=0 "$LS_SETTINGS_DIR/log4j2.properties"; \
	fi
ENV LS_CONF_DIR /etc/logstash/conf.d
cp /usr/logstash-settings/logstash.conf /etc/logstash/conf.d
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["-e", ""]
