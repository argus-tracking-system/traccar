FROM gradle:jdk11 AS DEPENDENCY_CACHE

ENV APP_HOME=/traccar
WORKDIR $APP_HOME

COPY build.gradle settings.gradle gradlew $APP_HOME/
COPY gradle $APP_HOME/gradle
RUN gradle -g $APP_HOME/.gradle --no-daemon --parallel -i dependencies

# =============

FROM gradle:jdk11 AS MAIN_BUILD

ENV ARTIFACT_NAME=tracker-server.jar
ENV APP_HOME=/traccar
ENV FORWARD_URL=https://forward-url-unset.local
WORKDIR $APP_HOME

COPY --from=DEPENDENCY_CACHE $APP_HOME/.gradle $APP_HOME/.gradle
COPY build.gradle settings.gradle debug.xml swagger.json $APP_HOME/
COPY gradle $APP_HOME/gradle
COPY schema $APP_HOME/schema
COPY src $APP_HOME/src

RUN gradle -g $APP_HOME/.gradle --no-daemon --no-watch-fs --parallel -i assemble

COPY setup $APP_HOME/setup

EXPOSE 5000-5223/tcp 5000-5223/udp

CMD java -jar -Dforward.enable=true -Dforward.json=true -Dforward.url=https://forward-url-unset.local target/$ARTIFACT_NAME

