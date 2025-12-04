#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

IMAGE_NAME="ghcr.io/sethcarlton/devbox:latest"
PLATFORMS="linux/amd64,linux/arm64"

echo -e "${YELLOW}Publishing devbox container to GitHub Container Registry${NC}"
echo -e "${YELLOW}Platforms: ${PLATFORMS}${NC}"
echo ""

# Ensure buildx builder exists and is using it
echo -e "${GREEN}Setting up buildx builder${NC}"
if ! docker buildx inspect multiarch >/dev/null 2>&1; then
    docker buildx create --name multiarch --use
else
    docker buildx use multiarch
fi

# Build and push for multiple architectures
echo -e "${GREEN}Building and pushing multi-arch image: ${IMAGE_NAME}${NC}"
# Use .. because the script is in build/ but the Dockerfile is in root
docker buildx build \
    --platform "${PLATFORMS}" \
    --tag "${IMAGE_NAME}" \
    --push \
    ..

echo ""
echo -e "${GREEN}Successfully published ${IMAGE_NAME} for ${PLATFORMS}${NC}"
