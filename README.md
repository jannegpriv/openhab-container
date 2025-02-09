# openHAB Container

This repository contains a Docker container setup for openHAB with automated builds using GitHub Actions. It supports both regular releases and milestone versions.

## Features

- Multi-stage build for optimized container size
- Based on eclipse-temurin Java 17
- Automated builds via GitHub Actions
- Support for both regular and milestone releases
- Container images published to GitHub Container Registry (GHCR)

## Usage

### Pull and Run (Regular Release)

```bash
docker pull ghcr.io/jannegpriv/openhab-container:4.1.1
docker compose up -d
```

### Using Docker Compose

The included `docker-compose.yml` provides a complete setup. To use a specific version, modify the build args:

```yaml
# For regular release
build:
  args:
    OPENHAB_VERSION: "4.1.1"
    IS_MILESTONE: "false"

# For milestone release
build:
  args:
    OPENHAB_VERSION: "4.3.2.M2"
    IS_MILESTONE: "true"
```

## Creating New Versions

To create a new version of the OpenHAB container:

1. Update version in `docker-compose.yml`:
   ```yaml
   image: ghcr.io/jannegpriv/openhab-container:${OPENHAB_VERSION:-4.3.2}
   ```

2. Commit and tag the new version:
   ```bash
   # Commit the changes
   git add docker-compose.yml
   git commit -m "Update to OpenHAB X.Y.Z"
   
   # Create and push the version tag
   git tag vX.Y.Z
   git push && git push --tags
   ```

3. GitHub Actions will automatically:
   - Build the new container image
   - Tag it with the version number and 'latest'
   - Push it to GitHub Container Registry

4. Deploy the new version:
   ```bash
   # Pull and start the new version
   docker compose pull
   docker compose up -d
   ```

## Local Development

For local testing and development, you can build the image directly:

```bash
# Build with default version
docker build -t openhab-local .

# Build with specific version
docker build --build-arg OPENHAB_VERSION=4.3.2 --build-arg IS_MILESTONE=false -t openhab-local .

# Run the local build
docker run -p 8080:8080 openhab-local
```

Note: For production use, prefer the pre-built images from GitHub Container Registry as described above.

### GitHub Actions Automated Builds

The repository uses GitHub Actions to automatically build and publish images. Builds are triggered by:

1. Regular Releases:
```bash
git tag v4.1.1
git push origin v4.1.1
```

2. Milestone Releases:
```bash
git tag v4.3.2.M2
git push origin v4.3.2.M2
```

3. Push to main branch (creates 'latest' tag)

Supported tag formats:
- Regular releases: `v4.1.1`
- Milestone releases: 
  - `v4.3.2.M2` (uppercase M)
  - `v4.3.2.m2` (lowercase m)
  - `v4-milestone.2` (alternative format)

### Required GitHub Setup

1. Ensure repository has access to GitHub Packages
2. No additional secrets needed as GITHUB_TOKEN is used

## Configuration

### Ports

- 8080: HTTP port
- 8443: HTTPS port
- 8101: Console port
- 5007: LSP port

### Volumes

- `/openhab/conf`: Configuration files
- `/openhab/userdata`: User data and database
- `/openhab/addons`: Optional add-ons

### Environment Variables

- `USER_ID`: User ID for openHAB process (default: 9001)
- `GROUP_ID`: Group ID for openHAB process (default: 9001)
- `EXTRA_JAVA_OPTS`: Additional Java options
- `OPENHAB_HTTP_PORT`: HTTP port (default: 8080)
- `OPENHAB_HTTPS_PORT`: HTTPS port (default: 8443)

## License

This project is licensed under the EPL-2.0 License.
