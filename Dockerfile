FROM openjdk:8-jdk-alpine

RUN addgroup -S gatling && adduser -S -G gatling gatling

RUN apk add --no-cache wget ca-certificates bash git && \
    cd /tmp && \
    wget --no-verbose https://downloads.typesafe.com/scala/2.12.8/scala-2.12.8.tgz && \
    tar xzf /tmp/scala-2.12.8.tgz && \
    mkdir -p /home/gatling/scala && \
    mv /tmp/scala-2.12.8/bin /tmp/scala-2.12.8/lib /home/gatling/scala && \
    ln -s /home/gatling/scala/bin /usr/bin && \
    rm -rf /tmp/*

RUN export PATH=/usr/local/sbt/bin:$PATH &&  \
    cd /tmp && \
    wget --no-verbose https://github.com/sbt/sbt/releases/download/v1.2.8/sbt-1.2.8.tgz && \
    tar xzf /tmp/sbt-1.2.8.tgz && \
    mv /tmp/sbt /usr/local/sbt && \
    ln -s /usr/local/sbt/bin/* /usr/local/bin/ && \
    rm -rf /tmp/* && \
    sbt sbtVersion

#ADD build.sbt /home/gatling/gatling-git

WORKDIR /home/gatling/gatling-git

VOLUME ["/data", "/scenarios"]

RUN chown -R gatling:gatling . && \
    chown -R gatling:gatling /data && \
    chown -R gatling:gatling /scenarios

USER gatling

RUN mkdir -p src/test/resources/data && \
    ln -sf /data src/test/resources/data && \
    mkdir -p src/test/scala && \
    ln -sf /scenarios src/test/scala

ONBUILD RUN sbt compile
CMD ["sbt", "gatling:test"]
