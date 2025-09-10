# Use an updated Maven builder with JDK 17 to remediate vulnerabilities from older Debian-based images
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set working directory for build
WORKDIR /app

# Copy Maven descriptor first to leverage build cache for dependencies
COPY pom.xml .

# Pre-fetch dependencies to improve build reproducibility and speed
RUN mvn -B -DskipTests dependency:go-offline

# Copy the full project
COPY . .

# Enforce patched dependency versions to remediate CVEs in transitive libraries
RUN mvn -B -DprocessDependencies=true versions:use-dep-version -Dincludes=org.apache.commons:commons-text -DdepVersion=1.10.0 -DforceVersion=true && \
    mvn -B -DprocessDependencies=true versions:use-dep-version -Dincludes=org.slf4j:slf4j-ext -DdepVersion=1.7.36 -DforceVersion=true

# Build the Maven project and copy dependencies
RUN mvn -B clean install && mvn -B dependency:copy-dependencies


# Use a minimal, secure JRE 17 runtime based on Ubuntu Jammy to eliminate vulnerable Debian 11 packages
FROM eclipse-temurin:17-jre-jammy

# Document the secure base image used for runtime
LABEL org.opencontainers.image.base.name="eclipse-temurin:17-jre-jammy"

# Set the working directory inside the container
WORKDIR /app

# Create a non-root user and group to run the application with least privilege
RUN groupadd -r appgroup --gid 10001 && \
    useradd -r -u 10001 -g appgroup -d /app -s /usr/sbin/nologin appuser

# Copy the built artifacts from the build stage with non-root ownership
COPY --from=build --chown=10001:10001 /app/target/endor-java-webapp-demo.jar .
COPY --from=build --chown=10001:10001 /app/target/endor-java-webapp-demo-jar-with-dependencies.jar .

# Restrict file permissions to reduce attack surface
RUN chmod 0444 /app/endor-java-webapp-demo.jar && \
    chmod 0440 /app/endor-java-webapp-demo-jar-with-dependencies.jar

# Expose any necessary ports
EXPOSE 443

# Drop privileges and run as a non-root user
USER 10001:10001

# Set the command to run your application
CMD ["java", "-jar", "endor-java-webapp-demo.jar"]