# cspell:disable-next-line
FROM eclipse-temurin:21-jre

VOLUME /tmp

COPY target/product-service-1.0-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app.jar"] 