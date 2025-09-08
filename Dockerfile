
		# Use a secure Maven image to build the application in a build stage
FROM maven:3.8.4-openjdk-17 AS build

# Set working directory for the build stage
WORKDIR /app

# Copy the Maven project files into the container
COPY . .

# Build the Maven project
RUN mvn clean install

# Use a secure base image for the runtime
FROM openjdk:17.0.6-slim # Updated to a secure JDK version to mitigate vulnerabilities adding this to check pr creation

# Set the working directory for the runtime
WORKDIR /app

# Copy the built artifact from the build stage
COPY --from=build /app/target/endor-java-webapp-demo.jar .