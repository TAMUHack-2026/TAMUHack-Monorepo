FROM eclipse-temurin:25

WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y maven python3
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install -r requirements.txt

RUN mvn package
ENTRYPOINT ["java", "-jar", "target/model-service.jar"]
