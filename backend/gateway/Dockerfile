FROM eclipse-temurin:25

WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y maven

RUN mvn package
ENTRYPOINT ["java", "-jar", "target/gateway-service.jar"]
