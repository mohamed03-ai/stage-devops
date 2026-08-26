#!/usr/bin/env bash
#
# helm-deploy.sh — install or uninstall all Helm charts in ./helm
#
# Usage:
#   ./helm-deploy.sh install
#   ./helm-deploy.sh uninstall
#
set -euo pipefail

HELM_DIR="helm"

install_charts() {
  for chart_path in "$HELM_DIR"/*/; do
    chart_name=$(basename "$chart_path")
    echo ">> Installing $chart_name"
    helm upgrade --install "$chart_name" "$chart_path" \
      --wait
  done
}

uninstall_charts() {
  for chart_path in "$HELM_DIR"/*/; do
    chart_name=$(basename "$chart_path")
    echo ">> Uninstalling $chart_name"
    helm uninstall "$chart_name" --namespace "$chart_name" --ignore-not-found
  done
}

case "${1:-}" in
  install)
    install_charts
    ;;
  uninstall)
    uninstall_charts
    ;;
  *)
    echo "Usage: $0 {install|uninstall}"
    exit 1
    ;;
esac