FROM eclipse-temurin:25

WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y maven python3 python3-pip
RUN pip3 install -r requirements.txt --break-system-packages

RUN mvn package
ENTRYPOINT ["java", "-jar", "target/model-service.jar"]
