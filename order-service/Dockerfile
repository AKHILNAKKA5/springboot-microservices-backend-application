FROM eclipse-temurin:21-jre

VOLUME /tmp

COPY target/order-service-1.0-SNAPSHOT.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java","-jar","/app.jar"] 