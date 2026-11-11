#!/usr/bin/env bash
set -eu

http_hits="$(grep -rl "package:http" lib/ | grep -v -e "core/api" -e "_repository.dart" || true)"
material_hits="$(grep -rl "package:flutter/material" lib/ | grep -e "_model.dart" -e "_repository.dart" -e "core/api" || true)"

if [ -n "$http_hits" ] || [ -n "$material_hits" ]; then
  printf '%s\n' "$http_hits" "$material_hits" | sed '/^$/d'
  exit 1
fi
