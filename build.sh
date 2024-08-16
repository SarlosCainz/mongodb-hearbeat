#!/bin/bash

set -eux

if [ "$#" -lt 1 ]; then
  echo "$(basename $0): image [registry profile region]"
  exit 1
fi

IMAGE=$1
REGISTRY=${2:-}
PROFILE=${3:-default}
REGION=ap-northeast-1

docker buildx build --load --platform linux/amd64 -t "$IMAGE" --progress plain .

if [ "$REGISTRY" != "" ]; then
  docker tag "$IMAGE" "$REGISTRY"/"$IMAGE"
  aws ecr get-login-password --region "$REGION" --profile "$PROFILE" | docker login --username AWS --password-stdin "$REGISTRY"
  docker push "$REGISTRY"/"$IMAGE"
fi
