# DO NOT EDIT. Edit Dockerfile-9.4 and use update.sh
FROM openjdk:11-jre-slim

ENV JETTY_HOME /usr/local/jetty
ENV JETTY_BASE /var/lib/jetty
ENV TMPDIR /tmp/jetty
ENV PATH $JETTY_HOME/bin:$PATH

COPY --from=jetty:9.4-jdk13 $JETTY_HOME $JETTY_HOME
COPY --from=jetty:9.4-jdk13 $JETTY_BASE $JETTY_BASE

RUN set -xe \
	&& mkdir -p "$TMPDIR" \
	&& groupadd -r jetty && useradd -r -g jetty jetty \
	&& chown -R jetty:jetty "$JETTY_HOME" "$JETTY_BASE" "$TMPDIR" \
	&& rm -rf /tmp/hsperfdata_root

WORKDIR $JETTY_BASE
COPY docker-entrypoint.sh generate-jetty-start.sh /

USER jetty
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]

