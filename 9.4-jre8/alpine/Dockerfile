FROM openjdk:8-jre-alpine

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN addgroup -S jetty && adduser -D -S -H -G jetty jetty && rm -rf /etc/group- /etc/passwd- /etc/shadow-

ENV JETTY_HOME /usr/local/jetty
ENV PATH $JETTY_HOME/bin:$PATH
RUN mkdir -p "$JETTY_HOME"
WORKDIR $JETTY_HOME

ENV JETTY_VERSION 9.4.12.v20180830
ENV JETTY_TGZ_URL https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/$JETTY_VERSION/jetty-home-$JETTY_VERSION.tar.gz

# GPG Keys are personal keys of Jetty committers (see https://github.com/eclipse/jetty.project/blob/0607c0e66e44b9c12a62b85551da3a0edce0281e/KEYS.txt)
ENV JETTY_GPG_KEYS \
	# Jan Bartel      <janb@mortbay.com>
	AED5EE6C45D0FE8D5D1B164F27DED4BF6216DB8F \
	# Jesse McConnell <jesse.mcconnell@gmail.com>
	2A684B57436A81FA8706B53C61C3351A438A3B7D \
	# Joakim Erdfelt  <joakim.erdfelt@gmail.com>
	5989BAF76217B843D66BE55B2D0E1FB8FE4B68B4 \
	# Joakim Erdfelt  <joakim@apache.org>
	B59B67FD7904984367F931800818D9D68FB67BAC \
	# Joakim Erdfelt  <joakim@erdfelt.com>
	BFBB21C246D7776836287A48A04E0C74ABB35FEA \
	# Simone Bordet   <simone.bordet@gmail.com>
	8B096546B1A8F02656B15D3B1677D141BCF3584D \
	# Greg Wilkins    <gregw@webtide.com>
	FBA2B18D238AB852DF95745C76157BDF03D0DCD6 \
	# Greg Wilkins    <gregw@webtide.com>
	5C9579B3DB2E506429319AAEF33B071B29559E1E

RUN set -xe \
	# Install required packages for build time. Will be removed when build finishes.
	&& apk add --no-cache --virtual .build-deps gnupg curl \

	&& curl -SL "$JETTY_TGZ_URL" -o jetty.tar.gz \
	&& curl -SL "$JETTY_TGZ_URL.asc" -o jetty.tar.gz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& for key in $JETTY_GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; done \
	&& gpg --batch --verify jetty.tar.gz.asc jetty.tar.gz \
	&& rm -rf "$GNUPGHOME" \
	&& tar -xvzf jetty.tar.gz \
	&& mv jetty-home-$JETTY_VERSION/* ./ \
	&& sed -i '/jetty-logging/d' etc/jetty.conf \
	&& rm jetty.tar.gz* \
	&& rm -fr jetty-home-$JETTY_VERSION/ \

	# Remove installed packages and various cleanup
	&& apk del .build-deps \
	&& rm -fr .build-deps \
	&& rm -rf /tmp/hsperfdata_root

ENV JETTY_BASE /var/lib/jetty
RUN mkdir -p "$JETTY_BASE"
WORKDIR $JETTY_BASE

RUN set -xe \
	&& java -jar "$JETTY_HOME/start.jar" --create-startd --add-to-start="server,http,deploy,jsp,jstl,ext,resources,websocket" \
	&& chown -R jetty:jetty "$JETTY_BASE" \
	&& rm -rf /tmp/hsperfdata_root

ENV TMPDIR /tmp/jetty
RUN set -xe \
	&& mkdir -p "$TMPDIR" \
	&& chown -R jetty:jetty "$TMPDIR"

COPY docker-entrypoint.sh generate-jetty-start.sh /

USER jetty
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]
