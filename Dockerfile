FROM openjdk:17-slim

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
    tar \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK 17
# Using a secure and specific version
RUN wget --no-verbose -O openjdk.tar.gz https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz && \
    echo '0022753d0cceecacdd3a795dd4cea2bd7ffdf9dc06e22ffd1be98411742fbb44  openjdk.tar.gz' | sha256sum --check && \
    mkdir -p $JAVA_HOME && \
    tar -xzf openjdk.tar.gz --strip-components=1 -C $JAVA_HOME && \
    rm openjdk.tar.gz && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Use non-root user for security
RUN useradd -m appuser
USER appuser

# Expose the port for Tomcat
EXPOSE 8080