#!/bin/bash

APPS_DIR="Apps"
UNIQUE_CATEGORIES=()

find "$APPS_DIR" -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' app_dir; do
  app_name=$(basename "$app_dir")
  docker_compose_file="$app_dir/docker-compose.yml"

  if [ -f "$docker_compose_file" ]; then
    echo "Processing: $app_name"
    category=$(yq '.x-casaos.category' "$docker_compose_file" 2>/dev/null)
    if [ -n "$category" ]; then
      category=$(sed 's/^"//g' <<< "$category" | sed 's/"$//g') # 移除引号
      echo "Extracted category: $category"
      echo "App: $app_name"
      echo "Category: $category"
      echo "--------------------"
      UNIQUE_CATEGORIES+=("$category") # 添加到数组
    else
      echo "Warning: x-casaos.category not found for $app_name"
    fi
  else
    echo "Warning: docker-compose.yml not found for $app_name"
  fi
done

echo "Unique Categories:"
IFS=$'\n' sorted_categories=($(sort -u <<<"${UNIQUE_CATEGORIES[*]}")) # 排序并去重
for cat in "${sorted_categories[@]}"; do
  echo "- $cat"
done