#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

IMAGE_NAME="ghcr.io/sethcarlton/devbox:latest"
PLATFORMS="linux/amd64,linux/arm64"

echo -e "${YELLOW}Publishing devbox container to GitHub Container Registry${NC}"
echo -e "${YELLOW}Platforms: ${PLATFORMS}${NC}"
echo ""

echo -e "${GREEN}Setting up buildx builder${NC}"
if ! docker buildx inspect multiarch >/dev/null 2>&1; then
    docker buildx create --name multiarch --use
else
    docker buildx use multiarch
fi

echo -e "${GREEN}Building and pushing multi-arch image: ${IMAGE_NAME}${NC}"

docker buildx build \
    --platform "${PLATFORMS}" \
    --tag "${IMAGE_NAME}" \
    --push \
    .

echo ""
echo -e "${GREEN}Successfully published ${IMAGE_NAME} for ${PLATFORMS}${NC}"
