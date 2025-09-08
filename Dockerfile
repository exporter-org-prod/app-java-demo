FROM openjdk:17.0.2-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Update package list and install basic dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    curl \
    unzip \
    tar && \
    # Upgrade critical libraries to patched versions
    apt-get install -y --no-install-recommends libc6=2.31-13+deb11u4 libtirpc3=1.3.1-1+deb11u1 && \
    rm -rf /var/lib/apt/lists/* && \
    # Clean up
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    apt-get clean;

# Copy application files
COPY . .

# Command to run the application
CMD ["java", "-jar", "your-app.jar"]