FROM eclipse-temurin:21-jre

VOLUME /tmp

COPY target/notification-service-1.0-SNAPSHOT.jar app.jar

EXPOSE 8083

ENTRYPOINT ["java","-jar","/app.jar"] 