#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

UNRAID_IMAGE_NAME="ghcr.io/sethcarlton/devbox:unraid"
UNRAID_USER="seth"
UNRAID_UID="1000"
UNRAID_GID="100"
UNRAID_PLATFORM="linux/amd64"

echo -e "${YELLOW}Publishing Unraid specific image (User: ${UNRAID_USER})${NC}"
echo -e "${YELLOW}Platform: ${UNRAID_PLATFORM}${NC}"
echo ""

# Ensure buildx builder exists and is using it
if ! docker buildx inspect multiarch >/dev/null 2>&1; then
    docker buildx create --name multiarch --use
else
    docker buildx use multiarch
fi

echo -e "${GREEN}Building and pushing image: ${UNRAID_IMAGE_NAME}${NC}"

# Use .. because the script is in build/ but the Dockerfile is in root
docker buildx build \
    --platform "${UNRAID_PLATFORM}" \
    --build-arg USERNAME="${UNRAID_USER}" \
    --build-arg USER_UID="${UNRAID_UID}" \
    --build-arg USER_GID="${UNRAID_GID}" \
    --tag "${UNRAID_IMAGE_NAME}" \
    --push \
    ..

echo ""
echo -e "${GREEN}Successfully published ${UNRAID_IMAGE_NAME} for ${UNRAID_PLATFORM}${NC}"
