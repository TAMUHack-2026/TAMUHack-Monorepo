FROM eclipse-temurin:25

WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y maven

RUN mvn package
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "target/gateway-service.jar"]
