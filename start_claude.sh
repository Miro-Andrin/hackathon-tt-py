#!/usr/bin/env bash

USE_BEDROCK=1
USE_TELEMETRY=1
PASSTHROUGH=()

for arg in "$@"; do
  case "$arg" in
    --no-bedrock)   USE_BEDROCK=0 ;;
    --no-telemetry) USE_TELEMETRY=0 ;;
    *)              PASSTHROUGH+=("$arg") ;;
  esac
done

if [ "$USE_BEDROCK" = "1" ]; then
  export ANTHROPIC_DEFAULT_SONNET_MODEL=bedrock/global.anthropic.claude-sonnet-4-6
  export ANTHROPIC_DEFAULT_HAIKU_MODEL=bedrock/global.anthropic.claude-haiku-4-5-20251001-v1:0
  export ANTHROPIC_BASE_URL=https://bifrost.hackathon.menneskeogmaskin.no/anthropic
  export ANTHROPIC_AUTH_TOKEN=sk-bf-b29ed51f-f40f-460e-b554-0c3ec0a1b539
fi

if [ "$USE_TELEMETRY" = "1" ]; then
  read -rp "Your email address: " USER_EMAIL
  export CLAUDE_CODE_ENABLE_TELEMETRY=1
  export CLAUDE_CODE_USER_EMAIL="${USER_EMAIL}"
  export OTEL_METRICS_EXPORTER=otlp
  export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
  export OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp-gateway-prod-eu-north-0.grafana.net/otlp
  export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic MTU4NzQ2MzpnbGNfZXlKdklqb2lNVGN5TlRJd015SXNJbTRpT2lKamJHRjFaR1V0WTI5a1pTSXNJbXNpT2lJMVRUWnRWMHMwVXpGcFEwRnZZelo2VGpBd1VUazNlRFlpTENKdElqcDdJbklpT2lKd2NtOWtMV1YxTFc1dmNuUm9MVEFpZlgwPQ=="
  export OTEL_METRIC_EXPORT_INTERVAL=6000
  export OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=cumulative
  export OTEL_LOG_USER_PROMPTS=0
  export OTEL_LOG_TOOL_DETAILS=1
  export OTEL_RESOURCE_ATTRIBUTES="user.email=${USER_EMAIL}"
fi

claude --model ${ANTHROPIC_DEFAULT_SONNET_MODEL:-claude-sonnet-4-6} "${PASSTHROUGH[@]}"

