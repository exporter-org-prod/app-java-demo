FROM maven:3.8.4-openjdk-17-slim AS build

WORKDIR /app

# Copy the Maven project files into the container
COPY . .

# Build the Maven project
RUN mvn clean install
RUN mvn dependency:copy-dependencies

# Use a smaller image for deployment
FROM openjdk:17-slim

LABEL org.opencontainers.image.base.name="openjdk:17-slim"
# Set the working directory inside the container
WORKDIR /app

# Copy the built artifact from the build stage
COPY --from=build /app/target/endor-java-webapp-demo.jar .
COPY --from=build /app/target/endor-java-webapp-demo-jar-with-dependencies.jar .
# Expose any necessary ports
EXPOSE 443

# Set the command to run your application
CMD ["java", "-jar", "endor-java-webapp-demo.jar"]
