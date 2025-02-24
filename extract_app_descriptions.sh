#!/bin/bash

APPS_DIR="Apps"

find "$APPS_DIR" -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' app_dir; do
  app_name=$(basename "$app_dir")
  docker_compose_file="$app_dir/docker-compose.yml"

  if [ -f "$docker_compose_file" ]; then
    echo "Processing: $app_name"
    description=$(yq '.x-casaos.description.en_us' "$docker_compose_file" 2>/dev/null)
    if [ -n "$description" ]; then
      description=$(sed 's/^"//g' <<< "$description" | sed 's/"$//g') # 移除引号
      echo "Extracted description: $description"
      echo "App: $app_name"
      echo "Description: $description"
      echo "--------------------"
    else
      echo "Warning: x-casaos.description.en_us not found for $app_name"
    fi
  else
    echo "Warning: docker-compose.yml not found for $app_name"
  fi
done