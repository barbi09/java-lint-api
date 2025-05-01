# Stage 1: Building the code
FROM maven:3.9.5-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# ARG USERNAME
# ARG PASSWORD

COPY target .

RUN ls -l
#RUN mvn -gs settings.xml clean package -q && \
#RUN mvn clean package -q && \
#    ls -l

# Stage 3: Docker image app
FROM openjdk:17-jdk-alpine
WORKDIR /app

RUN ls -l
# COPY --from=builder /app/target/*.jar /app/app.jar
COPY target/*.jar /app/app.jar

# Starting the app
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar /app/app.jar"]