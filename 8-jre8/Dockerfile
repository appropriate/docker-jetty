FROM java:8-jre

ENV JETTY_HOME /usr/local/jetty
ENV PATH $JETTY_HOME/bin:$PATH
RUN mkdir -p "$JETTY_HOME"
WORKDIR $JETTY_HOME

# see http://dev.eclipse.org/mhonarc/lists/jetty-users/msg05220.html
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
        5DE533CB43DAF8BC3E372283E7AE839CD7C58886

ENV JETTY_MAJOR 8
ENV JETTY_VERSION 8.1.16.v20140903
ENV JETTY_TGZ_URL http://eclipse.org/downloads/download.php?r=1&file=/jetty/stable-$JETTY_MAJOR/dist/jetty-distribution-$JETTY_VERSION.tar.gz

RUN curl -SL "$JETTY_TGZ_URL" -o jetty.tar.gz \
    && curl -SL "$JETTY_TGZ_URL.asc" -o jetty.tar.gz.asc \
    && gpg --verify jetty.tar.gz.asc \
    && tar -xvf jetty.tar.gz --strip-components=1 \
    && rm jetty.tar.gz*

RUN { \
        echo '<?xml version="1.0"?>'; \
        echo '<!DOCTYPE Configure PUBLIC "-//Jetty//Configure//EN" "http://www.eclipse.org/jetty/configure.dtd">'; \
        echo '<Configure id="Server" class="org.eclipse.jetty.server.Server"/>'; \
    } > etc/jetty-logging.xml

EXPOSE 8080
CMD ["jetty.sh", "run"]
