FROM eclipse-temurin:17-jre-jammy as builder

ARG OPENHAB_VERSION
ARG IS_MILESTONE=false

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /openhab

# Set the URL for downloading openHAB
ARG RELEASE_URL=https://github.com/openhab/openhab-distro/releases/download/${OPENHAB_VERSION}/openhab-${OPENHAB_VERSION}.zip
ARG MILESTONE_URL=https://openhab.jfrog.io/artifactory/libs-milestone-local/org/openhab/distro/openhab/${OPENHAB_VERSION}/openhab-${OPENHAB_VERSION}.zip

# Use different URL based on whether this is a milestone release
RUN if [ "$IS_MILESTONE" = "true" ]; then \
    echo "Using milestone URL: $MILESTONE_URL" && \
    wget -nv -O openhab.zip "$MILESTONE_URL"; \
    else \
    echo "Using release URL: $RELEASE_URL" && \
    wget -nv -O openhab.zip "$RELEASE_URL"; \
    fi && \
    unzip openhab.zip -d /openhab && \
    rm openhab.zip

# Final stage
FROM eclipse-temurin:17-jre-jammy

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    fontconfig \
    locales \
    locales-all \
    netbase \
    tini \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV \
    CRYPTO_POLICY="unlimited" \
    EXTRA_JAVA_OPTS="" \
    GROUP_ID="9001" \
    JAVA_VERSION="17" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    OPENHAB_HTTP_PORT="8080" \
    OPENHAB_HTTPS_PORT="8443" \
    USER_ID="9001"

# Copy openHAB from builder
COPY --from=builder /openhab /openhab

WORKDIR /openhab

# Expose ports
EXPOSE 8080 8443 8101 5007

# Set volumes
VOLUME ["/openhab/conf", "/openhab/userdata", "/openhab/addons"]

# Set tini as entrypoint
ENTRYPOINT ["/usr/bin/tini", "-s"]
CMD ["/openhab/start.sh"]

LABEL org.opencontainers.image.source=https://github.com/jannegpriv/openhab-container
LABEL org.opencontainers.image.description="Custom openHAB container"
LABEL org.opencontainers.image.licenses=EPL-2.0
