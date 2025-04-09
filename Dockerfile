FROM "amazoncorretto:17"

COPY target/metricsapp-0.0.1-SNAPSHOT.jar .

ENTRYPOINT ["java", "-jar", "metricsapp-0.0.1-SNAPSHOT.jar"]
